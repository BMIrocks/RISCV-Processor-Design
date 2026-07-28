# GTKWave Professional Layout Guide
## How to Read and Understand the Waveform Display

---

## 🎨 Waveform Layout Structure

The GTKWave display is organized into **5 main pipeline stages** plus **hazard detection signals**, mirroring the actual processor pipeline:

```
┌─────────────────────────────────────────────┐
│ 1. Fetch_Cycle      (IF Stage)             │
├─────────────────────────────────────────────┤
│ 2. Decode_Cycle     (ID Stage)             │
├─────────────────────────────────────────────┤
│ 3. Execute_Cycle    (EX Stage)             │
├─────────────────────────────────────────────┤
│ 4. Memory           (MEM Stage)            │
├─────────────────────────────────────────────┤
│ 5. Register_Writeback (WB Stage)           │
├─────────────────────────────────────────────┤
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│ 🔴 HAZARD INDICATORS                        │
│ 🟢 FORWARDING UNIT                          │
│ 🔵 STALL & FLUSH CONTROL                    │
│ 📊 REGISTER FILE (Selected)                │
└─────────────────────────────────────────────┘
```

---

## 📖 Reading Each Pipeline Stage

### 1️⃣ **Fetch_Cycle** (Instruction Fetch)

**Purpose:** Fetch instruction from memory and calculate next PC

**Key Signals:**
- **PC[31:0]** - Current program counter (instruction address)
- **Instr[31:0]** - Fetched instruction (32-bit machine code)
- **PCTarget[31:0]** - Branch target address
- **PCSrc** - PC source selector (0=PC+4, 1=branch target)

**What to Look For:**
- ✅ PC increments by 4 each cycle (sequential execution)
- ⚠️ PC jumps to different address (branch taken)
- 🔴 PC stays same (stall - load-use hazard)

---

### 2️⃣ **Decode_Cycle** (Instruction Decode & Register Read)

**Purpose:** Decode instruction, read registers, generate control signals

**Key Signals:**
- **RD1_E[31:0]** - Register read data 1 (rs1 value)
- **RD2_E[31:0]** - Register read data 2 (rs2 value)
- **Imm_Ext_E[31:0]** - Sign-extended immediate value
- **ALUControl[2:0]** - ALU operation selector
- **ALUSrcE** - ALU source B (0=register, 1=immediate)
- **BranchE** - Branch instruction flag
- **MemWrite** - Memory write enable
- **RegWriteE** - Register write enable
- **ResultSrcE** - Result source (0=ALU, 1=Memory)

**What to Look For:**
- 📊 RD1_E and RD2_E show values being read from register file
- ⚠️ If hazard exists, these may need forwarding (old values)
- 🔧 Control signals determine instruction type

---

### 3️⃣ **Execute_Cycle** (ALU Execution)

**Purpose:** Perform ALU operations and branch calculations

**Key Signals:**
- **ALU_ResultM[31:0]** - ALU output (result of computation)
- **WriteDataM[31:0]** - Data to be written to memory (for stores)
- **RD_M[4:0]** - Destination register number
- **MemWriteM** - Memory write enable (store instruction)
- **RegWriteM** - Register write enable

**What to Look For:**
- 🟢 **EX Hazard:** ALU_ResultM is forwarded back to EX stage
- ⏸️ If load-use hazard, this stage shows bubble (zeros)
- 💡 ALU result determines if branch is taken

---

### 4️⃣ **Memory** (Data Memory Access)

**Purpose:** Read from or write to data memory

**Key Signals:**
- **ALU_ResultW[31:0]** - ALU result from previous stage (or memory address)
- **ReadDataW[31:0]** - Data read from memory (for loads)
- **ResultSrcW** - Select between ALU result or memory data

**What to Look For:**
- 📥 **Load instructions:** ReadDataW shows value from memory
- 📤 **Store instructions:** Data written to memory
- 🟡 **MEM Hazard:** ALU_ResultW forwarded to EX stage

---

### 5️⃣ **Register_Writeback** (Write Back to Register File)

**Purpose:** Write final result back to register file

**Key Signals:**
- **RegWriteW** - Register write enable (1=write happening)
- **RW[4:0]** - Destination register number being written
- **ResultW[31:0]** - Final value being written to register

**What to Look For:**
- ✍️ When RegWriteW=1, register RW is being updated
- 🔄 This is the final stage - no more hazards after this
- 📝 Values appear in register file this cycle

---

## 🚨 Hazard Detection Signals (Bottom Section)

### 🔴 **HAZARD INDICATORS**

**HazardType[3:0]** - 4-bit indicator showing active hazards:
- **Bit[0]** - EX Data Hazard (forward_A/B = 10)
- **Bit[1]** - MEM Data Hazard (forward_A/B = 01)
- **Bit[2]** - Load-Use Hazard (stall required)
- **Bit[3]** - Control Hazard (branch taken)

**Color Coding:**
- 🟥 Red pulse = Hazard detected and being handled

---

### 🟢 **FORWARDING UNIT**

**ForwardA[1:0] / ForwardB[1:0]** - Forwarding control signals:
- **00** = No forwarding (use register file value)
- **01** = Forward from MEM stage (MEM/WB register)
- **10** = Forward from EX stage (EX/MEM register)

**Register Tracking:**
- **ID_EX_rs1/rs2** - Source registers in EX stage
- **EX_MEM_rd** - Destination register in MEM stage
- **MEM_WB_rd** - Destination register in WB stage

**How to Read:**
1. Compare rs1/rs2 with EX_MEM_rd
   - If match → ForwardA or ForwardB = 10 (EX hazard)
2. Compare rs1/rs2 with MEM_WB_rd
   - If match → ForwardA or ForwardB = 01 (MEM hazard)

---

### 🔵 **STALL & FLUSH CONTROL**

**Stall Signals:**
- **Stall** - Master stall signal (1=pipeline frozen)
- **StallIF** - Freeze IF stage (PC doesn't advance)
- **StallID** - Freeze ID stage (don't decode new instruction)

**Flush Signals:**
- **Flush** - Master flush signal (1=discard instruction)
- **FlushID_EX** - Insert bubble in EX stage (load-use)
- **FlushIF_ID** - Discard IF/ID stage (branch taken)

**Branch Control:**
- **BranchTaken** - Branch condition satisfied (1=take branch)

**When Stall=1:**
- PC freezes (same value)
- IF/ID register holds same instruction
- Bubble inserted in EX stage

**When Flush=1:**
- Instructions in IF/ID discarded
- PC jumps to branch target
- Pipeline restarted from new address

---

### 📊 **REGISTER FILE (Selected)**

Shows values of key registers used in hazard tests:
- **x1, x2, x3** - Initial test values (10, 20, 5)
- **x4, x5** - EX hazard test results
- **x6, x7** - MEM hazard test results
- **x8, x9, x10, x11** - Load-use hazard test results
- **x15** - Branch target result

---

## 🔍 How to Identify Each Hazard Type

### 🟥 **EX Data Hazard (Cycle 7)**

```
Timeline: Cycle 6-7
├─ Cycle 6: add x4, x1, x2  (x4 in EX stage)
└─ Cycle 7: add x5, x4, x3  (needs x4 immediately)

Look for:
✅ ForwardA = 10 (binary)
✅ EX_MEM_rd = 4 (x4)
✅ ID_EX_rs1 = 4 (x4)
✅ Stall = 0 (no stall needed)
✅ HazardType[0] = 1
```

---

### 🟡 **MEM Data Hazard (Cycle 10)**

```
Timeline: Cycle 8-10
├─ Cycle 8: add x6, x1, x2  (x6 in EX)
├─ Cycle 9: nop             (x6 in MEM)
└─ Cycle 10: add x7, x6, x3 (needs x6)

Look for:
✅ ForwardA = 01 (binary)
✅ MEM_WB_rd = 6 (x6)
✅ ID_EX_rs1 = 6 (x6)
✅ Stall = 0 (no stall needed)
✅ HazardType[1] = 1
```

---

### 🔵 **Load-Use Hazard (Cycle 12-13)**

```
Timeline: Cycle 11-13
├─ Cycle 11: ld x8, 0(x0)      (load - data in MEM)
├─ Cycle 12: add x9, x8, x2    (needs x8 - NOT READY!)
│            ↓ STALL INSERTED
└─ Cycle 13: add x9, x8, x2    (retry with forward)

Look for:
✅ Stall = 1 (Cycle 12)
✅ StallIF = 1, StallID = 1
✅ FlushID_EX = 1 (bubble)
✅ PC stays same (Cycle 12 → 13)
✅ IF/ID_instruction same
✅ Then ForwardA = 01 (forward from MEM)
✅ HazardType[2] = 1
```

---

### 🟣 **Control Hazard (Cycle 19)**

```
Timeline: Cycle 18-21
├─ Cycle 18: addi x12, x0, 100 (before branch)
├─ Cycle 19: beq x1, x1, 12    (branch taken!)
│            ↓ FLUSH IF/ID
├─ Cycle 20: (flushed)
└─ Cycle 21: addi x15, x0, 77  (branch target)

Look for:
✅ BranchTaken = 1
✅ Flush = 1
✅ FlushIF_ID = 1
✅ PC jumps (19 → different address)
✅ Next instructions discarded
✅ HazardType[3] = 1
```

---

## 💡 **Pro Tips for Waveform Analysis**

### 1. **Use Markers**
   - Right-click on time axis → Add Marker
   - Place markers at cycles: 7, 10, 12, 16, 19
   - Label them: "EX Hazard", "MEM Hazard", etc.

### 2. **Zoom to Hazard Events**
   - Select time range around hazard
   - Click "Zoom Fit" or use scroll wheel
   - See exact signal transitions

### 3. **Compare Signals Vertically**
   - Stack related signals (e.g., rs1, EX_MEM_rd, ForwardA)
   - Look for matching register numbers → hazard!

### 4. **Follow Data Flow**
   - Trace a value through pipeline stages
   - Example: x4 created in EX → used in next cycle

### 5. **Watch for Anomalies**
   - PC not incrementing = stall
   - All signals zero in stage = bubble/flush
   - Sudden PC jump = branch

### 6. **Use Color Coding**
   - Hazard signals highlighted in red/yellow
   - Stall signals in orange
   - Branch signals in purple

---

## 📚 **Quick Reference: Signal Meanings**

| Signal Pattern | Meaning |
|----------------|---------|
| PC increments by 4 | Normal sequential execution |
| PC stays same | Pipeline stall (load-use) |
| PC jumps | Branch taken |
| ForwardA/B = 10 | EX stage forwarding |
| ForwardA/B = 01 | MEM stage forwarding |
| Stall = 1 | Pipeline frozen for 1 cycle |
| Flush = 1 | Instruction discarded |
| All zeros in stage | Bubble (NOP) in pipeline |
| HazardType ≠ 0 | Hazard detected |

---

## 🎓 **Learning Exercise**

Try to answer these questions while viewing the waveform:

1. **At Cycle 7:** Why doesn't the EX hazard cause a stall?
2. **At Cycle 12:** Why can't forwarding alone solve the load-use hazard?
3. **At Cycle 19:** How many instructions are discarded when the branch is taken?
4. **Compare Cycles 7 and 10:** What's the difference between EX and MEM forwarding?

---

**Now open GTKWave and explore! 🚀**

```powershell
gtkwave hazard_demo.vcd hazard_demo.gtkw
```
