`ifndef IMEM_SIZE
    `define IMEM_SIZE 4096
`endif
module instruction_memory (
    input             clk,
    input             reset,
    input      [63:0] addr,
    output     [31:0] instruction
);
    reg [7:0] mem [0:`IMEM_SIZE-1];
    integer i;
    initial begin
        for (i = 0; i < `IMEM_SIZE; i = i + 1)
            mem[i] = 8'h00;
        $readmemh("../instructions.txt", mem);
    end
    assign instruction = {mem[addr], mem[addr + 1],mem[addr + 2], mem[addr + 3]};

endmodule
