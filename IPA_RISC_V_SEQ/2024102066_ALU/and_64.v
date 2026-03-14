module and_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : and_gate
            and(result[i], a[i], b[i]);
        end
    endgenerate

endmodule
