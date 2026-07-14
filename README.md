# RISC-V Processor Design

A fully functional **64-bit RISC-V processor** implemented in Verilog, covering both sequential and pipelined architectures. This project was developed as part of an academic computer architecture course and demonstrates a ground-up hardware design flow — from individual ALU components to a complete 5-stage pipelined processor with hazard handling.

---

## 📐 Project Overview

| Feature | Sequential | Pipelined |
|---|---|---|
| Architecture | Single-cycle | 5-Stage Pipeline |
| ISA | RISC-V RV64I | RISC-V RV64I |
| Hazard Handling | N/A | Forwarding + Stalling |
| Branch Prediction | N/A | Static (Not-taken) |
| Simulation Tool | Icarus Verilog | Icarus Verilog |
| Waveform Viewer | GTKWave | GTKWave |

---

## 🗂️ Repository Structure

```
RISC-V-Processor-Design/
├── IPA_RISC_V_SEQ/
│   ├── 2024102044_ALU/          # Standalone 64-bit ALU components
│   │   ├── alu.v                # Top-level ALU
│   │   ├── add_64.v             # 64-bit Adder
│   │   ├── ripple_carry_adder_64.v
│   │   ├── sll_64.v / srl_64.v / sra_64.v  # Shift units
│   │   ├── slt_64.v / sltu_64.v             # Comparison units
│   │   └── tb_*.v               # Unit testbenches
│   └── Sequential_RISC_V_Processor/
│       ├── processor.v          # Top-level sequential processor
│       ├── alu.v                # ALU integrated in datapath
│       ├── control_unit.v       # Main control decoder
│       ├── alu_control.v        # ALU function decoder
│       ├── data_memory.v        # Data memory (load/store)
│       ├── instruction_memory.v # Instruction ROM
│       ├── imm_gen.v            # Immediate generator
│       ├── register_file_module.v
│       ├── program_counter.v
│       ├── seq_tb.v             # Top-level sequential testbench
│       └── tb_*.v               # Module-level testbenches
│
├── Pipelined_Processor/
│   ├── pipelined_processor.v    # Complete 5-stage pipeline
│   ├── forwarding_unit.v        # Data forwarding (EX-EX, MEM-EX)
│   ├── hazard_detection_unit.v  # Load-use stall detection
│   ├── branch_predictor.v       # Static branch predictor
│   ├── register_file_module.v
│   ├── pipe_tb.v                # Pipeline integration testbench
│   └── hazard_tb.v              # Hazard-specific testbench
│
├── gtkwave_demo/
│   ├── GTKWAVE_GUIDE.md         # Step-by-step waveform viewing guide
│   ├── hazard_demo_tb.v         # Interactive hazard demonstration
│   └── run_hazard_demo.ps1      # PowerShell automation script
│
├── hazard_instructions.txt      # Instruction sequences for hazard testing
├── instructions.txt             # Basic instruction encoding reference
├── instructions_exp.txt         # Extended instruction examples
├── register_file.txt            # Register file state snapshots
├── IPA_PROJECT.pdf              # Sequential processor project report
└── IPA_Pipelined_Project_Doc.pdf # Pipelined processor project report
```

---

## 🔧 ALU — Building Block (Phase 1)

The ALU was designed bottom-up using structural Verilog:

- **Full Adder** → **Ripple Carry Adder (64-bit)** → **Add/Sub units**
- Logical ops: AND, OR, XOR (64-bit)
- Shift ops: SLL, SRL, SRA (logical & arithmetic shifts)
- Comparison: SLT, SLTU (signed & unsigned less-than)
- All operations verified with dedicated testbenches (`tb_*.v`)

---

## 🖥️ Sequential RISC-V Processor (Phase 2)

A single-cycle datapath implementing the core RV64I subset:

**Supported Instructions:**
- **R-type**: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`
- **I-type**: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLTIU`, `LW`, `LD`, `JALR`
- **S-type**: `SW`, `SD`
- **B-type**: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- **U-type**: `LUI`, `AUIPC`
- **J-type**: `JAL`

The testbench (`seq_tb.v`) runs a Fibonacci sequence computation to validate correctness.

---

## ⚙️ Pipelined Processor (Phase 3)

A **5-stage pipeline**: IF → ID → EX → MEM → WB

### Hazard Resolution
| Hazard Type | Solution |
|---|---|
| Data Hazard (RAW) | Forwarding Unit (EX→EX, MEM→EX paths) |
| Load-Use Hazard | Hazard Detection Unit (1-cycle stall) |
| Control Hazard | Branch resolved in MEM; flush on misprediction |

### Key Design Decisions
- Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) hold all control + data signals
- Forwarding mux at EX stage selects between register file, EX/MEM, and MEM/WB sources
- Static branch predictor always predicts "not-taken"; pipeline flushes on taken branches

---

## 🚀 Running Simulations

### Prerequisites
```bash
sudo apt install iverilog gtkwave
```

### Sequential Processor
```bash
cd IPA_RISC_V_SEQ/Sequential_RISC_V_Processor
iverilog -o seq_sim seq_tb.v processor.v alu.v control_unit.v alu_control.v \
         data_memory.v instruction_memory.v imm_gen.v register_file_module.v program_counter.v
./seq_sim
gtkwave processor_tb.vcd
```

### Pipelined Processor
```bash
cd Pipelined_Processor
iverilog -o pipe_sim pipe_tb.v pipelined_processor.v forwarding_unit.v \
         hazard_detection_unit.v branch_predictor.v register_file_module.v
./pipe_sim
gtkwave processor_tb.vcd
```

### Hazard Demo
```bash
cd gtkwave_demo
# See GTKWAVE_GUIDE.md for detailed waveform navigation instructions
```

---

## 📊 Performance Comparison

| Metric | Sequential | Pipelined |
|---|---|---|
| CPI (ideal) | 1 | ~1 |
| CPI (with hazards) | 1 | ~1.1–1.3 |
| Clock frequency | Lower | Higher |
| Throughput | 1 instr/cycle | ~4–5× improvement |

---

## 🧪 Verified Test Cases

- Fibonacci sequence (sequential & pipelined)
- Load-use hazard (LW followed by dependent instruction)
- EX-EX forwarding chains
- Branch resolution and pipeline flush
- All R-type/I-type ALU operations

---

## 📚 References

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- Patterson & Hennessy — *Computer Organization and Design: RISC-V Edition*
- Icarus Verilog documentation
- GTKWave User Guide

---

## 👤 Author

**Shrenil** — Computer Architecture, 2024–2025  
Academic project: IPA (Introduction to Processor Architecture)
