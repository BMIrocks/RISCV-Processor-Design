`timescale 1ns/1ps
`include "alu.v"

module alu_final_tb;

    reg  [63:0] a, b;
    reg  [3:0]  opcode;

    wire [63:0] result;
    wire cout, carry_flag, overflow_flag, zero_flag;

    localparam  ADD_Oper  = 4'b0000,
                SLL_Oper  = 4'b0001,
                SLT_Oper  = 4'b0010,
                SLTU_Oper = 4'b0011,
                XOR_Oper  = 4'b0100,
                SRL_Oper  = 4'b0101,
                OR_Oper   = 4'b0110,
                AND_Oper  = 4'b0111,
                SUB_Oper  = 4'b1000,
                SRA_Oper  = 4'b1101;

    alu_64_bit uut(
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .cout(cout),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    function exp_overflow_add;
        input [63:0] x, y, s;
        begin
            exp_overflow_add = (~(x[63]^y[63])) & (s[63]^x[63]);
        end
    endfunction

    function exp_overflow_sub;
        input [63:0] x, y, s;
        begin
            exp_overflow_sub = (x[63]^y[63]) & (s[63]^x[63]);
        end
    endfunction

    task check_test;
        input [8*50:1] test_name;
        input [3:0] op;
        input [63:0] inp_a, inp_b;
        input [63:0] exp_res;
        input exp_c, exp_o, exp_z;

        begin
            total_tests = total_tests + 1;
            a = inp_a;
            b = inp_b;
            opcode = op;
            #10;

            if (result === exp_res &&
                carry_flag === exp_c &&
                overflow_flag === exp_o &&
                zero_flag === exp_z) begin
                pass_count = pass_count + 1;
                $display("PASS #%0d: %s", total_tests, test_name);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL #%0d: %s", total_tests, test_name);
                $display("Inputs: A=%h, B=%h, OP=%b", inp_a, inp_b, op);
                $display("Expected: RES=%h C=%b O=%b Z=%b", exp_res, exp_c, exp_o, exp_z);
                $display("Got:      RES=%h C=%b O=%b Z=%b", result, carry_flag, overflow_flag, zero_flag);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_final_tb.vcd");
        $dumpvars(0, alu_final_tb);

        $display("ALU COMPREHENSIVE FINAL TESTBENCH");

        check_test("ADD: 0 + 0", ADD_Oper, 64'd0, 64'd0, 64'd0, 1'b0, 1'b0, 1'b1);
        check_test("ADD: 1 + 1", ADD_Oper, 64'd1, 64'd1, 64'd2, 1'b0, 1'b0, 1'b0);
        check_test("ADD: 10 + 20", ADD_Oper, 64'd10, 64'd20, 64'd30, 1'b0, 1'b0, 1'b0);
        check_test("ADD: 100 + 200", ADD_Oper, 64'd100, 64'd200, 64'd300, 1'b0, 1'b0, 1'b0);
        check_test("ADD: MAX + 1", ADD_Oper, 64'hFFFFFFFFFFFFFFFF, 64'd1, 64'd0, 1'b1, 1'b0, 1'b1);
        check_test("ADD: MAX + MAX", ADD_Oper, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFE, 1'b1, 1'b0, 1'b0);
        check_test("ADD: MAX_POS + 1", ADD_Oper, 64'h7FFFFFFFFFFFFFFF, 64'd1, 64'h8000000000000000, 1'b0, 1'b1, 1'b0);
        check_test("ADD: MAX_POS + MAX_POS", ADD_Oper, 64'h7FFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFE, 1'b0, 1'b1, 1'b0);
        check_test("ADD: MIN_NEG + MIN_NEG", ADD_Oper, 64'h8000000000000000, 64'h8000000000000000, 64'd0, 1'b1, 1'b1, 1'b1);

        check_test("SUB: 0 - 0", SUB_Oper, 64'd0, 64'd0, 64'd0, 1'b0, 1'b0, 1'b1);
        check_test("SUB: 20 - 10", SUB_Oper, 64'd20, 64'd10, 64'd10, 1'b0, 1'b0, 1'b0);
        check_test("SUB: MAX_POS - MIN_NEG", SUB_Oper, 64'h7FFFFFFFFFFFFFFF, 64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, 1'b0, 1'b1, 1'b0);
        check_test("SUB: MIN_NEG - MAX_POS", SUB_Oper, 64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF, 64'd1, 1'b1, 1'b1, 1'b0);
        check_test("SUB: 0 - MIN_NEG", SUB_Oper, 64'd0, 64'h8000000000000000, 64'h8000000000000000, 1'b0, 1'b1, 1'b0);

        $display("Total Tests: %0d", total_tests);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        #20 $finish;
    end

endmodule
