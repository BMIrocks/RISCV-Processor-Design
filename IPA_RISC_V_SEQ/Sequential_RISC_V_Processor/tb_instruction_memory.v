`timescale 1ns/1ps
`include "instruction_memory.v"

module tb_instruction_memory;

    reg clk;
    reg reset;
    reg [63:0] addr;
    wire [31:0] instruction;

    instruction_memory uut (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .instruction(instruction)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;

    task check;
        input [255:0] test_name;
        input [31:0] actual;
        input [31:0] expected;
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
        $dumpfile("tb_instruction_memory.vcd");
        $dumpvars(0, tb_instruction_memory);
        $display("=== instruction_memory Testbench ===");

        reset = 0;
        addr = 64'd0;

        #2;

        uut.mem[0] = 8'hDE;
        uut.mem[1] = 8'hAD;
        uut.mem[2] = 8'hBE;
        uut.mem[3] = 8'hEF;

        uut.mem[4] = 8'hCA;
        uut.mem[5] = 8'hFE;
        uut.mem[6] = 8'hBA;
        uut.mem[7] = 8'hBE;

        uut.mem[8] = 8'h00;
        uut.mem[9] = 8'h50;
        uut.mem[10] = 8'h00;
        uut.mem[11] = 8'h93;

        uut.mem[100] = 8'h12;
        uut.mem[101] = 8'h34;
        uut.mem[102] = 8'h56;
        uut.mem[103] = 8'h78;

        #1;

        addr = 64'd0;
        #1;
        check("Addr 0: DEADBEEF", instruction, 32'hDEADBEEF);

        addr = 64'd4;
        #1;
        check("Addr 4: CAFEBABE", instruction, 32'hCAFEBABE);

        addr = 64'd8;
        #1;
        check("Addr 8: 00500093", instruction, 32'h00500093);

        addr = 64'd100;
        #1;
        check("Addr 100: 12345678", instruction, 32'h12345678);

        addr = 64'd2;
        #1;
        check("Addr 2 unaligned: BEEF_CAFE", instruction, 32'hBEEFCAFE);

        uut.mem[200] = 8'h00;
        uut.mem[201] = 8'h00;
        uut.mem[202] = 8'h00;
        uut.mem[203] = 8'h00;
        #1;
        addr = 64'd200;
        #1;
        check("Addr 200: all zeros", instruction, 32'h00000000);

        uut.mem[16] = 8'hFF;
        uut.mem[17] = 8'hFF;
        uut.mem[18] = 8'hFF;
        uut.mem[19] = 8'hFF;
        #1;
        addr = 64'd16;
        #1;
        check("Addr 16: all ones", instruction, 32'hFFFFFFFF);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
