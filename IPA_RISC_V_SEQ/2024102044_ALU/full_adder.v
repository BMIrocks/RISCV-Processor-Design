module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    wire s1, c1, c2;

    xor(s1, a, b);
    xor(sum, s1, cin);

    and(c1, a, b);
    and(c2, cin, s1);
    or(cout, c1, c2);

endmodule
