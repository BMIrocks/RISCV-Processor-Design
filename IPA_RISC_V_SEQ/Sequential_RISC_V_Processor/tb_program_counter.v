`timescale 1ns/1ps
`include "program_counter.v"

module tb_program_counter;

    reg clk;
    reg reset;
    reg halt;
    reg [63:0] pc_next;
    wire [63:0] pc;

    program_counter uut (
        .clk(clk),
        .reset(reset),
        .halt(halt),
        .pc_next(pc_next),
        .pc(pc)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [255:0] test_name;
        input [63:0] actual;
        input [63:0] expected;
        begin
            total_tests = total_tests + 1;
            if (actual === expected) begin
                $display("PASS: %0s | Expected: %0h, Got: %0h", test_name, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s | Expected: %0h, Got: %0h", test_name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_program_counter.vcd");
        $dumpvars(0, tb_program_counter);
        $display("=== program_counter Testbench ===");

        reset = 1;
        halt = 0;
        pc_next = 64'd0;
        @(posedge clk);
        #1;
        check("Reset sets PC to 0", pc, 64'd0);

        reset = 0;
        pc_next = 64'd4;
        @(posedge clk);
        #1;
        check("PC loads pc_next=4", pc, 64'd4);

        pc_next = 64'd8;
        @(posedge clk);
        #1;
        check("PC loads pc_next=8", pc, 64'd8);

        pc_next = 64'd100;
        @(posedge clk);
        #1;
        check("PC loads pc_next=100", pc, 64'd100);

        halt = 1;
        pc_next = 64'd200;
        @(posedge clk);
        #1;
        check("Halt active - PC stays at 100", pc, 64'd100);

        pc_next = 64'd300;
        @(posedge clk);
        #1;
        check("Halt still active - PC stays at 100", pc, 64'd100);

        halt = 0;
        pc_next = 64'd200;
        @(posedge clk);
        #1;
        check("Halt deasserted - PC loads 200", pc, 64'd200);

        pc_next = 64'd204;
        @(posedge clk);
        #1;
        check("Normal increment after halt resume", pc, 64'd204);

        reset = 1;
        pc_next = 64'd500;
        @(posedge clk);
        #1;
        check("Reset during operation sets PC to 0", pc, 64'd0);

        reset = 0;
        pc_next = 64'd44;
        @(posedge clk);
        #1;
        check("Normal operation after second reset", pc, 64'd44);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
