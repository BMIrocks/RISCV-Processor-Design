`timescale 1ns/1ps
`include "full_adder.v"

module tb_full_adder;
    reg a, b, cin;
    wire sum, cout;

    full_adder uut(
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
        input expected_sum;
        input expected_cout;
        begin
            total_tests = total_tests + 1;
            if (sum === expected_sum && cout === expected_cout) begin
                $display("PASS: Test %0d: a=%b b=%b cin=%b | sum=%b cout=%b", total_tests, a, b, cin, sum, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Test %0d: a=%b b=%b cin=%b | sum=%b (exp %b) cout=%b (exp %b)", total_tests, a, b, cin, sum, expected_sum, cout, expected_cout);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_full_adder.vcd");
        $dumpvars(0, tb_full_adder);
        $display("full_adder Testbench");

        a = 0; b = 0; cin = 0; #10;
        check(1'b0, 1'b0);

        a = 0; b = 0; cin = 1; #10;
        check(1'b1, 1'b0);

        a = 0; b = 1; cin = 0; #10;
        check(1'b1, 1'b0);

        a = 0; b = 1; cin = 1; #10;
        check(1'b0, 1'b1);

        a = 1; b = 0; cin = 0; #10;
        check(1'b1, 1'b0);

        a = 1; b = 0; cin = 1; #10;
        check(1'b0, 1'b1);

        a = 1; b = 1; cin = 0; #10;
        check(1'b0, 1'b1);

        a = 1; b = 1; cin = 1; #10;
        check(1'b1, 1'b1);

        $display("Total: %0d  Passed: %0d  Failed: %0d", total_tests, pass_count, fail_count);
        #20 $finish;
    end
endmodule
