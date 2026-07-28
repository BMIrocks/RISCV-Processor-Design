module hazard_detection_unit (
    input       ID_EX_mem_read,
    input       ID_EX_reg_write,
    input [4:0] ID_EX_rd,
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    input       IF_ID_mem_write,
    input       IF_ID_branch,
    input       EX_MEM_reg_write,
    input [4:0] EX_MEM_rd,
    input       EX_MEM_mem_read,
    output      stall
);

    wire rs1_load_hazard = ID_EX_mem_read && (ID_EX_rd != 5'd0) && (ID_EX_rd == IF_ID_rs1);

    wire rs2_load_hazard = ID_EX_mem_read && (ID_EX_rd != 5'd0) && (ID_EX_rd == IF_ID_rs2) && !IF_ID_mem_write;

    wire load_use_stall = rs1_load_hazard || rs2_load_hazard;

    wire branch_ex_rs1 = IF_ID_branch && ID_EX_reg_write && (ID_EX_rd != 5'd0) && (ID_EX_rd == IF_ID_rs1);
    wire branch_ex_rs2 = IF_ID_branch && ID_EX_reg_write && (ID_EX_rd != 5'd0) && (ID_EX_rd == IF_ID_rs2);

    wire branch_mem_load_rs1 = IF_ID_branch && EX_MEM_mem_read && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == IF_ID_rs1);
    wire branch_mem_load_rs2 = IF_ID_branch && EX_MEM_mem_read && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == IF_ID_rs2);

    wire branch_stall = branch_ex_rs1 || branch_ex_rs2 || branch_mem_load_rs1 || branch_mem_load_rs2;

    assign stall = load_use_stall || branch_stall;

endmodule
