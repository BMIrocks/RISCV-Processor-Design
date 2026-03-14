module program_counter (
    input             clk,
    input             reset,
    input             halt,
    input      [63:0] pc_next,
    output reg [63:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 64'd0;
        else if (!halt)
            pc <= pc_next;
    end

endmodule
