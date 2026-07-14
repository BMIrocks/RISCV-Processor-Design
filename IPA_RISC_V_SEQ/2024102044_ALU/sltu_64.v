module sltu_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    wire [63:0] diff;
    wire borrow;
    wire less_than;

    wire [63:0] b_inverted;

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : invert_b
            not(b_inverted[i], b[i]);
        end
    endgenerate

    ripple_carry_adder_64 rca(
        .a(a),
        .b(b_inverted),
        .cin(1'b1),
        .sum(diff),
        .cout(borrow)
    );

    not(less_than, borrow);

    assign result[0] = less_than;

    generate
        for(i = 1; i < 64; i = i + 1) begin : zero_upper
            assign result[i] = 1'b0;
        end
    endgenerate

endmodule
