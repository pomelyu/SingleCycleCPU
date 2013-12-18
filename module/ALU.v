module ALU
(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o
);

input       [31:0]    data1_i, data2_i;
input       [2:0]     ALUCtrl_i;
output  reg [31:0]    data_o;

always@(ALUCtrl_i or data1_i or data2_i) begin
  case(ALUCtrl_i)
    3'b000 : data_o = data1_i & data2_i;
    3'b001 : data_o = data1_i | data2_i;
    3'b010 : data_o = data1_i + data2_i;
    3'b110 : data_o = data1_i - data2_i;
    3'b111 : data_o = (data1_i - data2_i < 0)? 1:0;
    3'b011 : data_o = data1_i * data2_i;
  endcase

end

endmodule
