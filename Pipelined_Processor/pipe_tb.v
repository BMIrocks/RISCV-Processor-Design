`timescale 1ns/1ps

`include "../IPA_RISC_V_SEQ/2024102066_ALU/full_adder.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/ripple_carry_adder_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/add_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sub_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/and_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/or_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/xor_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/slt_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sltu_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sll_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/srl_64.v"
`include "../IPA_RISC_V_SEQ/2024102066_ALU/sra_64.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu.v"

`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/program_counter.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/instruction_memory.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/control_unit.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/imm_gen.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/alu_control.v"
`include "../IPA_RISC_V_SEQ/Sequential_RISC_V_Processor/data_memory.v"

`include "register_file_module.v"
`include "forwarding_unit.v"
`include "hazard_detection_unit.v"
`include "branch_predictor.v"
`include "pipelined_processor.v"

module pipe_tb;

    reg         clk;
    reg         reset;
    wire        halt;
    wire [31:0] cycle_count;

    pipelined_processor DUT (
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
        $dumpvars(0, pipe_tb);

        reset = 1;
        #12;
        reset = 0;

        wait (halt == 1'b1);
          @(posedge clk);

        #1;

        fd = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1) begin
            $fwrite(fd, "%h\n", DUT.REG_FILE.registers[i]);
        end

        #1;
        $fwrite(fd, "%0d\n", cycle_count);
        $fclose(fd);

        $display("");
        $display("  Register dump written to: register_file.txt");
        $display("  Base: %0d, Flush: %0d, Total: %0d", DUT.base_count, DUT.flush_count, cycle_count);
        $display("================================================================");

        #20 $finish;
    end

endmodule
