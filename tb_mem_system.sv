class mem_block;
rand bit [31:0] start_addr;
rand bit [15:0] size;
bit [31:0] end_addr;

constraint kichthuoc {
    size inside {[1024:8192]};
    start_addr[1:0] == 2'b00;
    start_addr >= 32'h8000_0000;
    start_addr + size <= 32'h8001_0000;
}

function void post_randomize();
    end_addr = start_addr + size - 1; //địa chỉ byte cuối = địa chỉ byte đầu + số lượng byte - 1
endfunction
endclass

class mem_system;
rand mem_block blocks[];

function new(int num_blocks = 4);
    blocks = new[num_blocks];
    foreach (blocks[i]) blocks[i] = new();
endfunction

constraint c_space {
    foreach (blocks[i]) {
        foreach (blocks[j]) {
            if (i < j) {
                (blocks[i].start_addr + blocks[i].size <= blocks[j].start_addr) || (
                 blocks[j].start_addr + blocks[j].size <= blocks[i].start_addr   
                );
            } 
        }
    }
}

function void post_randomize();
    foreach(blocks[i]) blocks[i].post_randomize();
endfunction

endclass

module tb;
localparam N = 4;
logic clk = 0;
logic rst_n;

logic [31:0] region_start [N];
logic [31:0] region_end [N];
logic region_valid [N];

logic [31:0] req_addr;
logic req_valid;

logic hit;
logic [1:0] hit_region_id;
logic overlap_fault;

always #5 clk = ~clk;

mmu_region_checker #(.NUM_REGIONS(N))  dut (
    .clk(clk),
    .rst_n(rst_n),
    .region_start(region_start),
    .region_end(region_end),
    .region_valid(region_valid),
    .req_addr(req_addr),
    .req_valid(req_valid),
    .hit(hit),
    .hit_region_id(hit_region_id),
    .overlap_fault(overlap_fault)
);

mem_system mem;

initial begin
    rst_n     = 0;
    req_valid = 0;
    #20;
    rst_n     = 1;

    mem = new(N);
    if (!mem.randomize()) begin
        $fatal(1, "Random that bai!");
    end

    $display("=== DANH SACH PHAN VUNG BO NHO DUOC TAO ===");
    foreach (mem.blocks[i]) begin
        region_start[i] = mem.blocks[i].start_addr;
        region_end[i] = mem.blocks[i].end_addr;
        region_valid[i] = 1'b1;
        $display("Block %0d: 0x%08h -> 0x%08h (Size: %4d Bytes)", 
        i, region_start[i], region_end[i], mem.blocks[i].size);
    end

    #10;
    $display("\n=== KIEM TRA TRANG THAI RTL ===");
    if (overlap_fault) begin
        $display("[FAIL] RTL bao loi overlap_fault = 1!");
    end else begin
        $display("[PASS] RTL xac nhan: Khong co phan vung nao bi chong lan (overlap_fault = 0).");
    end

    $display("\n=== BAT DAU RANDOM TEST VECTOR (20 TRANS) ===");
    repeat (20) begin
        @(posedge clk);
        // Sinh ngau nhien req_addr va req_valid
        assert(std::randomize(req_addr, req_valid) with {req_addr inside {[32'h7fff_f000 : 32'h8001_1000]}; req_addr[1:0] == 2'b00; req_valid dist {1 := 90, 0 := 10};})
        else $error("Randomize stimulus that bai!");
    
        #1; // Doi mach to hop RTL phan hoi

        // Sinh ngau nhien req_addr va req_valid
        if (!req_valid) begin
            $display("[IDLE] req_valid = 0 | req_addr = 0x%08h -> Hit = %0b", req_addr, hit);
        end else if (hit) begin
            $display("[HIT] req_addr = 0x%08h -> Region %0d [%08h : %08h]", 
            req_addr, hit_region_id, region_start[hit_region_id], region_end[hit_region_id]);
        end else begin
            $display("[MISS] req_addr = 0x%08h -> Nam ngoai cac vung (Unmapped)", req_addr);
        end
    end

    #20;
    $finish;
end
endmodule