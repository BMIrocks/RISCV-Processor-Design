`timescale 1ns/1ps
`include "alu_control.v"

module tb_alu_control;

    reg [1:0] alu_op;
    reg [2:0] funct3;
    reg funct7_bit5;
    wire [3:0] alu_opcode;

    alu_control uut (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_bit5(funct7_bit5),
        .alu_opcode(alu_opcode)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [255:0] test_name;
        input [3:0] actual;
        input [3:0] expected;
        begin
            total_tests = total_tests + 1;
            if (actual === expected) begin
                $display("PASS: %0s | Expected: %04b, Got: %04b", test_name, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s | Expected: %04b, Got: %04b", test_name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_alu_control.vcd");
        $dumpvars(0, tb_alu_control);
        $display("=== alu_control Testbench ===");

        alu_op = 2'b00; funct3 = 3'b000; funct7_bit5 = 0;
        #10;
        check("alu_op=00 -> ADD (0000)", alu_opcode, 4'b0000);

        alu_op = 2'b00; funct3 = 3'b111; funct7_bit5 = 1;
        #10;
        check("alu_op=00 ignores funct fields -> ADD (0000)", alu_opcode, 4'b0000);

        alu_op = 2'b01; funct3 = 3'b000; funct7_bit5 = 0;
        #10;
        check("alu_op=01 -> SUB (1000)", alu_opcode, 4'b1000);

        alu_op = 2'b01; funct3 = 3'b101; funct7_bit5 = 1;
        #10;
        check("alu_op=01 ignores funct fields -> SUB (1000)", alu_opcode, 4'b1000);

        alu_op = 2'b10; funct3 = 3'b000; funct7_bit5 = 0;
        #10;
        check("R-type ADD: f3=000 f7b5=0 -> 0000", alu_opcode, 4'b0000);

        alu_op = 2'b10; funct3 = 3'b000; funct7_bit5 = 1;
        #10;
        check("R-type SUB: f3=000 f7b5=1 -> 1000", alu_opcode, 4'b1000);

        alu_op = 2'b10; funct3 = 3'b001; funct7_bit5 = 0;
        #10;
        check("R-type SLL: f3=001 -> 0001", alu_opcode, 4'b0001);

        alu_op = 2'b10; funct3 = 3'b010; funct7_bit5 = 0;
        #10;
        check("R-type SLT: f3=010 -> 0010", alu_opcode, 4'b0010);

        alu_op = 2'b10; funct3 = 3'b011; funct7_bit5 = 0;
        #10;
        check("R-type SLTU: f3=011 -> 0011", alu_opcode, 4'b0011);

        alu_op = 2'b10; funct3 = 3'b100; funct7_bit5 = 0;
        #10;
        check("R-type XOR: f3=100 -> 0100", alu_opcode, 4'b0100);

        alu_op = 2'b10; funct3 = 3'b101; funct7_bit5 = 0;
        #10;
        check("R-type SRL: f3=101 f7b5=0 -> 0101", alu_opcode, 4'b0101);

        alu_op = 2'b10; funct3 = 3'b101; funct7_bit5 = 1;
        #10;
        check("R-type SRA: f3=101 f7b5=1 -> 1101", alu_opcode, 4'b1101);

        alu_op = 2'b10; funct3 = 3'b110; funct7_bit5 = 0;
        #10;
        check("R-type OR: f3=110 -> 0110", alu_opcode, 4'b0110);

        alu_op = 2'b10; funct3 = 3'b111; funct7_bit5 = 0;
        #10;
        check("R-type AND: f3=111 -> 0111", alu_opcode, 4'b0111);

        alu_op = 2'b11; funct3 = 3'b000; funct7_bit5 = 0;
        #10;
        check("alu_op=11 default -> 0000", alu_opcode, 4'b0000);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
