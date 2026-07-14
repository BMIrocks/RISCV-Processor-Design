module srl_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    wire [63:0] stage0, stage1, stage2, stage3, stage4, stage5;
    wire [5:0] shamt;

    assign shamt = b[5:0];

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : stage0_gen
            wire shifted_bit;
            assign shifted_bit = (i == 63) ? 1'b0 : a[i+1];
            assign stage0[i] = shamt[0] ? shifted_bit : a[i];
        end
    endgenerate

    generate
        for(i = 0; i < 64; i = i + 1) begin : stage1_gen
            wire shifted_bit;
            assign shifted_bit = (i > 61) ? 1'b0 : stage0[i+2];
            assign stage1[i] = shamt[1] ? shifted_bit : stage0[i];
        end
    endgenerate

    generate
        for(i = 0; i < 64; i = i + 1) begin : stage2_gen
            wire shifted_bit;
            assign shifted_bit = (i > 59) ? 1'b0 : stage1[i+4];
            assign stage2[i] = shamt[2] ? shifted_bit : stage1[i];
        end
    endgenerate

    generate
        for(i = 0; i < 64; i = i + 1) begin : stage3_gen
            wire shifted_bit;
            assign shifted_bit = (i > 55) ? 1'b0 : stage2[i+8];
            assign stage3[i] = shamt[3] ? shifted_bit : stage2[i];
        end
    endgenerate

    generate
        for(i = 0; i < 64; i = i + 1) begin : stage4_gen
            wire shifted_bit;
            assign shifted_bit = (i > 47) ? 1'b0 : stage3[i+16];
            assign stage4[i] = shamt[4] ? shifted_bit : stage3[i];
        end
    endgenerate

    generate
        for(i = 0; i < 64; i = i + 1) begin : stage5_gen
            wire shifted_bit;
            assign shifted_bit = (i > 31) ? 1'b0 : stage4[i+32];
            assign stage5[i] = shamt[5] ? shifted_bit : stage4[i];
        end
    endgenerate

    assign result = stage5;

endmodule
