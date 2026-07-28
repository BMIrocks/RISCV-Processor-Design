`timescale 1ns/1ps

module alu_64_bit(
    input [63:0] a,
    input [63:0] b,
    input [3:0] opcode,
    output [63:0] result,
    output cout,
    output carry_flag,
    output overflow_flag,
    output zero_flag
);
    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0] slt_result, sltu_result, sll_result, srl_result, sra_result;
    wire add_cout, add_overflow, sub_cout, sub_overflow;

    add_64 add_inst(
        .a(a),
        .b(b),
        .result(add_result),
        .cout(add_cout),
        .overflow(add_overflow)
    );

    sub_64 sub_inst(
        .a(a),
        .b(b),
        .result(sub_result),
        .cout(sub_cout),
        .overflow(sub_overflow)
    );

    and_64 and_inst(
        .a(a),
        .b(b),
        .result(and_result)
    );

    or_64 or_inst(
        .a(a),
        .b(b),
        .result(or_result)
    );

    xor_64 xor_inst(
        .a(a),
        .b(b),
        .result(xor_result)
    );

    slt_64 slt_inst(
        .a(a),
        .b(b),
        .result(slt_result)
    );

    sltu_64 sltu_inst(
        .a(a),
        .b(b),
        .result(sltu_result)
    );

    sll_64 sll_inst(
        .a(a),
        .b(b),
        .result(sll_result)
    );

    srl_64 srl_inst(
        .a(a),
        .b(b),
        .result(srl_result)
    );

    sra_64 sra_inst(
        .a(a),
        .b(b),
        .result(sra_result)
    );

    wire [63:0] mux_level1_0, mux_level1_1, mux_level1_2, mux_level1_3, mux_level1_4;
    wire [63:0] mux_level2_0, mux_level2_1, mux_level2_2;
    wire [63:0] mux_level3_0, mux_level3_1;
    wire [63:0] mux_result;

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : mux_tree
            wire sel_bit, not_sel_bit;
            wire temp_add, temp_sll;

            not(not_sel_bit, opcode[0]);
            and(temp_add, not_sel_bit, add_result[i]);
            and(temp_sll, opcode[0], sll_result[i]);
            or(mux_level1_0[i], temp_add, temp_sll);

            wire temp_slt, temp_sltu;
            and(temp_slt, not_sel_bit, slt_result[i]);
            and(temp_sltu, opcode[0], sltu_result[i]);
            or(mux_level1_1[i], temp_slt, temp_sltu);

            wire temp_xor, temp_srl;
            and(temp_xor, not_sel_bit, xor_result[i]);
            and(temp_srl, opcode[0], srl_result[i]);
            or(mux_level1_2[i], temp_xor, temp_srl);

            wire temp_or, temp_and;
            and(temp_or, not_sel_bit, or_result[i]);
            and(temp_and, opcode[0], and_result[i]);
            or(mux_level1_3[i], temp_or, temp_and);

            wire sel_sra, sel_sub, not_sel_sub;
            wire temp_sub, temp_sra;

            and(sel_sra, opcode[2], opcode[0]);
            not(not_sel_sub, sel_sra);
            and(temp_sub, not_sel_sub, sub_result[i]);
            and(temp_sra, sel_sra, sra_result[i]);
            or(mux_level1_4[i], temp_sub, temp_sra);

            wire not_op1;
            not(not_op1, opcode[1]);

            wire temp_l2_0a, temp_l2_0b;
            and(temp_l2_0a, not_op1, mux_level1_0[i]);
            and(temp_l2_0b, opcode[1], mux_level1_1[i]);
            or(mux_level2_0[i], temp_l2_0a, temp_l2_0b);

            wire temp_l2_1a, temp_l2_1b;
            and(temp_l2_1a, not_op1, mux_level1_2[i]);
            and(temp_l2_1b, opcode[1], mux_level1_3[i]);
            or(mux_level2_1[i], temp_l2_1a, temp_l2_1b);

            assign mux_level2_2[i] = mux_level1_4[i];

            wire not_op2;
            not(not_op2, opcode[2]);

            wire temp_l3_0a, temp_l3_0b;
            and(temp_l3_0a, not_op2, mux_level2_0[i]);
            and(temp_l3_0b, opcode[2], mux_level2_1[i]);
            or(mux_level3_0[i], temp_l3_0a, temp_l3_0b);

            assign mux_level3_1[i] = mux_level2_2[i];
            wire not_op3;
            not(not_op3, opcode[3]);
            wire temp_final_a, temp_final_b;
            and(temp_final_a, not_op3, mux_level3_0[i]);
            and(temp_final_b, opcode[3], mux_level3_1[i]);
            or(mux_result[i], temp_final_a, temp_final_b);
        end
    endgenerate

    assign result = mux_result;

    wire sel_add_flags, sel_sub_flags;
    wire not_op0, not_op1, not_op2, not_op3;

    not(not_op0, opcode[0]);
    not(not_op1, opcode[1]);
    not(not_op2, opcode[2]);
    not(not_op3, opcode[3]);

    and(sel_add_flags, not_op3, not_op2, not_op1, not_op0);
    and(sel_sub_flags, opcode[3], not_op2, not_op1, not_op0);

    wire cout_from_add, cout_from_sub, overflow_from_add, overflow_from_sub;
    and(cout_from_add, sel_add_flags, add_cout);
    and(cout_from_sub, sel_sub_flags, sub_cout);
    or(cout, cout_from_add, cout_from_sub);
    assign carry_flag = cout;

    and(overflow_from_add, sel_add_flags, add_overflow);
    and(overflow_from_sub, sel_sub_flags, sub_overflow);
    or(overflow_flag, overflow_from_add, overflow_from_sub);

    wire [63:0] nor_chain;
    assign nor_chain[0] = mux_result[0];
    genvar j;
    generate
        for(j = 1; j < 64; j = j + 1) begin : zero_detect
            or(nor_chain[j], nor_chain[j-1], mux_result[j]);
        end
    endgenerate
    not(zero_flag, nor_chain[63]);

endmodule
