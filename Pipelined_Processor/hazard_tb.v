`timescale 1ns/1ps

`include "../IPA_RISC_V_SEQ/2024102066_ALU/full_adder.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/ripple_carry_adder_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/add_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sub_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/and_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/or_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/xor_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/slt_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sltu_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sll_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/srl_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sra_64.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu.v"

`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/program_counter.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/instruction_memory.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/control_unit.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/imm_gen.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu_control.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/data_memory.v"

`include "register_file_module.v"
`include "forwarding_unit.v"
`include "hazard_detection_unit.v"
`include "branch_predictor.v"
`include "pipelined_processor.v"

module hazard_tb;

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

    reg [63:0] expected [0:31];
    initial begin
        expected[ 0] = 64'd0;
        expected[ 1] = 64'd5;
        expected[ 2] = 64'd10;
        expected[ 3] = 64'd15;
        expected[ 4] = 64'd15;
        expected[ 5] = 64'd20;
        expected[ 6] = 64'd15;
        expected[ 7] = 64'd20;
        expected[ 8] = 64'd15;
        expected[ 9] = 64'd20;
        expected[10] = 64'd15;
        expected[11] = 64'd20;
        expected[12] = 64'd3;
        expected[13] = 64'd8;
        expected[14] = 64'd5;
        expected[15] = 64'd15;
        expected[16] = 64'd5;
        expected[17] = 64'd15;
        expected[18] = 64'd25;
        expected[19] = 64'd25;
        expected[20] = 64'd5;
        expected[21] = 64'd5;
        expected[22] = 64'd42;
        expected[23] = 64'd0;
        expected[24] = 64'd77;
        expected[25] = 64'd3;
        expected[26] = 64'd0;
        expected[27] = 64'd0;
        expected[28] = 64'd0;
        expected[29] = 64'd0;
        expected[30] = 64'd0;
        expected[31] = 64'd0;
    end

    integer pass_count;
    integer fail_count;
    integer i;
    integer fd;

    task check_reg;
        input [4:0]  reg_num;
        input [63:0] exp_val;
        input [255:0] test_name;
        reg [63:0] actual;
        begin
            actual = DUT.REG_FILE.registers[reg_num];
            if (actual === exp_val) begin
                $display("  [PASS] x%-2d = %0d  (%s)", reg_num, actual, test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] x%-2d = %0d, expected %0d  (%s)",
                         reg_num, actual, exp_val, test_name);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, hazard_tb);

        pass_count = 0;
        fail_count = 0;

        reset = 1;
        #12;
        reset = 0;

        wait (halt == 1'b1);
        @(posedge clk);

        $display("");
        $display("================================================================");
        $display("  COMPREHENSIVE HAZARD TEST RESULTS");
        $display("================================================================");

        $display("");
        $display("--- Setup Registers ---");
        check_reg( 1, 64'd5,   "Setup: x1 = 5                 ");
        check_reg( 2, 64'd10,  "Setup: x2 = 10                ");
        check_reg( 3, 64'd15,  "Setup: x3 = 15                ");

        $display("");
        $display("--- TEST 1: EX Hazard on rs1 (ForwardA=10, I->I+1) ---");
        check_reg( 4, 64'd15,  "add x4=x1+x2=15               ");
        check_reg( 5, 64'd20,  "add x5=x4+x1=20 [FwdA from EX]");

        $display("");
        $display("--- TEST 2: EX Hazard on rs2 (ForwardB=10, I->I+1) ---");
        check_reg( 6, 64'd15,  "add x6=x1+x2=15               ");
        check_reg( 7, 64'd20,  "add x7=x1+x6=20 [FwdB from EX]");

        $display("");
        $display("--- TEST 3: MEM Hazard on rs1 (ForwardA=01, I->I+2) ---");
        check_reg( 8, 64'd15,  "add x8=x1+x2=15               ");
        check_reg( 9, 64'd20,  "add x9=x8+x1=20 [FwdA from WB]");

        $display("");
        $display("--- TEST 4: MEM Hazard on rs2 (ForwardB=01, I->I+2) ---");
        check_reg(10, 64'd15,  "add x10=x1+x2=15              ");
        check_reg(11, 64'd20,  "add x11=x1+x10=20[FwdB from WB]");

        $display("");
        $display("--- TEST 5: Double Data Hazard (EX priority over MEM) ---");
        check_reg(12, 64'd3,   "addi x12=1, then x12=x12+2=3  ");
        check_reg(13, 64'd8,   "add x13=x12+x1=3+5=8 [EX wins]");

        $display("");
        $display("--- TEST 6: Store to memory (sd x1 -> mem[0]=5) ---");
        $display("  [INFO] Verified via load tests below");

        $display("");
        $display("--- TEST 7: Load-Use on rs1 (Stall + ForwardA=01) ---");
        check_reg(14, 64'd5,   "ld x14=mem[0]=5               ");
        check_reg(15, 64'd15,  "add x15=x14+x2=15 [stall+fwd] ");

        $display("");
        $display("--- TEST 8: Load-Use on rs2 (Stall + ForwardB=01) ---");
        check_reg(16, 64'd5,   "ld x16=mem[0]=5               ");
        check_reg(17, 64'd15,  "add x17=x2+x16=15 [stall+fwd] ");

        $display("");
        $display("--- TEST 9: Store After ALU (add->sd, ForwardB=10) ---");
        check_reg(18, 64'd25,  "addi x18=25                   ");
        check_reg(19, 64'd25,  "ld x19=mem[8]=25 [verify store]");

        $display("");
        $display("--- TEST 10: Store After Load (ld->sd, MEM-to-MEM Fwd) ---");
        check_reg(20, 64'd5,   "ld x20=mem[0]=5               ");
        check_reg(21, 64'd5,   "ld x21=mem[16]=5 [verify store]");

        $display("");
        $display("--- TEST 11: Branch NOT Taken ---");
        check_reg(22, 64'd42,  "addi x22=42 [should execute]  ");

        $display("");
        $display("--- TEST 12: Branch TAKEN (skip next instruction) ---");
        check_reg(23, 64'd0,   "addi x23=99 [SKIPPED, stays 0]");
        check_reg(24, 64'd77,  "addi x24=77 [branch target]   ");

        $display("");
        $display("--- TEST 13: No Hazard (3+ instruction gap) ---");
        check_reg(25, 64'd3,   "addi x25=3                    ");
        check_reg(26, 64'd0,   "add x26=x25+x1=0 [no fwd]    ");

        $display("");
        $display("================================================================");
        $display("  CYCLE COUNT");
        $display("================================================================");
        $display("  Total cycles: %0d", cycle_count);

        $display("");
        $display("================================================================");
        $display("  SUMMARY: %0d PASSED, %0d FAILED out of %0d tests",
                 pass_count, fail_count, pass_count + fail_count);
        $display("================================================================");

        if (fail_count == 0)
            $display("  >>> ALL TESTS PASSED <<<");
        else
            $display("  >>> SOME TESTS FAILED <<<");
        $display("");

        fd = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1) begin
            $fwrite(fd, "%h\n", DUT.REG_FILE.registers[i]);
        end
        $fwrite(fd, "%0d\n", cycle_count);
        $fclose(fd);

        #20 $finish;
    end

endmodule
