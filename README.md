# 64-bit RISC-V Processor Design

A complete **64-bit RISC-V (RV64I) Processor** implemented in **Verilog HDL**, featuring both **single-cycle** and **5-stage pipelined** architectures. This project was developed as part of an academic **Computer Architecture (IPA)** course and demonstrates the complete processor design flow—from designing a structural ALU to implementing a pipelined processor with hazard detection, forwarding, and branch handling.

---

## Highlights

- 64-bit **RV64I ISA** implementation
- Structural 64-bit ALU built from basic digital components
- Single-cycle RISC-V processor
- 5-stage pipelined processor (IF → ID → EX → MEM → WB)
- Data forwarding and hazard detection units
- Static branch prediction (Always Not-Taken)
- Modular Verilog implementation with extensive testbenches
- Simulated using **Icarus Verilog** and visualized with **GTKWave**

---

## Project Overview

| Feature | Sequential | Pipelined |
|----------|------------|------------|
| Architecture | Single-Cycle | 5-Stage Pipeline |
| ISA | RV64I | RV64I |
| Forwarding | N/A | EX→EX, MEM→EX |
| Hazard Detection | N/A | Load-Use Stall |
| Branch Prediction | N/A | Static (Not-Taken) |
| Simulation | Icarus Verilog | Icarus Verilog |

---

## Repository Structure

```text
RISC-V-Processor-Design/
│
├── IPA_RISC_V_SEQ/
│   ├── 2024102044_ALU/
│   │   ├── alu.v
│   │   ├── add_64.v
│   │   ├── ripple_carry_adder_64.v
│   │   ├── sll_64.v
│   │   ├── srl_64.v
│   │   ├── sra_64.v
│   │   ├── slt_64.v
│   │   ├── sltu_64.v
│   │   └── tb_*.v
│   │
│   └── Sequential_RISC_V_Processor/
│       ├── processor.v
│       ├── alu.v
│       ├── control_unit.v
│       ├── alu_control.v
│       ├── instruction_memory.v
│       ├── data_memory.v
│       ├── imm_gen.v
│       ├── register_file_module.v
│       ├── program_counter.v
│       ├── seq_tb.v
│       └── tb_*.v
│
├── Pipelined_Processor/
│   ├── pipelined_processor.v
│   ├── forwarding_unit.v
│   ├── hazard_detection_unit.v
│   ├── branch_predictor.v
│   ├── register_file_module.v
│   ├── pipe_tb.v
│   └── hazard_tb.v
│
├── gtkwave_demo/
├── instructions.txt
├── hazard_instructions.txt
├── register_file.txt
├── IPA_PROJECT.pdf
└── IPA_Pipelined_Project_Doc.pdf
```

---

# Phase 1 – 64-bit ALU Design

The processor was built from the ground up, beginning with a structural implementation of a **64-bit Arithmetic Logic Unit (ALU)**.

### Implemented Operations

- ADD
- SUB
- AND
- OR
- XOR
- SLL
- SRL
- SRA
- SLT
- SLTU

### Major Components

- Full Adder
- 64-bit Ripple Carry Adder
- Add/Sub Unit
- Shift Units
- Comparator Units
- Individual Verilog Testbenches

---

# Phase 2 – Sequential RISC-V Processor

A complete **single-cycle RV64I processor** was implemented with separate datapath and control logic.

## Supported Instructions

### R-Type

- ADD
- SUB
- AND
- OR
- XOR
- SLL
- SRL
- SRA
- SLT
- SLTU

### I-Type

- ADDI
- ANDI
- ORI
- XORI
- SLTI
- SLTIU
- LW
- LD
- JALR

### S-Type

- SW
- SD

### B-Type

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU

### U-Type

- LUI
- AUIPC

### J-Type

- JAL

The processor was validated by executing a **Fibonacci sequence program** through the complete datapath.

---

# Phase 3 – 5-Stage Pipelined Processor

Pipeline Stages:

```
Instruction Fetch (IF)
        ↓
Instruction Decode (ID)
        ↓
Execute (EX)
        ↓
Memory Access (MEM)
        ↓
Write Back (WB)
```

## Hazard Handling

| Hazard | Solution |
|---------|----------|
| RAW Data Hazard | Forwarding Unit |
| Load-Use Hazard | One-Cycle Stall |
| Control Hazard | Pipeline Flush on Taken Branch |

### Pipeline Features

- IF/ID pipeline register
- ID/EX pipeline register
- EX/MEM pipeline register
- MEM/WB pipeline register
- Forwarding Unit
- Hazard Detection Unit
- Static Branch Predictor

---

# Running the Project

## Prerequisites

```bash
sudo apt install iverilog gtkwave
```

---

## Sequential Processor

```bash
cd IPA_RISC_V_SEQ/Sequential_RISC_V_Processor

iverilog -o seq_sim \
seq_tb.v processor.v alu.v control_unit.v alu_control.v \
instruction_memory.v data_memory.v imm_gen.v \
register_file_module.v program_counter.v

./seq_sim

gtkwave processor_tb.vcd
```

---

## Pipelined Processor

```bash
cd Pipelined_Processor

iverilog -o pipe_sim \
pipe_tb.v pipelined_processor.v \
forwarding_unit.v hazard_detection_unit.v \
branch_predictor.v register_file_module.v

./pipe_sim

gtkwave processor_tb.vcd
```

---

# Verification

The processor was verified through both module-level and integration-level simulations.

### Test Cases

- Fibonacci program execution
- Arithmetic and logical instruction validation
- Shift and comparison operations
- Load and store instructions
- EX→EX forwarding
- MEM→EX forwarding
- Load-use hazard detection
- Branch flushing and control hazards

---

# Performance Comparison

| Metric | Sequential | Pipelined |
|----------|------------|------------|
| Ideal CPI | 1 | ~1 |
| CPI with Hazards | 1 | ~1.1–1.3 |
| Throughput | 1 Instruction/Cycle | ~4–5× Higher |
| Clock Frequency | Lower | Higher |

---

# Technologies Used

- Verilog HDL
- RISC-V RV64I ISA
- Icarus Verilog
- GTKWave

---

# Future Improvements

Potential extensions to the processor include:

- RV64M (Multiply/Divide) instruction support
- Dynamic branch prediction
- Instruction and data caches
- CSR (Control and Status Registers)
- Exception and interrupt handling
- UART-based program loading
- Performance counters

---

# References

- RISC-V Unprivileged ISA Specification
- Patterson & Hennessy – *Computer Organization and Design: RISC-V Edition*
- Icarus Verilog Documentation
- GTKWave Documentation

---

# Authors

- **Het Selarka**
- **Shrenil Patel**
- **Saumya Vira**

**Course:** Introduction to Processor Architecture (IPA)  
**Academic Year:** 2024–2025

---

## License

This project is intended for **educational and academic purposes**. Feel free to use it as a learning resource with appropriate attribution.
