module sub_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result,
    output cout,
    output overflow
);
    wire [63:0] b_inverted;
    wire carry_out;
    wire sign_a, sign_b, sign_result;

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
        .sum(result),
        .cout(carry_out)
    );

    assign cout = (~carry_out) ^ overflow;

    assign sign_a = a[63];
    assign sign_b = b[63];
    assign sign_result = result[63];

    wire diff_sign, diff_result_sign;
    xor(diff_sign, sign_a, sign_b);
    xor(diff_result_sign, sign_a, sign_result);
    and(overflow, diff_sign, diff_result_sign);

endmodule
