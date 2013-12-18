module MEM_WB(
  clk,
  MemToReg_o, MemToReg_i,
  RegWrite_o, RegWrite_i,
  
  ReadData_o, ReadData_i,
  ALUresult_o, ALUresult_i,
  InstDst_o, InstDst_i
);
  input clk;
  input [31:0] ReadData_i;
  output [31:0] ReadData_o;
  reg [31:0] ReadData_o;
  
  input [31:0] ALUresult_i;
  output [31:0] ALUresult_o;
  reg [31:0] ALUresult_o;
  
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
  
always@(posedge clk) begin
   ReadData_o <= ReadData_i;
   ALUresult_o <= ALUresult_i;
   InstDst_o   <=  InstDst_i;

   MemToReg_o <= MemToReg_i;
   RegWrite_o <= RegWrite_i;
end  

endmodule
