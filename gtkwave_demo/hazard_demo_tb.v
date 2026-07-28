`timescale 1ns/1ps

`include "../../IPA_RISC_V_SEQ/2024102066_ALU/full_adder.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/ripple_carry_adder_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/add_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/sub_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/and_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/or_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/xor_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/slt_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/sltu_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/sll_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/srl_64.v"
`include "../../IPA_RISC_V_SEQ/2024102066_ALU/sra_64.v"
`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu.v"

`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/program_counter.v"
`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/instruction_memory.v"
`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/control_unit.v"
`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/imm_gen.v"
`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu_control.v"
`include "../../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/data_memory.v"

`include "register_file_module.v"
`include "forwarding_unit.v"
`include "hazard_detection_unit.v"
`include "pipelined_processor.v"

module hazard_demo_tb;

    reg         clk;
    reg         reset;
    wire        halt;
    wire [31:0] cycle_count;

    pipelined_processor DUT (
        .clk         (clk),
        .reset       (reset),
        .halt        (halt),
        .cycle_count (cycle_count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    wire [1:0] forward_A = DUT.ForwardA;
    wire [1:0] forward_B = DUT.ForwardB;
    wire stall_signal = DUT.stall;
    wire flush_signal = DUT.flush;
    wire branch_taken = DUT.branch_taken;

    wire load_use_hazard = stall_signal;
    wire stall_IF = stall_signal;
    wire stall_ID = stall_signal;
    wire flush_ID_EX = stall_signal || flush_signal;
    wire flush_IF_ID = flush_signal;

    reg [3:0] hazard_type;

    wire [4:0] ID_EX_rs1 = DUT.ID_EX_rs1;
    wire [4:0] ID_EX_rs2 = DUT.ID_EX_rs2;
    wire [4:0] EX_MEM_rd = DUT.EX_MEM_rd_wire;
    wire [4:0] MEM_WB_rd = DUT.MEM_WB_rd_wire;

    wire [31:0] IF_ID_instr = DUT.IF_ID_instruction;
    wire [63:0] IF_ID_PC_val = DUT.IF_ID_PC;
    wire [63:0] ID_EX_PC_val = DUT.ID_EX_PC;
    wire [4:0]  ID_EX_rd_val = DUT.ID_EX_rd;

    always @(posedge clk) begin
        if (!reset && cycle_count > 0) begin
            hazard_type = 4'b0000;

            if (forward_A == 2'b10 || forward_B == 2'b10) begin
                hazard_type[0] = 1'b1;
                $display("[Cycle %2d] >>> HAZARD 1: EX DATA HAZARD DETECTED <<<", cycle_count);
                $display("            Forward: A=%b B=%b | EX_MEM_rd=x%0d -> ID_EX rs1=x%0d rs2=x%0d",
                         forward_A, forward_B, EX_MEM_rd, ID_EX_rs1, ID_EX_rs2);
                $display("            Resolution: Forwarding from EX/MEM stage (no stall)");
                $display("");
            end

            if (forward_A == 2'b01 || forward_B == 2'b01) begin
                hazard_type[1] = 1'b1;
                $display("[Cycle %2d] >>> HAZARD 2: MEM DATA HAZARD DETECTED <<<", cycle_count);
                $display("            Forward: A=%b B=%b | MEM_WB_rd=x%0d -> ID_EX rs1=x%0d rs2=x%0d",
                         forward_A, forward_B, MEM_WB_rd, ID_EX_rs1, ID_EX_rs2);
                $display("            Resolution: Forwarding from MEM/WB stage (no stall)");
                $display("");
            end

            if (load_use_hazard) begin
                hazard_type[2] = 1'b1;
                $display("[Cycle %2d] >>> HAZARD 3: LOAD-USE HAZARD DETECTED <<<", cycle_count);
                $display("            Stall: IF=%b ID=%b Flush_ID_EX=%b", stall_IF, stall_ID, flush_ID_EX);
                $display("            Resolution: 1-cycle stall + bubble insertion");
                $display("");
            end

            if (branch_taken && flush_IF_ID) begin
                hazard_type[3] = 1'b1;
                $display("[Cycle %2d] >>> HAZARD 4: CONTROL HAZARD DETECTED <<<", cycle_count);
                $display("            Branch taken! Flush_IF_ID=%b", flush_IF_ID);
                $display("            Resolution: Flush IF/ID stage (2 instructions discarded)");
                $display("");
            end
        end
    end

    always @(posedge clk) begin
        if (!reset && cycle_count > 0 && cycle_count <= 50) begin
            $display("Cycle %2d | PC:%08h | IF/ID:%08h | ID_EX: rd=x%0d rs1=x%0d rs2=x%0d | EX_MEM: rd=x%0d | MEM_WB: rd=x%0d | Haz:%b",
                     cycle_count, DUT.pc, IF_ID_instr, ID_EX_rd_val, ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd, hazard_type);
        end
    end

    integer i;

    initial begin

        $dumpfile("hazard_demo.vcd");
        $dumpvars(0, hazard_demo_tb);

        $dumpvars(1, forward_A);
        $dumpvars(1, forward_B);
        $dumpvars(1, load_use_hazard);
        $dumpvars(1, stall_IF);
        $dumpvars(1, stall_ID);
        $dumpvars(1, flush_ID_EX);
        $dumpvars(1, branch_taken);
        $dumpvars(1, flush_IF_ID);
        $dumpvars(1, hazard_type);

        $display("");
        $display("========================================================================");
        $display("    4-HAZARD DEMONSTRATION TESTBENCH");
        $display("========================================================================");
        $display("");
        $display("This testbench will demonstrate:");
        $display("  1. EX Data Hazard    - Forwarding from EX/MEM (forward = 10)");
        $display("  2. MEM Data Hazard   - Forwarding from MEM/WB (forward = 01)");
        $display("  3. Load-Use Hazard   - Pipeline stall required");
        $display("  4. Control Hazard    - Branch causes flush");
        $display("");
        $display("Watch the following signals in GTKWave:");
        $display("  - forward_A, forward_B: Forwarding control (00=none, 01=MEM, 10=EX)");
        $display("  - load_use_hazard: Load-use detection");
        $display("  - stall_IF, stall_ID, flush_ID_EX: Stall and bubble signals");
        $display("  - branch_taken, flush_IF_ID: Branch control");
        $display("  - hazard_type[3:0]: Which hazards are active");
        $display("========================================================================");
        $display("");

        reset = 1;
        #12;
        reset = 0;

        $display("Starting execution...");
        $display("");

        wait (halt == 1'b1 || cycle_count > 100);

        #20;

        $display("");
        $display("========================================================================");
        $display("    TEST COMPLETED");
        $display("========================================================================");
        $display("Total cycles: %0d", cycle_count);
        $display("");
        $display("Check hazard_demo.vcd with GTKWave:");
        $display("  gtkwave hazard_demo.vcd");
        $display("");
        $display("Key signals to observe:");
        $display("  1. hazard_type[3:0] - Shows which hazard is active");
        $display("  2. forward_A/B - Forwarding control signals");
        $display("  3. stall_IF/ID - Pipeline stall signals");
        $display("  4. load_use_hazard - Load-use detection");
        $display("  5. branch_taken, flush_IF_ID - Control hazard");
        $display("========================================================================");
        $display("");

        $finish;
    end

    initial begin
        #500000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
