`timescale 1ns/1ps
`include "full_adder.v"
`include "ripple_carry_adder_64.v"

module tb_ripple_carry_adder_64;
    reg [63:0] a, b;
    reg cin;
    wire [63:0] sum;
    wire cout;

    ripple_carry_adder_64 uut(
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [63:0] expected_sum;
        input expected_cout;
        begin
            total_tests = total_tests + 1;
            if (sum === expected_sum && cout === expected_cout) begin
                $display("PASS: Test %0d: a=%h b=%h cin=%b | sum=%h cout=%b", total_tests, a, b, cin, sum, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Test %0d: a=%h b=%h cin=%b | sum=%h (exp %h) cout=%b (exp %b)", total_tests, a, b, cin, sum, expected_sum, cout, expected_cout);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_ripple_carry_adder_64.vcd");
        $dumpvars(0, tb_ripple_carry_adder_64);
        $display("ripple_carry_adder_64 Testbench");

        a = 64'h0; b = 64'h0; cin = 0; #10;
        check(64'h0, 1'b0);

        a = 64'h1; b = 64'h1; cin = 0; #10;
        check(64'h2, 1'b0);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h1; cin = 0; #10;
        check(64'h0, 1'b1);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; cin = 0; #10;
        check(64'hFFFFFFFFFFFFFFFE, 1'b1);

        a = 64'h0; b = 64'h0; cin = 1; #10;
        check(64'h1, 1'b0);

        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0; cin = 1; #10;
        check(64'h0, 1'b1);

        $display("Total: %0d  Passed: %0d  Failed: %0d", total_tests, pass_count, fail_count);
        #20 $finish;
    end
endmodule
