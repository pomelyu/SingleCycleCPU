module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire    [31:0]     inst, inst_addr_pc, inst_addr_add, dataToMem;
wire    [31:0]     ALU_result, signExtend_out, Jump_addr;


// ====== For Cotrol ====== //
Control Control(
    .Op_i       (inst[31:26]),
    .RegDst_o   (MUX_RegDst.select_i),
    .Jump_o     (MUX_Jump.select_i),
    .Branch_o   (AND_Branch.data1_i),
    .MemRead_o  (Data_Memory.MemRead_i),
    .MemToReg_o (MUX_MemToReg.select_i),    
    .ALUOp_o    (ALU_Control.ALUOp_i),
    .MemWrite_o (Data_Memory.MemWrite_i),
    .ALUSrc_o   (MUX_ALUSrc.select_i),
    .RegWrite_o (Registers.RegWrite_i)
);


// ====== For PC ====== //
PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (MUX_Branch.data_o),
    .pc_o       (inst_addr_pc)
);

Adder Add_PC(
    .data1_i    (inst_addr_pc),
    .data2_i    (32'd4),
    .data_o     (inst_addr_add)
);

MUX32 MUX_Branch(
    .data1_i    (inst_addr_add),
    .data2_i    (Add_Branch.data_o),
    .select_i   (AND_Branch.data_o),
    .data_o     (MUX_Jump.data1_i)
);

MUX32 MUX_Jump(
    .data1_i    (MUX_Branch.data_o),
    .data2_i    ({inst_addr_add[31:28], Jump_addr[27:0]}),
    .select_i   (Control.Jump_o),
    .data_o     (PC.pc_i)
);


// ====== For branch ===== //
Adder Add_Branch(
    .data1_i    (inst_addr_add),
    .data2_i    (Shift_Branch.data_o),
    .data_o     (MUX_Branch.data2_i)
);

ShiftLeft2 Shift_Branch(
    .data_i     (signExtend_out),
    .data_o     (Add_Branch.data2_i)
);

AND AND_Branch(
    .data1_i    (Control.Branch_o),
    .data2_i    (ALU.Zero_o),
    .data_o     (MUX_Branch.select_i)
);


// ====== For jump ====== //
ShiftLeft2 Shift_Jump(
    .data_i    ({6'b000000, inst[25:0]}),
    .data_o    (Jump_addr)
);


// ====== For registers ====== // 
Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr_pc), 
    .instr_o    (inst)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]),
    .RTaddr_i   (inst[20:16]),
    .RDaddr_i   (MUX_RegDst.data_o), 
    .RDdata_i   (MUX_MemToReg.data_o),
    .RegWrite_i (Control.RegWrite_o), 
    .RSdata_o   (ALU.data1_i), 
    .RTdata_o   (dataToMem) 
);

MUX5 MUX_RegDst(
    .data1_i    (inst[20:16]),
    .data2_i    (inst[15:11]),
    .select_i   (Control.RegDst_o),
    .data_o     (Registers.RDaddr_i)
);

MUX32 MUX_ALUSrc(
    .data1_i    (dataToMem),
    .data2_i    (signExtend_out),
    .select_i   (Control.ALUSrc_o),
    .data_o     (ALU.data2_i)
);

Signed_Extend Signed_Extend(
    .data_i     (inst[15:0]),
    .data_o     (signExtend_out)
);

  
// ====== For ALU ====== //
ALU ALU(
    .data1_i    (Registers.RSdata_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (ALU_result),
    .Zero_o     (AND_Branch.data2_i)
);

ALU_Control ALU_Control(
    .funct_i    (inst[5:0]),
    .ALUOp_i    (Control.ALUOp_o),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);


// ====== For data memory ====== // 
Data_Memory Data_Memory(
    .addr_i       (ALU_result),
    .WriteData_i  (dataToMem),
    .MemWrite_i   (Control.MemWrite_o),
    .MemRead_i    (Control.MemRead_o),
    .ReadData_o   (MUX_MemToReg.data2_i)
);

MUX32 MUX_MemToReg(
    .data1_i    (ALU_result),
    .data2_i    (Data_Memory.ReadData_o),
    .select_i   (Control.MemToReg_o),
    .data_o     (Registers.RDdata_i)
);

endmodule

