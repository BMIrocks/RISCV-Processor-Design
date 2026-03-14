module data_memory (
    input             clk,
    input             reset,
    input             mem_read,
    input             mem_write,
    input      [63:0] addr,
    input      [63:0] write_data,
    output     [63:0] read_data
);

    reg [7:0] mem [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 8'h00;
    end
    assign read_data = mem_read ?
        {mem[addr[9:0] + 7], mem[addr[9:0] + 6],
         mem[addr[9:0] + 5], mem[addr[9:0] + 4],
         mem[addr[9:0] + 3], mem[addr[9:0] + 2],
         mem[addr[9:0] + 1], mem[addr[9:0]]}
        : 64'd0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 8'h00;
        end else if (mem_write) begin
            mem[addr[9:0]]     <= write_data[7:0];
            mem[addr[9:0] + 1] <= write_data[15:8];
            mem[addr[9:0] + 2] <= write_data[23:16];
            mem[addr[9:0] + 3] <= write_data[31:24];
            mem[addr[9:0] + 4] <= write_data[39:32];
            mem[addr[9:0] + 5] <= write_data[47:40];
            mem[addr[9:0] + 6] <= write_data[55:48];
            mem[addr[9:0] + 7] <= write_data[63:56];
        end
    end

endmodule
