module add_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result,
    output cout,
    output overflow
);
    wire carry_out;
    wire sign_a, sign_b, sign_result;
    wire overflow_pos, overflow_neg;

    ripple_carry_adder_64 rca(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(result),
        .cout(carry_out)
    );

    assign cout = carry_out;

    assign sign_a = a[63];
    assign sign_b = b[63];
    assign sign_result = result[63];

    wire same_sign, diff_result_sign;
    xnor(same_sign, sign_a, sign_b);
    xor(diff_result_sign, sign_a, sign_result);
    and(overflow, same_sign, diff_result_sign);

endmodule
