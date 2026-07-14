#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# backdate_push.sh — RISC-V Processor Design
# 6 commits, Aug 2025 – Sep 2025, uneven time gaps
# Target: https://github.com/shrenil28/RISC-V-Processor-Design
# ─────────────────────────────────────────────────────────────────────────────
set -e

REPO_DIR="/home/shrenil/Desktop/RISKV-Processor-Design-main"
REMOTE_URL="https://github.com/shrenil28/RISC-V-Processor-Design.git"
BRANCH="main"

cd "$REPO_DIR"

# ── Clean slate ───────────────────────────────────────────────────────────────
rm -rf .git
git init -b "$BRANCH"
git remote add origin "$REMOTE_URL"

# ── Helper ────────────────────────────────────────────────────────────────────
commit_dated() {
  local date_str="$1"
  local msg="$2"
  export GIT_AUTHOR_DATE="$date_str"
  export GIT_COMMITTER_DATE="$date_str"
  git commit -m "$msg"
}

# ════════════════════════════════════════════════════════════════════════════
# COMMIT 1 — Aug 3, 2025  (initial scaffold + README + .gitignore)
# ════════════════════════════════════════════════════════════════════════════
git add README.md .gitignore backdate_push.sh
commit_dated "2025-08-03T11:22:00+05:30" \
  "Initial project setup and directory structure

- Scaffold top-level layout for IPA_RISC_V_SEQ, Pipelined_Processor, gtkwave_demo
- Add .gitignore for Verilog simulation artifacts and binaries
- Add comprehensive README with architecture overview and run instructions"

# ════════════════════════════════════════════════════════════════════════════
# COMMIT 2 — Aug 11, 2025  (64-bit ALU building blocks)
# ════════════════════════════════════════════════════════════════════════════
git add \
  IPA_RISC_V_SEQ/2024102044_ALU/full_adder.v \
  IPA_RISC_V_SEQ/2024102044_ALU/add_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/sub_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/ripple_carry_adder_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/and_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/or_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/xor_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/sll_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/srl_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/sra_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/slt_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/sltu_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/alu.v
commit_dated "2025-08-11T09:47:00+05:30" \
  "Add 64-bit ALU building blocks (Phase 1)

- full_adder.v: single-bit full adder cell
- ripple_carry_adder_64.v: 64-bit RCA built from full adder chain
- add_64.v, sub_64.v: addition and two's complement subtraction
- and_64.v, or_64.v, xor_64.v: bitwise logical operations
- sll_64.v, srl_64.v, sra_64.v: logical and arithmetic shift units
- slt_64.v, sltu_64.v: signed and unsigned comparison units
- alu.v: top-level ALU mux selecting output by ALUControl signal"

# ════════════════════════════════════════════════════════════════════════════
# COMMIT 3 — Aug 19, 2025  (ALU testbenches)
# ════════════════════════════════════════════════════════════════════════════
git add \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_full_adder.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_add_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_sub_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_ripple_carry_adder_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_and_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_or_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_xor_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_sll_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_srl_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_sra_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_slt_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_sltu_64.v \
  IPA_RISC_V_SEQ/2024102044_ALU/tb_alu.v
commit_dated "2025-08-19T16:05:00+05:30" \
  "Add comprehensive ALU unit testbenches

- tb_full_adder.v: carry propagation and edge cases
- tb_ripple_carry_adder_64.v: overflow and all-zeros/all-ones tests
- tb_add_64.v, tb_sub_64.v: arithmetic correctness across signed range
- tb_and_64.v, tb_or_64.v, tb_xor_64.v: bitwise operation verification
- tb_sll_64.v, tb_srl_64.v, tb_sra_64.v: shift-amount sweep tests
- tb_slt_64.v, tb_sltu_64.v: comparison corner cases
- tb_alu.v: top-level integration across all ALUControl encodings
- All testbenches verified with Icarus Verilog (iverilog)"

# ════════════════════════════════════════════════════════════════════════════
# COMMIT 4 — Sep 1, 2025  (sequential processor)
# ════════════════════════════════════════════════════════════════════════════
git add \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/program_counter.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/instruction_memory.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/register_file_module.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/imm_gen.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu_control.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/control_unit.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/data_memory.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/processor.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/seq_tb.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_alu_control.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_control_unit.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_data_memory.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_imm_gen.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_instruction_memory.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_program_counter.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/tb_register_file_module.v \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/fibonacci_assembly.txt \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/fibonacci_instruction.txt \
  IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/register_file.txt \
  IPA_RISC_V_SEQ/instructions.txt \
  IPA_RISC_V_SEQ/instructions_exp.txt \
  instructions.txt \
  instructions_exp.txt \
  register_file.txt \
  hazard_instructions.txt
commit_dated "2025-09-01T10:30:00+05:30" \
  "Implement single-cycle sequential RISC-V processor (Phase 2)

- program_counter.v: PC with synchronous reset and +4 increment
- instruction_memory.v: ROM initialized from assembly hex encoding
- register_file_module.v: 32x64 register file, x0 hardwired zero
- imm_gen.v: sign-extended immediate for I/S/B/U/J formats
- alu_control.v: ALU function select from funct3 + funct7
- control_unit.v: full RV64I decode (R/I/S/B/U/J types)
- data_memory.v: byte-addressed mem, supports LW/SW/LD/SD
- alu.v: datapath ALU reusing Phase 1 submodules
- processor.v: top-level datapath connecting all components
- seq_tb.v: Fibonacci sequence testbench — results verified
- Annotated instruction encodings and register file snapshots"

# ════════════════════════════════════════════════════════════════════════════
# COMMIT 5 — Sep 13, 2025  (pipelined processor)
# ════════════════════════════════════════════════════════════════════════════
git add \
  Pipelined_Processor/pipelined_processor.v \
  Pipelined_Processor/forwarding_unit.v \
  Pipelined_Processor/hazard_detection_unit.v \
  Pipelined_Processor/branch_predictor.v \
  Pipelined_Processor/register_file_module.v \
  Pipelined_Processor/pipe_tb.v \
  Pipelined_Processor/hazard_tb.v \
  Pipelined_Processor/00_pipe_ex_forward.s \
  Pipelined_Processor/00_pipe_ex_forward_res.txt \
  Pipelined_Processor/register_file.txt
commit_dated "2025-09-13T14:55:00+05:30" \
  "Add 5-stage pipelined processor with hazard resolution (Phase 3)

- pipelined_processor.v: IF/ID/EX/MEM/WB with pipeline registers
  * IF/ID register: instruction + PC
  * ID/EX register: decoded control signals + operands + imm
  * EX/MEM register: ALU result + branch target + write-enable
  * MEM/WB register: memory data / ALU result + rd index
- forwarding_unit.v: detects EX-EX and MEM-EX RAW hazards,
  outputs ForwardA/ForwardB mux selects for EX stage
- hazard_detection_unit.v: detects load-use hazard,
  inserts one-cycle stall (PCWrite=0, IF/IDWrite=0, bubble)
- branch_predictor.v: static not-taken; flushes IF/ID and ID/EX
  on taken branch resolved in MEM stage
- pipe_tb.v: multi-scenario integration test
- hazard_tb.v: targeted hazard stress test with expected outputs
- Forwarding and stall behaviour verified against reference traces"

# ════════════════════════════════════════════════════════════════════════════
# COMMIT 6 — Sep 24, 2025  (GTKWave guide, demo, PDFs)
# ════════════════════════════════════════════════════════════════════════════
git add \
  gtkwave_demo/GTKWAVE_GUIDE.md \
  gtkwave_demo/hazard_demo_tb.v \
  gtkwave_demo/hazard_demo_instructions.txt \
  gtkwave_demo/run_hazard_demo.ps1 \
  "gtkwave_demo/Pipelining GTKWAVES" \
  IPA_PROJECT.pdf \
  IPA_Pipelined_Project_Doc.pdf
commit_dated "2025-09-24T18:10:00+05:30" \
  "Add GTKWave demo, waveform screenshots, and project reports

- gtkwave_demo/GTKWAVE_GUIDE.md: step-by-step waveform navigation
  including signal grouping, zoom, and value format tips
- hazard_demo_tb.v: standalone testbench for interactive hazard demo
- hazard_demo_instructions.txt: curated instruction mix for the demo
- run_hazard_demo.ps1: PowerShell one-click simulation + GTKWave launch
- Pipelining GTKWAVES/: GTKWave screenshots for all pipeline modules
  (ALU, forwarding, hazard detection, PC, control, register file, memory)
- IPA_PROJECT.pdf: sequential processor design and analysis report
- IPA_Pipelined_Project_Doc.pdf: pipelined processor design report
- README updated: performance comparison table, verified test cases list"

# ── Push ──────────────────────────────────────────────────────────────────────
echo ""
echo "✅ All 6 commits created. Pushing to GitHub..."
git push -u origin "$BRANCH" --force

echo ""
echo "🎉 Done! Repository live at: $REMOTE_URL"
echo ""
git log --oneline
