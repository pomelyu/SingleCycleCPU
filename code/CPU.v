module CPU
(
    clk_i, 
    rst_i,
    start_i,
    
    mem_data_i, 
	  mem_ack_i, 	
	  mem_data_o, 
	  mem_addr_o, 	
	  mem_enable_o, 
	  mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

//
// to Data Memory interface		
//
input	[255:0]	mem_data_i; 
input				mem_ack_i; 	
output	[255:0]	mem_data_o; 
output	[31:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 

wire    stall;


wire    [31:0]     inst, inst_addr_pc, inst_addr_add, inst_EX;
wire    [31:0]     ALU_result, signExtend_out, dataToMem;
wire    [7:0]      ctrl_signal;

// ====== For Cotrol ====== //
Control Control(
    .Op_i       (inst[31:26]),
    .RegDst_o   (MUX8.data1_i[7]),
    .Jump_o     (MUX_Jump.select_i),
    .Branch_o   (AND_Branch.data1_i),
    .MemRead_o  (MUX8.data1_i[3]),
    .MemToReg_o (MUX8.data1_i[0]),    
    .ALUOp_o    (MUX8.data1_i[6:5]),
    .MemWrite_o (MUX8.data1_i[2]),
    .ALUSrc_o   (MUX8.data1_i[4]),
    .RegWrite_o (MUX8.data1_i[1])
);

MUX8 MUX8(
  .data1_i({Control.RegDst_o, Control.ALUOp_o, Control.ALUSrc_o, Control.MemRead_o, Control.MemWrite_o, Control.RegWrite_o, Control.MemToReg_o}),
  .data2_i(8'b00000000),
  .select_i(Hazard_Detection_Unit.Control_select),   
  .data_o(ctrl_signal)  
);
// ====== Hazard Detection Unit ====== //

Hazard_Detection_Unit Hazard_Detection_Unit(
    .IDEX_MemRead(ID_EX.MemRead_o),
    .IDEX_RegisterRt(inst_EX[20:16]),
    .IFID_RegisterRs(inst[25:21]),
    .IFID_RegisterRt(inst[20:16]),
    .PC_Write(PC.enable_i),
    .IFID_Write(IF_ID.IFID_Write_i),
    .Control_select(MUX8.select_i)
);
// ====== For PC ====== //
PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (MUX_Jump.data_o),
    .pc_o       (inst_addr_pc),
	.enable_i	(Hazard_Detection_Unit.PC_Write),
	.stall_i	(stall)
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
    .data2_i    (Shift_Jump.data_o),
    .select_i   (Control.Jump_o),
    .data_o     (PC.pc_i)
);


// ====== For branch ===== //
Adder Add_Branch(
    .data1_i    (IF_ID.inst_addr_add_o),
    .data2_i    (Shift_Branch.data_o),
    .data_o     (MUX_Branch.data2_i)
);

ShiftLeft2 Shift_Branch(
    .data_i     (signExtend_out),
    .data_o     (Add_Branch.data2_i)
);

AND AND_Branch(
    .data1_i    (Control.Branch_o),
    .data2_i    (EQ.zero_o),
    .data_o     (MUX_Branch.select_i)
);


// ====== For jump ====== //
ShiftLeft2 Shift_Jump(
    .data_i    ({2'b00, inst_addr_add[31:28], inst[25:0]}),
    .data_o    (MUX_Jump.data2_i)
);

// ====== IF_ID flip-flop =======//
OR OR(
  .data1_i(Control.Jump_o),
  .data2_i(AND_Branch.data_o),
  .data_o(IF_ID.Flush_i)
);
IF_ID IF_ID(
  .clk(clk_i),
  .inst_addr_add_i	(inst_addr_add),
  .inst_i (Instruction_Memory.instr_o),
  .inst_addr_add_o (Add_Branch.data1_i),
  .inst_o	(inst),
  .IFID_Write_i(Hazard_Detection_Unit.IFID_Write),
  .Flush_i(OR.data_o),
  .stall_i(stall)
);

// ====== For registers ====== // 
Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr_pc), 
    .instr_o    (IF_ID.inst_i)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]),
    .RTaddr_i   (inst[20:16]),
    .RDaddr_i   (MEM_WB.InstDst_o), 
    .RDdata_i   (MUX_MemToReg.data_o),
    .RegWrite_i (MEM_WB.RegWrite_o), 
    .RSdata_o   (ID_EX.data1_i), 
    .RTdata_o   (ID_EX.data2_i) 
);

MUX5 MUX_RegDst(
    .data1_i    (inst_EX[20:16]),
    .data2_i    (inst_EX[15:11]),
    .select_i   (ID_EX.regDst_o),
    .data_o     (EX_MEM.InstDst_i)
);

MUX32 MUX_ALUSrc(
    .data1_i    (mux7.data_o),
    .data2_i    (ID_EX.sign_ext_o),
    .select_i   (ID_EX.ALUsrc_o),
    .data_o     (ALU.data2_i)
);

Signed_Extend Signed_Extend(
    .data_i     (inst[15:0]),
    .data_o     (signExtend_out)
);

EQ EQ(
  .data1_i (Registers.RSdata_o),
  .data2_i (Registers.RTdata_o),
  .zero_o(AND_Branch.data2_i)
);
// ====== ID_EX flip-flop ======//
ID_EX ID_EX(
  .clk(clk_i),
  .inst_i(inst), .inst_o(inst_EX),
  .sign_ext_i(signExtend_out), .sign_ext_o(MUX_ALUSrc.data2_i),
  .data1_i(Registers.RSdata_o), .data1_o(mux6.data1_i),
  .data2_i(Registers.RTdata_o), .data2_o(mux7.data1_i),
  
  .MemToReg_i(ctrl_signal[0]), .MemToReg_o(EX_MEM.MemToReg_i),
  .RegWrite_i(ctrl_signal[1]), .RegWrite_o(EX_MEM.RegWrite_i),
  .MemWrite_i(ctrl_signal[2]), .MemWrite_o(EX_MEM.MemWrite_i),
  .MemRead_i(ctrl_signal[3]), .MemRead_o(EX_MEM.MemRead_i),
  .ALUsrc_i(ctrl_signal[4]), .ALUsrc_o(MUX_ALUSrc.select_i),
  .ALUop_i(ctrl_signal[6:5]), .ALUop_o(ALU_Control.ALUOp_i),
  .regDst_i(ctrl_signal[7]), .regDst_o(MUX_RegDst.select_i),
  
  .stall_i(stall)
);
// ====== EX_MEM flip-flop ======//
EX_MEM EX_MEM(
  .clk(clk_i),
  .ALUresult_o(dcache.p1_addr_i), .ALUresult_i(ALU.data_o),
  .WriteData_o(dcache.p1_data_i), .WriteData_i(mux7.data_o),
  .InstDst_o(MEM_WB.InstDst_i), .InstDst_i(MUX_RegDst.data_o),
  
  .MemToReg_o(MEM_WB.MemToReg_i), .MemToReg_i(ID_EX.MemToReg_o),
  .RegWrite_o(MEM_WB.RegWrite_i), .RegWrite_i(ID_EX.RegWrite_o),
  .MemWrite_o(dcache.p1_MemWrite_i), .MemWrite_i(ID_EX.MemWrite_o),
  .MemRead_o(dcache.p1_MemRead_i), .MemRead_i(ID_EX.MemRead_o),
  
  .stall_i(stall)
);
// ====== MEM_WB flip-flop ======//
MEM_WB MEM_WB(
  .clk(clk_i),
  .MemToReg_o(MUX_MemToReg.select_i), .MemToReg_i(EX_MEM.MemToReg_o),
  .RegWrite_o(Registers.RegWrite_i), .RegWrite_i(EX_MEM.RegWrite_o),
  
  .ReadData_o(MUX_MemToReg.data2_i), .ReadData_i(dcache.p1_data_o),
  .ALUresult_o(MUX_MemToReg.data1_i), .ALUresult_i(EX_MEM.ALUresult_o),
  .InstDst_o(Forwarding_Unit.MEMWB_RegisterRd), .InstDst_i(EX_MEM.InstDst_o),
  
  .stall_i(stall)
);
// ====== Forwarding Unit ======//
Forwarding_Unit Forwarding_Unit(
    .EXMEM_RegWrite(EX_MEM.RegWrite_o),
    .MEMWB_RegWrite(MEM_WB.RegWrite_o),
    .EXMEM_RegisterRd(EX_MEM.InstDst_o),
    .MEMWB_RegisterRd(MEM_WB.InstDst_o),
    .IDEX_RegisterRs(inst_EX[25:21]),
    .IDEX_RegisterRt(inst_EX[20:16]),
    .ForwardA(mux6.select_i),
    .ForwardB(mux7.select_i)
);

// ====== For ALU ====== //
MUX_Forward mux6(
    .data1_i(ID_EX.data1_o),
    .data2_i(MUX_MemToReg.data_o),
	.data3_i(EX_MEM.ALUresult_o),
    .select_i(Forwarding_Unit.ForwardA),
    .data_o(ALU.data1_i)
);
MUX_Forward mux7(
    .data1_i(ID_EX.data2_o),
    .data2_i(MUX_MemToReg.data_o),
	.data3_i(EX_MEM.ALUresult_o),
    .select_i(Forwarding_Unit.ForwardB),
    .data_o(MUX_ALUSrc.data1_i)
);

ALU ALU(
    .data1_i    (mux6.data_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (EX_MEM.ALUresult_i)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX.sign_ext_o[5:0]),
    .ALUOp_i    (ID_EX.ALUop_o),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);




//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o), 
	
	// to CPU interface	
	.p1_data_i(EX_MEM.WriteData_o), 
	.p1_addr_i(EX_MEM.ALUresult_o), 	
	.p1_MemRead_i(EX_MEM.MemRead_o), 
	.p1_MemWrite_i(EX_MEM.MemWrite_o), 
	.p1_data_o(MEM_WB.ReadData_i), 
	.p1_stall_o(stall)
);


MUX32 MUX_MemToReg(
    .data1_i    (MEM_WB.ALUresult_o),
    .data2_i    (MEM_WB.ReadData_o),
    .select_i   (MEM_WB.MemToReg_o),
    .data_o     (Registers.RDdata_i)
);

endmodule

