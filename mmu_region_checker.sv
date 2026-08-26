module mmu_region_checker #(parameter NUM_REGIONS = 4, parameter ID_WIDTH = $clog2(NUM_REGIONS)) (
    input logic clk,
    input logic rst_n,
    input logic [31:0] region_start [NUM_REGIONS],
    input logic [31:0] region_end [NUM_REGIONS],
    input logic region_valid [NUM_REGIONS],

    input logic [31:0] req_addr,
    input logic req_valid,

    output logic hit,
    output logic [ID_WIDTH-1:0] hit_region_id,
    output logic overlap_fault
);
    always_comb begin
        hit = 1'b0;
        hit_region_id = 0;
        if (req_valid) begin
            for (int i = 0; i < NUM_REGIONS; i++) begin
                if (region_valid[i] && (req_addr >= region_start[i]) && (req_addr <= region_end[i])) begin
                    hit = 1'b1;
                    hit_region_id = i[ID_WIDTH-1:0];
                end
            end
        end
    end

    always_comb begin
        overlap_fault = 1'b0;
        for (int i = 0; i < NUM_REGIONS; i++) begin
            for (int j = i + 1; j < NUM_REGIONS; j++) begin
                if (region_valid[i] && region_valid[j]) begin
                    if (!((region_end[i] < region_start[j]) || (region_end[j] < region_start[i]))) begin
                        overlap_fault = 1'b1;
                    end
                end
            end
        end
    end
endmodule