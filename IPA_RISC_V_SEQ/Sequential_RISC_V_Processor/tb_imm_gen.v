`timescale 1ns/1ps
`include "imm_gen.v"

module tb_imm_gen;

    reg [31:0] instruction;
    wire [63:0] imm_out;

    imm_gen uut (
        .instruction(instruction),
        .imm_out(imm_out)
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

    initial begin
        $dumpfile("tb_imm_gen.vcd");
        $dumpvars(0, tb_imm_gen);
        $display("=== imm_gen Testbench ===");

        instruction = 32'h00500013;
        #10;
        check("I-type positive imm=5", imm_out, 64'h0000000000000005);

        instruction = 32'hFFD00013;
        #10;
        check("I-type negative imm=-3", imm_out, 64'hFFFFFFFFFFFFFFFD);

        instruction = 32'h7FF00013;
        #10;
        check("I-type max positive imm=2047", imm_out, 64'h00000000000007FF);

        instruction = 32'h80000013;
        #10;
        check("I-type min negative imm=-2048", imm_out, 64'hFFFFFFFFFFFFF800);

        instruction = 32'h01000003;
        #10;
        check("Load positive imm=16", imm_out, 64'h0000000000000010);

        instruction = 32'hFF000003;
        #10;
        check("Load negative imm=-16", imm_out, 64'hFFFFFFFFFFFFFFF0);

        instruction = 32'h00000C23;
        #10;
        check("S-type positive imm=24", imm_out, 64'h0000000000000018);

        instruction = 32'hFE000C23;
        #10;
        check("S-type negative imm=-8", imm_out, 64'hFFFFFFFFFFFFFFF8);

        instruction = 32'h00000A63;
        #10;
        check("B-type positive imm=20", imm_out, 64'h0000000000000014);

        instruction = 32'hFE000AE3;
        #10;
        check("B-type negative imm=-12", imm_out, 64'hFFFFFFFFFFFFFFF4);

        instruction = 32'h00208463;
        #10;
        check("B-type positive imm=8", imm_out, 64'h0000000000000008);

        instruction = 32'h00000033;
        #10;
        check("Default R-type imm=0", imm_out, 64'h0000000000000000);

        instruction = 32'h00000000;
        #10;
        check("Default all-zeros imm=0", imm_out, 64'h0000000000000000);

        $display("=== Results: Total: %0d  Passed: %0d  Failed: %0d ===", total_tests, pass_count, fail_count);
        #20 $finish;
    end

endmodule
