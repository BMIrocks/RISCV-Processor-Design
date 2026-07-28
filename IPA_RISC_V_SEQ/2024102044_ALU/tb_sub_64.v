`timescale 1ns/1ps
`include "full_adder.v"
`include "ripple_carry_adder_64.v"
`include "sub_64.v"

module tb_sub_64;
    reg [63:0] a, b;
    wire [63:0] result;
    wire cout, overflow;

    sub_64 uut(
        .a(a),
        .b(b),
        .result(result),
        .cout(cout),
        .overflow(overflow)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [63:0] expected_result;
        input expected_overflow;
        begin
            total_tests = total_tests + 1;
            if (result === expected_result && overflow === expected_overflow) begin
                $display("PASS: Test %0d: a=%h b=%h | result=%h overflow=%b", total_tests, a, b, result, overflow);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Test %0d: a=%h b=%h | result=%h (exp %h) overflow=%b (exp %b)", total_tests, a, b, result, expected_result, overflow, expected_overflow);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_sub_64.vcd");
        $dumpvars(0, tb_sub_64);
        $display("sub_64 Testbench");

        a = 64'h0; b = 64'h0; #10;
        check(64'h0, 1'b0);

        a = 64'd20; b = 64'd10; #10;
        check(64'd10, 1'b0);

        a = 64'd10; b = 64'd20; #10;
        check(64'hFFFFFFFFFFFFFFF6, 1'b0);

        a = 64'h7FFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; #10;
        check(64'h8000000000000000, 1'b1);

        a = 64'h8000000000000000; b = 64'h1; #10;
        check(64'h7FFFFFFFFFFFFFFF, 1'b1);

        a = 64'd100; b = 64'd100; #10;
        check(64'h0, 1'b0);

        $display("Total: %0d  Passed: %0d  Failed: %0d", total_tests, pass_count, fail_count);
        #20 $finish;
    end
endmodule
