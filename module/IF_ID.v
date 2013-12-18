module IF_ID(
  clk,inst_addr_add_i, inst_i, inst_addr_add_o, inst_o, IFID_Write_i,Flush_i
);
input clk;
input	[31:0] inst_addr_add_i;
input   [31:0] inst_i;
input  IFID_Write_i;
input   Flush_i;

output  [31:0] inst_addr_add_o;
output  [31:0] inst_o;
reg [31:0] inst_addr_add_o;
reg [31:0] inst_o;


always@(posedge clk) begin
  if(IFID_Write_i) begin
    inst_addr_add_o <= inst_addr_add_i;
    inst_o <= inst_i;
  end
   else begin
    inst_addr_add_o <= inst_addr_add_o;
    inst_o <= inst_o;
   end	

  if(Flush_i) begin
    inst_addr_add_o <= 32'b0;
    inst_o <= 32'b0;
    end	
end



endmodule

