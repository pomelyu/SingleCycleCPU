module EQ(
 data1_i , data2_i, zero_o
);

input       [31:0]    data1_i, data2_i;
output 	reg    zero_o;

always@(data1_i or data2_i) begin
  if((data1_i - data2_i == 0))
    zero_o = 1'b1;
  else
    zero_o = 1'b0;
end

endmodule
