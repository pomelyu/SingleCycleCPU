module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

input      [5:0]   funct_i;
input      [1:0]   ALUOp_i;
output reg [2:0]   ALUCtrl_o;

always@(ALUOp_i or funct_i) begin
  case(ALUOp_i)
    2'b00 : ALUCtrl_o = 3'b010;
    2'b01 : ALUCtrl_o = 3'b110;
    2'b10 : ALUCtrl_o = 3'b001;
    2'b11 : begin
      case(funct_i[3:0])
        4'b0000 : ALUCtrl_o = 3'b010; // Add
        4'b0010 : ALUCtrl_o = 3'b110; // Subtract
        4'b0100 : ALUCtrl_o = 3'b000; // And
        4'b0101 : ALUCtrl_o = 3'b001; // Or
        4'b1010 : ALUCtrl_o = 3'b111; // Set less than
        4'b1000 : ALUCtrl_o = 3'b011; // mult
      endcase
    end
  endcase
  
end

endmodule