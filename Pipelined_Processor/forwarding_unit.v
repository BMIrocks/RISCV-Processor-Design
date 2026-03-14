module forwarding_unit (
    input      [4:0] ID_EX_rs1,
    input      [4:0] ID_EX_rs2,
    input      [4:0] EX_MEM_rd,
    input            EX_MEM_reg_write,
    input      [4:0] MEM_WB_rd,
    input            MEM_WB_reg_write,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin

        ForwardA = 2'b00;

        if (MEM_WB_reg_write && MEM_WB_rd != 5'd0
            && !(EX_MEM_reg_write && EX_MEM_rd != 5'd0 && EX_MEM_rd == ID_EX_rs1)
            && MEM_WB_rd == ID_EX_rs1)
            ForwardA = 2'b01;

        if (EX_MEM_reg_write && EX_MEM_rd != 5'd0 && EX_MEM_rd == ID_EX_rs1)
            ForwardA = 2'b10;
    end

    always @(*) begin

        ForwardB = 2'b00;

        if (MEM_WB_reg_write && MEM_WB_rd != 5'd0
            && !(EX_MEM_reg_write && EX_MEM_rd != 5'd0 && EX_MEM_rd == ID_EX_rs2)
            && MEM_WB_rd == ID_EX_rs2)
            ForwardB = 2'b01;

        if (EX_MEM_reg_write && EX_MEM_rd != 5'd0 && EX_MEM_rd == ID_EX_rs2)
            ForwardB = 2'b10;
    end

endmodule
