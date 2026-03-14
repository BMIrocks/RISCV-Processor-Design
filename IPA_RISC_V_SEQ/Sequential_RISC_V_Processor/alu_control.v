module alu_control (
    input      [1:0] alu_op,
    input      [2:0] funct3,
    input            funct7_bit5,
    output reg [3:0] alu_opcode
);

    always @(*) begin
        case (alu_op)
            2'b00: begin
                alu_opcode = 4'b0000;
            end
            2'b01: begin
                alu_opcode = 4'b1000;
            end
            2'b10: begin
                case (funct3)
                    3'b000: alu_opcode = funct7_bit5 ? 4'b1000 : 4'b0000;
                    3'b001: alu_opcode = 4'b0001;
                    3'b010: alu_opcode = 4'b0010;
                    3'b011: alu_opcode = 4'b0011;
                    3'b100: alu_opcode = 4'b0100;
                    3'b101: alu_opcode = funct7_bit5 ? 4'b1101 : 4'b0101;
                    3'b110: alu_opcode = 4'b0110;
                    3'b111: alu_opcode = 4'b0111;
                    default: alu_opcode = 4'b0000;
                endcase
            end

            default: begin
                alu_opcode = 4'b0000;
            end
        endcase
    end

endmodule
