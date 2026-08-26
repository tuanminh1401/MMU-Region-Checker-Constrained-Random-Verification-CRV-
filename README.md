# MMU Region Checker & Constrained-Random Verification (CRV)

A parameterized SystemVerilog Memory Management Unit (MMU) Region Checker RTL paired with an Object-Oriented Constrained-Random Testbench environment.

## 📌 Key Features

- **Parameterized Architecture**: Fully configurable number of memory regions (`NUM_REGIONS`) with automated bit-width calculation for region indexing (`ID_WIDTH = $clog2(NUM_REGIONS)`).
- **Single-Cycle Combinatorial Hit Logic**: Parallel evaluation of address bounds returning access hits and region identifiers with zero latency overhead.
- **Hardware Safety Engine**: Combinatorial fault checking logic detecting any overlapping address ranges between active regions (`overlap_fault`).
- **Constrained-Random Verification (CRV)**: SystemVerilog OOP testbench implementing multi-block random memory allocation, boundary alignment constraints (4-byte aligned), and random transaction injection.

## 📁 Project Structure

- `mmu_region_checker.sv`: Synthesizable MMU Region Checker RTL module.
- `tb_mem_system.sv`: SystemVerilog testbench containing `mem_block`, `mem_system` classes, and random transaction drivers.

## 🚀 How to Simulate

### Vivado (xsim via CLI)

```bash
xvlog -sv mmu_region_checker.sv tb_mem_system.sv
xelab tb -s top_sim
xsim top_sim -R
```
