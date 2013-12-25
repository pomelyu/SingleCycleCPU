module ID_EX(
  clk,
  inst_i, inst_o,
  sign_ext_i, sign_ext_o,
  data1_i,data1_o,
  data2_i,data2_o,
  
  MemToReg_i, MemToReg_o,
  RegWrite_i, RegWrite_o,
  MemWrite_i, MemWrite_o,
  MemRead_i, MemRead_o,
  ALUsrc_i, ALUsrc_o,
  ALUop_i, ALUop_o,
  regDst_i, regDst_o,
  
  stall_i
);
  input clk;
  input [31:0] inst_i;
  input [31:0] sign_ext_i;
  input [31:0] data1_i;
  input [31:0] data2_i;
  output [31:0] data2_o;
  output [31:0] data1_o;
  output [31:0] sign_ext_o;
  output [31:0] inst_o;
  
  reg [31:0] data2_o;
  reg [31:0] data1_o;
  reg [31:0] sign_ext_o;  
  reg [31:0] inst_o;
//===== WB stage ======/
  input MemToReg_i;
  output MemToReg_o;
  reg MemToReg_o;
  
  input RegWrite_i;
  output RegWrite_o;
  reg RegWrite_o;
//===== Memory stage =====/
  input MemWrite_i;
  output MemWrite_o;
  reg MemWrite_o;
  
  input MemRead_i;
  output MemRead_o;
  reg MemRead_o;
//===== EX stage ========/ 
  input ALUsrc_i;
  output ALUsrc_o;
  reg ALUsrc_o;
  
  input [1:0] ALUop_i;
  output [1:0] ALUop_o;
  reg [1:0] ALUop_o;
  
  input regDst_i;
  output regDst_o;
  reg regDst_o;
  
  
  input stall_i;
  
always@(posedge clk) begin
  if(stall_i) begin
  inst_o <= inst_o;
  sign_ext_o <= sign_ext_o;
  data1_o <= data1_o;
  data2_o <= data2_o;
  
  MemToReg_o <= MemToReg_o;
  RegWrite_o <= RegWrite_o;
  MemWrite_o <= MemWrite_o;
  MemRead_o  <= MemRead_o;
  ALUsrc_o   <= ALUsrc_o;
  ALUop_o    <= ALUop_o;
  regDst_o   <= regDst_o;
  end
  else begin
  inst_o <= inst_i;
  sign_ext_o <= sign_ext_i;
  data1_o <= data1_i;
  data2_o <= data2_i;
  
  MemToReg_o <= MemToReg_i;
  RegWrite_o <= RegWrite_i;
  MemWrite_o <= MemWrite_i;
  MemRead_o  <= MemRead_i;
  ALUsrc_o   <= ALUsrc_i;
  ALUop_o    <= ALUop_i;
  regDst_o   <= regDst_i;
  end
end

endmodule
