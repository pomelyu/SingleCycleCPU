module Control
(
    Op_i,
    RegDst_o,
    Jump_o,
    Branch_o,
    MemRead_o,
    MemToReg_o,
    ALUOp_o,
    MemWrite_o,
    ALUSrc_o,
    RegWrite_o
);

input      [5:0]   Op_i;
output reg [1:0]   ALUOp_o;
output reg         RegDst_o, Jump_o, Branch_o, MemRead_o;
output reg         MemToReg_o, MemWrite_o, ALUSrc_o, RegWrite_o;

always@(Op_i) begin
  case(Op_i)
    // R-type
    6'b000000 : begin
      RegDst_o    = 1'b1;
      ALUSrc_o    = 1'b0;
      MemToReg_o  = 1'b0;
      RegWrite_o  = 1'b1;
      MemWrite_o  = 1'b0;
      MemRead_o   = 1'b0;
      Branch_o    = 1'b0;
      Jump_o      = 1'b0;
      ALUOp_o     = 2'b11;          
    end
    
    // addi
    6'b001000 :  begin
      RegDst_o    = 1'b0;
      ALUSrc_o    = 1'b1;
      MemToReg_o  = 1'b0;
      RegWrite_o  = 1'b1;
      MemWrite_o  = 1'b0;
      MemRead_o   = 1'b0;
      Branch_o    = 1'b0;
      Jump_o      = 1'b0;
      ALUOp_o     = 2'b00;    
    end
    
    // lw
    6'b100011 :  begin
      RegDst_o    = 1'b0;
      ALUSrc_o    = 1'b1;
      MemToReg_o  = 1'b1;
      RegWrite_o  = 1'b1;
      MemWrite_o  = 1'b0;
      MemRead_o   = 1'b1;
      Branch_o    = 1'b0;
      Jump_o      = 1'b0;
      ALUOp_o     = 2'b00;  
    end
    
    // sw
    6'b101011 :  begin
      RegDst_o    = 1'bx;
      ALUSrc_o    = 1'b1;
      MemToReg_o  = 1'bx;
      RegWrite_o  = 1'b0;
      MemWrite_o  = 1'b1;
      MemRead_o   = 1'b0;
      Branch_o    = 1'b0;
      Jump_o      = 1'b0;
      ALUOp_o     = 2'b00; 
    end
    
    // beq
    6'b000100 :  begin
      RegDst_o    = 1'bx;
      ALUSrc_o    = 1'b0;
      MemToReg_o  = 1'bx;
      RegWrite_o  = 1'b0;
      MemWrite_o  = 1'b0;
      MemRead_o   = 1'b0;
      Branch_o    = 1'b1;
      Jump_o      = 1'b0;
      ALUOp_o     = 2'b01; 
    end
    
    // jump
    6'b000100 :  begin
      RegDst_o    = 1'bx;
      ALUSrc_o    = 1'bx;
      MemToReg_o  = 1'bx;
      RegWrite_o  = 1'b0;
      MemWrite_o  = 1'b0;
      MemRead_o   = 1'b0;
      Branch_o    = 1'b0;
      Jump_o      = 1'b1;
      ALUOp_o     = 2'bxx; 
    end
    
    // default
    default : begin
      RegDst_o    = 1'bx;
      ALUSrc_o    = 1'bx;
      MemToReg_o  = 1'bx;
      RegWrite_o  = 1'bx;
      MemWrite_o  = 1'bx;
      MemRead_o   = 1'bx;
      Branch_o    = 1'bx;
      Jump_o      = 1'bx;
      ALUOp_o     = 2'bxx; 
    end
    
  endcase
end

endmodule