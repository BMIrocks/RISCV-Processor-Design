module slt_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    wire [63:0] diff;
    wire cout, overflow;
    wire sign_a, sign_b, sign_diff;
    wire less_than;
    wire case1, case2, case3;

    sub_64 subtractor(
        .a(a),
        .b(b),
        .result(diff),
        .cout(cout),
        .overflow(overflow)
    );

    assign sign_a = a[63];
    assign sign_b = b[63];
    assign sign_diff = diff[63];

    wire not_sign_b, same_sign;
    not(not_sign_b, sign_b);
    and(case1, sign_a, not_sign_b);

    xnor(same_sign, sign_a, sign_b);
    wire not_overflow;
    not(not_overflow, overflow);
    wire cond2;
    and(cond2, same_sign, not_overflow);
    and(case2, cond2, sign_diff);

    wire cond3;
    and(cond3, same_sign, overflow);
    wire not_sign_diff;
    not(not_sign_diff, sign_diff);
    and(case3, cond3, not_sign_diff);

    wire lt_temp;
    or(lt_temp, case1, case2);
    or(less_than, lt_temp, case3);

    assign result[0] = less_than;

    genvar i;
    generate
        for(i = 1; i < 64; i = i + 1) begin : zero_upper
            assign result[i] = 1'b0;
        end
    endgenerate

endmodule
