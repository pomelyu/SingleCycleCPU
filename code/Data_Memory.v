module Data_Memory(
    addr_i,
    WriteData_i,
    MemWrite_i,
    MemRead_i,
    ReadData_o
);

input       [31:0]  addr_i, WriteData_i;
input               MemWrite_i, MemRead_i;
output  reg [31:0]  ReadData_o;

// Data memory
reg       [31:0]  memory[0:7]; 

always@(addr_i or WriteData_i or MemWrite_i or MemRead_i)#5 begin

if (MemWrite_i == 1'b1)
  memory[addr_i] = WriteData_i;

if (MemRead_i == 1'b1)
  ReadData_o = memory[addr_i];
  
end

endmodule
