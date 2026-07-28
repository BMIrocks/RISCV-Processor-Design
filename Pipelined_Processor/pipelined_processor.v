module pipelined_processor (
    input             clk,
    input             reset,
    output            halt,
    output reg [31:0] cycle_count
);

    wire [31:0] IF_instruction;
    assign halt = (IF_instruction == 32'h00000000);

    reg halt_delayed;
    always @(posedge clk or posedge reset) begin
        if (reset)
            halt_delayed <= 1'b0;
        else
            halt_delayed <= halt;
    end

    reg [31:0] flush_count;
    always @(posedge clk or posedge reset) begin
        if (reset)
            flush_count <= 32'd0;
        else if (flush && !halt)
            flush_count <= flush_count + 32'd1;
    end

    reg [31:0] base_count;
    always @(posedge clk or posedge reset) begin
        if (reset)
            base_count <= 32'd0;
        else if (!halt)
            base_count <= base_count + 32'd1;
    end

    always @(*) begin
        cycle_count = base_count + flush_count;
    end

    wire        stall;
    wire        flush;

    wire        WB_reg_write;
    wire [4:0]  WB_rd;
    wire [63:0] WB_write_data;

    wire [63:0] pc, pc_plus_4, pc_next;
    wire [63:0] branch_target;
    wire        branch_taken;

    wire        predict_taken;
    wire [63:0] predict_target;
    wire        btb_hit;
    wire        misprediction;
    wire [63:0] correct_pc;

    assign pc_plus_4 = pc + 64'd4;

    assign pc_next = misprediction ? correct_pc :
                     (predict_taken ? predict_target : pc_plus_4);

    branch_predictor BP (
        .clk           (clk),
        .reset         (reset),
        .pc_IF         (pc),
        .predict_taken (predict_taken),
        .predict_target(predict_target),
        .btb_hit       (btb_hit),
        .update_en     (ID_branch),
        .pc_update     (IF_ID_PC),
        .actual_taken  (branch_taken),
        .actual_target (branch_target)
    );

    program_counter PC_REG (
        .clk     (clk),
        .reset   (reset),
        .halt    (halt | stall),
        .pc_next (pc_next),
        .pc      (pc)
    );

    instruction_memory IMEM (
        .clk         (clk),
        .reset       (reset),
        .addr        (pc),
        .instruction (IF_instruction)
    );

    reg [63:0] IF_ID_PC;
    reg [31:0] IF_ID_instruction;
    reg        IF_ID_predicted_taken;

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            IF_ID_PC              <= 64'd0;
            IF_ID_instruction     <= 32'd0;
            IF_ID_predicted_taken <= 1'b0;
        end else if (!stall) begin
            IF_ID_PC              <= pc;
            IF_ID_instruction     <= IF_instruction;
            IF_ID_predicted_taken <= predict_taken;
        end

    end

    wire [6:0]  ID_opcode  = IF_ID_instruction[6:0];
    wire [4:0]  ID_rd      = IF_ID_instruction[11:7];
    wire [2:0]  ID_funct3  = IF_ID_instruction[14:12];
    wire [4:0]  ID_rs1     = IF_ID_instruction[19:15];
    wire [4:0]  ID_rs2     = IF_ID_instruction[24:20];
    wire        ID_funct7_b5;

    assign ID_funct7_b5 = IF_ID_instruction[30] &
                           ((ID_opcode == 7'b0110011) | (ID_funct3 == 3'b101));

    wire        ID_reg_write, ID_alu_src, ID_mem_read, ID_mem_write;
    wire        ID_mem_to_reg, ID_branch;
    wire [1:0]  ID_alu_op;

    control_unit CTRL (
        .opcode     (ID_opcode),
        .reg_write  (ID_reg_write),
        .alu_src    (ID_alu_src),
        .mem_read   (ID_mem_read),
        .mem_write  (ID_mem_write),
        .mem_to_reg (ID_mem_to_reg),
        .branch     (ID_branch),
        .alu_op     (ID_alu_op)
    );

    wire [63:0] ID_read_data1, ID_read_data2;

    register_file_module REG_FILE (
        .clk        (clk),
        .reset      (reset),
        .reg_write  (WB_reg_write),
        .rs1        (ID_rs1),
        .rs2        (ID_rs2),
        .rd         (WB_rd),
        .write_data (WB_write_data),
        .read_data1 (ID_read_data1),
        .read_data2 (ID_read_data2)
    );

    wire [63:0] ID_imm_gen_out;

    imm_gen IMM_GEN (
        .instruction (IF_ID_instruction),
        .imm_out     (ID_imm_gen_out)
    );

    wire [63:0] ID_branch_target = IF_ID_PC + ID_imm_gen_out;

    reg [63:0] branch_op1, branch_op2;
    always @(*) begin

        if (EX_MEM_reg_write && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_rs1))
            branch_op1 = EX_MEM_alu_result;
        else if (WB_reg_write && (WB_rd != 5'd0) && (WB_rd == ID_rs1))
            branch_op1 = WB_write_data;
        else
            branch_op1 = ID_read_data1;

        if (EX_MEM_reg_write && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_rs2))
            branch_op2 = EX_MEM_alu_result;
        else if (WB_reg_write && (WB_rd != 5'd0) && (WB_rd == ID_rs2))
            branch_op2 = WB_write_data;
        else
            branch_op2 = ID_read_data2;
    end

    reg ID_branch_condition;
    always @(*) begin
        case (ID_funct3)
            3'b000:  ID_branch_condition = (branch_op1 == branch_op2);
            default: ID_branch_condition = 1'b0;
        endcase
    end

    assign branch_taken  = ID_branch & ID_branch_condition;
    assign branch_target = ID_branch_target;

    assign misprediction = ID_branch & (IF_ID_predicted_taken != branch_taken);

    assign correct_pc = branch_taken ? branch_target : (IF_ID_PC + 64'd4);

    assign flush = misprediction;

    hazard_detection_unit HDU (
        .ID_EX_mem_read   (ID_EX_mem_read),
        .ID_EX_reg_write  (ID_EX_reg_write),
        .ID_EX_rd         (ID_EX_rd),
        .IF_ID_rs1        (ID_rs1),
        .IF_ID_rs2        (ID_rs2),
        .IF_ID_mem_write  (ID_mem_write),
        .IF_ID_branch     (ID_branch),
        .EX_MEM_reg_write (EX_MEM_reg_write),
        .EX_MEM_rd        (EX_MEM_rd),
        .EX_MEM_mem_read  (EX_MEM_mem_read),
        .stall            (stall)
    );

    reg [63:0] ID_EX_PC;
    reg [63:0] ID_EX_read_data1;
    reg [63:0] ID_EX_read_data2;
    reg [63:0] ID_EX_imm_gen_out;
    reg [2:0]  ID_EX_funct3;
    reg        ID_EX_funct7_b5;
    reg [4:0]  ID_EX_rs1;
    reg [4:0]  ID_EX_rs2;
    reg [4:0]  ID_EX_rd;

    reg        ID_EX_reg_write;
    reg        ID_EX_alu_src;
    reg        ID_EX_mem_read;
    reg        ID_EX_mem_write;
    reg        ID_EX_mem_to_reg;
    reg [1:0]  ID_EX_alu_op;

    always @(posedge clk or posedge reset) begin
        if (reset || flush || stall) begin

            ID_EX_PC          <= 64'd0;
            ID_EX_read_data1  <= 64'd0;
            ID_EX_read_data2  <= 64'd0;
            ID_EX_imm_gen_out <= 64'd0;
            ID_EX_funct3      <= 3'd0;
            ID_EX_funct7_b5   <= 1'b0;
            ID_EX_rs1         <= 5'd0;
            ID_EX_rs2         <= 5'd0;
            ID_EX_rd          <= 5'd0;
            ID_EX_reg_write   <= 1'b0;
            ID_EX_alu_src     <= 1'b0;
            ID_EX_mem_read    <= 1'b0;
            ID_EX_mem_write   <= 1'b0;
            ID_EX_mem_to_reg  <= 1'b0;
            ID_EX_alu_op      <= 2'b00;
        end else begin
            ID_EX_PC          <= IF_ID_PC;
            ID_EX_read_data1  <= ID_read_data1;
            ID_EX_read_data2  <= ID_read_data2;
            ID_EX_imm_gen_out <= ID_imm_gen_out;
            ID_EX_funct3      <= ID_funct3;
            ID_EX_funct7_b5   <= ID_funct7_b5;
            ID_EX_rs1         <= ID_rs1;
            ID_EX_rs2         <= ID_rs2;
            ID_EX_rd          <= ID_rd;
            ID_EX_reg_write   <= ID_reg_write;
            ID_EX_alu_src     <= ID_alu_src;
            ID_EX_mem_read    <= ID_mem_read;
            ID_EX_mem_write   <= ID_mem_write;
            ID_EX_mem_to_reg  <= ID_mem_to_reg;
            ID_EX_alu_op      <= ID_alu_op;
        end
    end

    wire [63:0] EX_MEM_alu_result_wire;
    wire [4:0]  EX_MEM_rd_wire;
    wire        EX_MEM_reg_write_wire;
    wire [4:0]  MEM_WB_rd_wire;
    wire        MEM_WB_reg_write_wire;

    wire [1:0] ForwardA, ForwardB;

    forwarding_unit FWD_UNIT (
        .ID_EX_rs1       (ID_EX_rs1),
        .ID_EX_rs2       (ID_EX_rs2),
        .EX_MEM_rd       (EX_MEM_rd_wire),
        .EX_MEM_reg_write(EX_MEM_reg_write_wire),
        .MEM_WB_rd       (MEM_WB_rd_wire),
        .MEM_WB_reg_write(MEM_WB_reg_write_wire),
        .ForwardA        (ForwardA),
        .ForwardB        (ForwardB)
    );

    reg [63:0] alu_operand_a;
    always @(*) begin
        case (ForwardA)
            2'b10:   alu_operand_a = EX_MEM_alu_result_wire;
            2'b01:   alu_operand_a = WB_write_data;
            default: alu_operand_a = ID_EX_read_data1;
        endcase
    end

    reg [63:0] forwarded_rs2;
    always @(*) begin
        case (ForwardB)
            2'b10:   forwarded_rs2 = EX_MEM_alu_result_wire;
            2'b01:   forwarded_rs2 = WB_write_data;
            default: forwarded_rs2 = ID_EX_read_data2;
        endcase
    end

    wire [63:0] alu_operand_b = ID_EX_alu_src ? ID_EX_imm_gen_out : forwarded_rs2;

    wire [3:0] EX_alu_opcode;

    alu_control ALU_CTRL (
        .alu_op      (ID_EX_alu_op),
        .funct3      (ID_EX_funct3),
        .funct7_bit5 (ID_EX_funct7_b5),
        .alu_opcode  (EX_alu_opcode)
    );

    wire [63:0] EX_alu_result;
    wire        EX_zero_flag, EX_cout, EX_carry_flag, EX_overflow_flag;

    alu_64_bit ALU (
        .a             (alu_operand_a),
        .b             (alu_operand_b),
        .opcode        (EX_alu_opcode),
        .result        (EX_alu_result),
        .cout          (EX_cout),
        .carry_flag    (EX_carry_flag),
        .overflow_flag (EX_overflow_flag),
        .zero_flag     (EX_zero_flag)
    );

    reg [63:0] EX_MEM_alu_result;
    reg [63:0] EX_MEM_write_data;
    reg [4:0]  EX_MEM_rd;
    reg [4:0]  EX_MEM_rs2;
    reg        EX_MEM_reg_write;
    reg        EX_MEM_mem_read;
    reg        EX_MEM_mem_write;
    reg        EX_MEM_mem_to_reg;

    assign EX_MEM_alu_result_wire = EX_MEM_alu_result;
    assign EX_MEM_rd_wire         = EX_MEM_rd;
    assign EX_MEM_reg_write_wire  = EX_MEM_reg_write;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_alu_result <= 64'd0;
            EX_MEM_write_data <= 64'd0;
            EX_MEM_rd         <= 5'd0;
            EX_MEM_rs2        <= 5'd0;
            EX_MEM_reg_write  <= 1'b0;
            EX_MEM_mem_read   <= 1'b0;
            EX_MEM_mem_write  <= 1'b0;
            EX_MEM_mem_to_reg <= 1'b0;
        end else begin
            EX_MEM_alu_result <= EX_alu_result;
            EX_MEM_write_data <= forwarded_rs2;
            EX_MEM_rd         <= ID_EX_rd;
            EX_MEM_rs2        <= ID_EX_rs2;
            EX_MEM_reg_write  <= ID_EX_reg_write;
            EX_MEM_mem_read   <= ID_EX_mem_read;
            EX_MEM_mem_write  <= ID_EX_mem_write;
            EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
        end
    end

    wire [63:0] MEM_read_data;

    wire mem_to_mem_forward = EX_MEM_mem_write &&
                              MEM_WB_reg_write &&
                              MEM_WB_mem_to_reg &&
                              (EX_MEM_rs2 == MEM_WB_rd) &&
                              (MEM_WB_rd != 5'd0);

    wire [63:0] MEM_store_data = mem_to_mem_forward ? WB_write_data : EX_MEM_write_data;

    data_memory DMEM (
        .clk        (clk),
        .reset      (reset),
        .mem_read   (EX_MEM_mem_read),
        .mem_write  (EX_MEM_mem_write),
        .addr       (EX_MEM_alu_result),
        .write_data (MEM_store_data),
        .read_data  (MEM_read_data)
    );

    reg [63:0] MEM_WB_alu_result;
    reg [63:0] MEM_WB_mem_read_data;
    reg [4:0]  MEM_WB_rd;
    reg        MEM_WB_reg_write;
    reg        MEM_WB_mem_to_reg;

    assign MEM_WB_rd_wire        = MEM_WB_rd;
    assign MEM_WB_reg_write_wire = MEM_WB_reg_write;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_alu_result    <= 64'd0;
            MEM_WB_mem_read_data <= 64'd0;
            MEM_WB_rd            <= 5'd0;
            MEM_WB_reg_write     <= 1'b0;
            MEM_WB_mem_to_reg    <= 1'b0;
        end else begin
            MEM_WB_alu_result    <= EX_MEM_alu_result;
            MEM_WB_mem_read_data <= MEM_read_data;
            MEM_WB_rd            <= EX_MEM_rd;
            MEM_WB_reg_write     <= EX_MEM_reg_write;
            MEM_WB_mem_to_reg    <= EX_MEM_mem_to_reg;
        end
    end

    assign WB_write_data = MEM_WB_mem_to_reg ? MEM_WB_mem_read_data : MEM_WB_alu_result;
    assign WB_rd         = MEM_WB_rd;
    assign WB_reg_write  = MEM_WB_reg_write;

endmodule
