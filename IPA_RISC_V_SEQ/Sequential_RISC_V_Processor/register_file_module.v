module register_file_module (
    input             clk,
    input             reset,
    input             reg_write,
    input      [4:0]  rs1,
    input      [4:0]  rs2,
    input      [4:0]  rd,
    input      [63:0] write_data,
    output     [63:0] read_data1,
    output     [63:0] read_data2
);

    reg [63:0] registers [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'd0;
    end
    assign read_data1 = (rs1 == 5'd0) ? 64'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 64'd0 : registers[rs2];
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 64'd0;
        end else if (reg_write && (rd != 5'd0))
            registers[rd] <= write_data;
    end

endmodule
