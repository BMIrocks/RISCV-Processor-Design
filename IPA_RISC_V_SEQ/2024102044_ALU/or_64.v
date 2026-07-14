module or_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : or_gate
            or(result[i], a[i], b[i]);
        end
    endgenerate

endmodule
