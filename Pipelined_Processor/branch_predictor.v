module branch_predictor #(
    parameter BHT_SIZE = 64,
    parameter BHT_BITS = 6
)(
    input             clk,
    input             reset,

    input      [63:0] pc_IF,
    output            predict_taken,
    output     [63:0] predict_target,
    output            btb_hit,

    input             update_en,
    input      [63:0] pc_update,
    input             actual_taken,
    input      [63:0] actual_target
);

    reg [1:0] BHT [0:BHT_SIZE-1];

    reg [63:0] BTB_target [0:BHT_SIZE-1];
    reg        BTB_valid  [0:BHT_SIZE-1];

    wire [BHT_BITS-1:0] index_IF     = pc_IF[BHT_BITS+1:2];
    wire [BHT_BITS-1:0] index_update = pc_update[BHT_BITS+1:2];

    assign predict_taken  = BHT[index_IF][1] & BTB_valid[index_IF];
    assign predict_target = BTB_target[index_IF];
    assign btb_hit        = BTB_valid[index_IF];

    integer i;
    initial begin
        for (i = 0; i < BHT_SIZE; i = i + 1) begin
            BHT[i] = 2'b01;
            BTB_target[i] = 64'd0;
            BTB_valid[i] = 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < BHT_SIZE; i = i + 1) begin
                BHT[i] <= 2'b01;
                BTB_target[i] <= 64'd0;
                BTB_valid[i] <= 1'b0;
            end
        end else if (update_en) begin

            BTB_target[index_update] <= actual_target;
            BTB_valid[index_update]  <= 1'b1;

            case (BHT[index_update])
                2'b00:
                    BHT[index_update] <= actual_taken ? 2'b01 : 2'b00;
                2'b01:
                    BHT[index_update] <= actual_taken ? 2'b10 : 2'b00;
                2'b10:
                    BHT[index_update] <= actual_taken ? 2'b11 : 2'b01;
                2'b11:
                    BHT[index_update] <= actual_taken ? 2'b11 : 2'b10;
            endcase
        end
    end

endmodule
