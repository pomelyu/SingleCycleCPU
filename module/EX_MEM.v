module EX_MEM(
  clk,
  ALUresult_o, ALUresult_i,
  WriteData_o, WriteData_i,
  InstDst_o, InstDst_i,
  
  MemToReg_o, MemToReg_i,
  RegWrite_o, RegWrite_i,
  MemWrite_o, MemWrite_i,
  MemRead_o, MemRead_i,
  
  stall_i
);
  input  clk;
  input [31:0] ALUresult_i;
  output [31:0] ALUresult_o;
  reg [31:0] ALUresult_o;
  
   input [31:0] WriteData_i;
  output [31:0] WriteData_o; 
  reg [31:0] WriteData_o;
  
  input [4:0] InstDst_i;
  output [4:0] InstDst_o;
  reg [4:0] InstDst_o;
  
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
  
  
  input stall_i;
  
always@(posedge clk) begin
  if(stall_i) begin
  ALUresult_o <= ALUresult_o;
  WriteData_o <=  WriteData_o;
  InstDst_o   <=  InstDst_o;

  MemToReg_o <= MemToReg_o;
  RegWrite_o <= RegWrite_o;
  MemWrite_o <= MemWrite_o;
  MemRead_o  <= MemRead_o;
  end
  else begin
  ALUresult_o <= ALUresult_i;
  WriteData_o <=  WriteData_i;
  InstDst_o   <=  InstDst_i;

  MemToReg_o <= MemToReg_i;
  RegWrite_o <= RegWrite_i;
  MemWrite_o <= MemWrite_i;
  MemRead_o  <= MemRead_i;
  end
end
endmodule
