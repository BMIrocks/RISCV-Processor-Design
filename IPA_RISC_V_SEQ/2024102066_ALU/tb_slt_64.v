`timescale 1ns/1ps
`include "full_adder.v"
`include "ripple_carry_adder_64.v"
`include "sub_64.v"
`include "slt_64.v"

module tb_slt_64;
    reg [63:0] a, b;
    wire [63:0] result;

    slt_64 uut(
        .a(a),
        .b(b),
        .result(result)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [63:0] expected;
        begin
            total_tests = total_tests + 1;
            if (result === expected) begin
                $display("PASS: Test %0d: a=%h b=%h | result=%h", total_tests, a, b, result);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Test %0d: a=%h b=%h | result=%h (exp %h)", total_tests, a, b, result, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_slt_64.vcd");
        $dumpvars(0, tb_slt_64);
        $display("slt_64 Testbench");

        a = 64'd5; b = 64'd10; #10;
        check(64'd1);

        a = 64'd10; b = 64'd5; #10;
        check(64'd0);

        a = 64'd5; b = 64'd5; #10;
        check(64'd0);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1; #10;
        check(64'd1);

        a = 64'd1; b = 64'hFFFFFFFFFFFFFFFF; #10;
        check(64'd0);

        a = 64'hFFFFFFFFFFFFFFF6; b = 64'hFFFFFFFFFFFFFFFB; #10;
        check(64'd1);

        a = 64'h8000000000000000; b = 64'h7FFFFFFFFFFFFFFF; #10;
        check(64'd1);

        a = 64'h7FFFFFFFFFFFFFFF; b = 64'h8000000000000000; #10;
        check(64'd0);

        $display("Total: %0d  Passed: %0d  Failed: %0d", total_tests, pass_count, fail_count);
        #20 $finish;
    end
endmodule
