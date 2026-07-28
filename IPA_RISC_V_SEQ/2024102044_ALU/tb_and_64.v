`timescale 1ns/1ps
`include "and_64.v"

module tb_and_64;
    reg [63:0] a, b;
    wire [63:0] result;

    and_64 uut(
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
        $dumpfile("tb_and_64.vcd");
        $dumpvars(0, tb_and_64);
        $display("and_64 Testbench");

        a = 64'h0; b = 64'h0; #10;
        check(64'h0);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; #10;
        check(64'hFFFFFFFFFFFFFFFF);

        a = 64'hFF00FF00FF00FF00; b = 64'h00FF00FF00FF00FF; #10;
        check(64'h0);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0; #10;
        check(64'h0);

        a = 64'hAAAAAAAAAAAAAAAA; b = 64'hFFFFFFFFFFFFFFFF; #10;
        check(64'hAAAAAAAAAAAAAAAA);

        a = 64'h123456789ABCDEF0; b = 64'hF0F0F0F0F0F0F0F0; #10;
        check(64'h1030507090B0D0F0);

        $display("Total: %0d  Passed: %0d  Failed: %0d", total_tests, pass_count, fail_count);
        #20 $finish;
    end
endmodule
