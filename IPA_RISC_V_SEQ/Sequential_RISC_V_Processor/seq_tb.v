`timescale 1ns/1ps

`include "../2024102066_ALU/full_adder.v"
`include "../2024102066_ALU/ripple_carry_adder_64.v"
`include "../2024102066_ALU/add_64.v"
`include "../2024102066_ALU/sub_64.v"
`include "../2024102066_ALU/and_64.v"
`include "../2024102066_ALU/or_64.v"
`include "../2024102066_ALU/xor_64.v"
`include "../2024102066_ALU/slt_64.v"
`include "../2024102066_ALU/sltu_64.v"
`include "../2024102066_ALU/sll_64.v"
`include "../2024102066_ALU/srl_64.v"
`include "../2024102066_ALU/sra_64.v"
`include "alu.v"

`include "program_counter.v"
`include "instruction_memory.v"
`include "control_unit.v"
`include "register_file_module.v"
`include "imm_gen.v"
`include "alu_control.v"
`include "data_memory.v"

`include "processor.v"
module seq_tb;
    reg clk;
    reg reset;
    wire halt;
    wire [31:0] cycle_count;
    processor DUT (
        .clk         (clk),
        .reset       (reset),
        .halt        (halt),
        .cycle_count (cycle_count)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    integer i;
    integer fd;
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, seq_tb);
        reset = 1;
        #12;
        reset = 0;
        wait(halt == 1'b1);
        @(posedge clk);
        @(posedge clk);
        fd = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1) begin
            $fwrite(fd, "%h\n", DUT.REG_FILE.registers[i]);
        end
        $fwrite(fd, "%0d\n", cycle_count);
        $fclose(fd);
        $display("");
        $display("  Register dump written to: register_file.txt");
        $display("================================================================");
        #20 $finish;
    end

endmodule
