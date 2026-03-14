`timescale 1ns/1ps
`include "register_file_module.v"

module tb_register_file_module;

    reg clk;
    reg reg_write;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [63:0] write_data;
    wire [63:0] read_data1;
    wire [63:0] read_data2;

    register_file_module uut (
        .clk(clk),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
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
        $dumpfile("tb_register_file_module.vcd");
        $dumpvars(0, tb_register_file_module);
        $display("=== register_file_module Testbench ===");

        reg_write = 0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd0;
        write_data = 64'd0;

        @(posedge clk);
        #1;
        check("x0 reads 0 on rs1", read_data1, 64'd0);
        check("x0 reads 0 on rs2", read_data2, 64'd0);

        reg_write = 1;
        rd = 5'd1;
        write_data = 64'hDEADBEEFCAFEBABE;
        @(posedge clk);
        #1;
        rs1 = 5'd1;
        rs2 = 5'd0;
        #1;
        check("Write x1, read x1 on rs1", read_data1, 64'hDEADBEEFCAFEBABE);
        check("x0 still 0 on rs2", read_data2, 64'd0);

        rd = 5'd2;
        write_data = 64'h123456789ABCDEF0;
        @(posedge clk);
        #1;
        rs1 = 5'd1;
        rs2 = 5'd2;
        #1;
        check("x1 unchanged on rs1", read_data1, 64'hDEADBEEFCAFEBABE);
        check("Write x2, read x2 on rs2", read_data2, 64'h123456789ABCDEF0);

        rd = 5'd31;
        write_data = 64'hFFFFFFFFFFFFFFFF;
        @(posedge clk);
        #1;
        rs1 = 5'd31;
        #1;
        check("Write x31, read x31", read_data1, 64'hFFFFFFFFFFFFFFFF);

        rd = 5'd0;
        write_data = 64'hAAAAAAAAAAAAAAAA;
        @(posedge clk);
        #1;
        rs1 = 5'd0;
        #1;
        check("Write to x0 ignored, x0 still 0", read_data1, 64'd0);

        rd = 5'd15;
        write_data = 64'd42;
        @(posedge clk);
        #1;
        rs1 = 5'd15;
        rs2 = 5'd31;
        #1;
        check("Write x15=42, read on rs1", read_data1, 64'd42);
        check("x31 unchanged on rs2", read_data2, 64'hFFFFFFFFFFFFFFFF);

        reg_write = 0;
        rd = 5'd15;
        write_data = 64'd999;
        @(posedge clk);
        #1;
        rs1 = 5'd15;
        #1;
        check("reg_write=0, x15 unchanged", read_data1, 64'd42);

        reg_write = 1;
        rd = 5'd10;
        write_data = 64'd100;
        @(posedge clk);
        #1;
        rd = 5'd11;
        write_data = 64'd200;
        @(posedge clk);
        #1;
        rs1 = 5'd10;
        rs2 = 5'd11;
        #1;
        check("x10=100 on rs1", read_data1, 64'd100);
        check("x11=200 on rs2", read_data2, 64'd200);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
