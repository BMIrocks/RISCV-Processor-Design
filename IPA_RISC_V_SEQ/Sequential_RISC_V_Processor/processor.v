module processor (
    input             clk,
    input             reset,
    output            halt,
    output reg [31:0] cycle_count
);

    wire [31:0] instruction;
    assign halt = (instruction == 32'h00000000);

    reg halt_delayed;
    always @(posedge clk or posedge reset) begin
        if (reset)
            halt_delayed <= 1'b0;
        else
            halt_delayed <= halt;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            cycle_count <= 32'd0;
        else if (!halt_delayed)
            cycle_count <= cycle_count + 32'd1;
    end

    wire [6:0]  opcode    = instruction[6:0];
    wire [4:0]  rd        = instruction[11:7];
    wire [2:0]  funct3    = instruction[14:12];
    wire [4:0]  rs1       = instruction[19:15];
    wire [4:0]  rs2       = instruction[24:20];
    wire        funct7_b5;

    wire        reg_write;
    wire        alu_src;
    wire        mem_read;
    wire        mem_write;
    wire        mem_to_reg;
    wire        branch;
    wire [1:0]  alu_op;

    wire [63:0] read_data1;
    wire [63:0] read_data2;
    wire [63:0] write_data;

    wire [63:0] imm_gen_out;

    wire [3:0]  alu_opcode;
    wire [63:0] alu_input_b;
    wire [63:0] alu_result;
    wire        zero_flag;
    wire        cout;
    wire        carry_flag;
    wire        overflow_flag;

    wire [63:0] mem_read_data;

    wire [63:0] pc;
    wire [63:0] pc_plus_4;
    wire [63:0] branch_target;
    wire [63:0] pc_next;
    wire        branch_taken;

    assign pc_plus_4 = pc + 64'd4;
    assign branch_target = pc + (imm_gen_out << 1);
    wire negative_flag = alu_result[63];
    reg branch_condition;
    always @(*) begin
        case (funct3)
            3'b000: branch_condition = zero_flag;
        endcase
    end
    assign branch_taken = branch & branch_condition;
    assign pc_next = branch_taken ? branch_target : pc_plus_4;
    program_counter PC_REG (
        .clk     (clk),
        .reset   (reset),
        .halt    (halt),
        .pc_next (pc_next),
        .pc      (pc)
    );
    instruction_memory IMEM (
        .clk         (clk),
        .reset       (reset),
        .addr        (pc),
        .instruction (instruction)
    );
    wire reg_write_raw, mem_read_raw, mem_write_raw;
    control_unit CTRL (
        .opcode     (opcode),
        .reg_write  (reg_write_raw),
        .alu_src    (alu_src),
        .mem_read   (mem_read_raw),
        .mem_write  (mem_write_raw),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .alu_op     (alu_op)
    );

    assign reg_write = reg_write_raw & ~halt;
    assign mem_read  = mem_read_raw & ~halt;
    assign mem_write = mem_write_raw & ~halt;

    register_file_module REG_FILE (
        .clk        (clk),
        .reset      (reset),
        .reg_write  (reg_write),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (write_data),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );
    imm_gen IMM_GEN (
        .instruction (instruction),
        .imm_out     (imm_gen_out)
    );
    assign funct7_b5 = instruction[30] &
                       ((opcode == 7'b0110011) | (funct3 == 3'b101));

    alu_control ALU_CTRL (
        .alu_op      (alu_op),
        .funct3      (funct3),
        .funct7_bit5 (funct7_b5),
        .alu_opcode  (alu_opcode)
    );
    assign alu_input_b = alu_src ? imm_gen_out : read_data2;
    alu_64_bit ALU (
        .a             (read_data1),
        .b             (alu_input_b),
        .opcode        (alu_opcode),
        .result        (alu_result),
        .cout          (cout),
        .carry_flag    (carry_flag),
        .overflow_flag (overflow_flag),
        .zero_flag     (zero_flag)
    );
    data_memory DMEM (
        .clk        (clk),
        .reset      (reset),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .addr       (alu_result),
        .write_data (read_data2),
        .read_data  (mem_read_data)
    );
    assign write_data = mem_to_reg ? mem_read_data : alu_result;

endmodule
