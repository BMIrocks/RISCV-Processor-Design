`timescale 1ns/1ps
`include "control_unit.v"

module tb_control_unit;

    reg [6:0] opcode;
    wire reg_write;
    wire alu_src;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire branch;
    wire [1:0] alu_op;

    control_unit uut (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_op(alu_op)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [255:0] test_name;
        input [7:0] actual;
        input [7:0] expected;
        begin
            total_tests = total_tests + 1;
            if (actual === expected) begin
                $display("PASS: %0s | Expected: %0b, Got: %0b", test_name, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s | Expected: %0b, Got: %0b", test_name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    wire [7:0] signals = {reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op};

    initial begin
        $dumpfile("tb_control_unit.vcd");
        $dumpvars(0, tb_control_unit);
        $display("=== control_unit Testbench ===");
        $display("Signal order: reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op[1:0]");

        opcode = 7'b0110011;
        #10;
        check("R-type (0110011)", signals, 8'b10000010);

        opcode = 7'b0010011;
        #10;
        check("I-type (0010011)", signals, 8'b11000010);

        opcode = 7'b0000011;
        #10;
        check("Load (0000011)", signals, 8'b11101000);

        opcode = 7'b0100011;
        #10;
        check("Store (0100011)", signals, 8'b01010000);

        opcode = 7'b1100011;
        #10;
        check("Branch (1100011)", signals, 8'b00000101);

        opcode = 7'b1111111;
        #10;
        check("Default (1111111)", signals, 8'b00000000);

        opcode = 7'b0000000;
        #10;
        check("Default (0000000)", signals, 8'b00000000);

        opcode = 7'b1010101;
        #10;
        check("Default (1010101)", signals, 8'b00000000);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
