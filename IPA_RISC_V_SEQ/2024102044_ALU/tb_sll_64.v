`timescale 1ns/1ps
`include "sll_64.v"

module tb_sll_64;
    reg [63:0] a, b;
    wire [63:0] result;

    sll_64 uut(
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
        $dumpfile("tb_sll_64.vcd");
        $dumpvars(0, tb_sll_64);
        $display("sll_64 Testbench");

        a = 64'h1; b = 64'd0; #10;
        check(64'h1);

        a = 64'h1; b = 64'd1; #10;
        check(64'h2);

        a = 64'h1; b = 64'd4; #10;
        check(64'h10);

        a = 64'h1; b = 64'd32; #10;
        check(64'h100000000);

        a = 64'h1; b = 64'd63; #10;
        check(64'h8000000000000000);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1; #10;
        check(64'hFFFFFFFFFFFFFFFE);

        a = 64'hAAAAAAAAAAAAAAAA; b = 64'd4; #10;
        check(64'hAAAAAAAAAAAAAAA0);

        $display("Total: %0d  Passed: %0d  Failed: %0d", total_tests, pass_count, fail_count);
        #20 $finish;
    end
endmodule
