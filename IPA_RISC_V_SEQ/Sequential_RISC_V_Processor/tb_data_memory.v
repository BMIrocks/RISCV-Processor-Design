`timescale 1ns/1ps
`include "data_memory.v"

module tb_data_memory;

    reg clk;
    reg mem_read;
    reg mem_write;
    reg [63:0] addr;
    reg [63:0] write_data;
    wire [63:0] read_data;

    data_memory uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
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

    task check_byte;
        input [255:0] test_name;
        input [7:0] actual;
        input [7:0] expected;
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
        $dumpfile("tb_data_memory.vcd");
        $dumpvars(0, tb_data_memory);
        $display("=== data_memory Testbench ===");

        mem_read = 0;
        mem_write = 0;
        addr = 64'd0;
        write_data = 64'd0;

        #1;
        mem_read = 1;
        addr = 64'd0;
        #1;
        check("Initial memory reads 0", read_data, 64'd0);

        mem_read = 0;
        mem_write = 1;
        addr = 64'd0;
        write_data = 64'hDEADBEEFCAFEBABE;
        @(posedge clk);
        #1;

        mem_write = 0;
        mem_read = 1;
        addr = 64'd0;
        #1;
        check("Write and read back doubleword", read_data, 64'hDEADBEEFCAFEBABE);

        check_byte("LE byte[0] = BE", uut.mem[0], 8'hBE);
        check_byte("LE byte[1] = BA", uut.mem[1], 8'hBA);
        check_byte("LE byte[2] = FE", uut.mem[2], 8'hFE);
        check_byte("LE byte[3] = CA", uut.mem[3], 8'hCA);
        check_byte("LE byte[4] = EF", uut.mem[4], 8'hEF);
        check_byte("LE byte[5] = BE", uut.mem[5], 8'hBE);
        check_byte("LE byte[6] = AD", uut.mem[6], 8'hAD);
        check_byte("LE byte[7] = DE", uut.mem[7], 8'hDE);

        mem_read = 0;
        addr = 64'd0;
        #1;
        check("mem_read=0 returns 0", read_data, 64'd0);

        mem_read = 0;
        mem_write = 1;
        addr = 64'd16;
        write_data = 64'h0102030405060708;
        @(posedge clk);
        #1;

        mem_write = 0;
        mem_read = 1;
        addr = 64'd16;
        #1;
        check("Second write at addr 16", read_data, 64'h0102030405060708);

        check_byte("Addr 16 LE byte[0] = 08", uut.mem[16], 8'h08);
        check_byte("Addr 16 LE byte[7] = 01", uut.mem[23], 8'h01);

        mem_read = 1;
        addr = 64'd0;
        #1;
        check("First write still intact at addr 0", read_data, 64'hDEADBEEFCAFEBABE);

        mem_read = 0;
        mem_write = 1;
        addr = 64'd0;
        write_data = 64'hFFFFFFFFFFFFFFFF;
        @(posedge clk);
        #1;

        mem_write = 0;
        mem_read = 1;
        addr = 64'd0;
        #1;
        check("Overwrite addr 0 with all ones", read_data, 64'hFFFFFFFFFFFFFFFF);

        mem_read = 0;
        mem_write = 1;
        addr = 64'd0;
        write_data = 64'd0;
        @(posedge clk);
        #1;

        mem_write = 0;
        mem_read = 1;
        addr = 64'd0;
        #1;
        check("Overwrite addr 0 with zero", read_data, 64'd0);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
