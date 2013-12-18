module Forwarding_Unit
(
    EXMEM_RegWrite,
    MEMWB_RegWrite,
    EXMEM_RegisterRd,
    MEMWB_RegisterRd,
    IDEX_RegisterRs,
    IDEX_RegisterRt,
    ForwardA,
    ForwardB
);

input             EXMEM_RegWrite, MEMWB_RegWrite;
input   [4:0]     EXMEM_RegisterRd, MEMWB_RegisterRd, IDEX_RegisterRs, IDEX_RegisterRt;
output  reg [1:0]     ForwardA, ForwardB;

always@(EXMEM_RegWrite or MEMWB_RegWrite or EXMEM_RegisterRd or MEMWB_RegisterRd or IDEX_RegisterRs or IDEX_RegisterRt) begin
  if((EXMEM_RegWrite==1) & (EXMEM_RegisterRd!=0) & (EXMEM_RegisterRd==IDEX_RegisterRs))
    ForwardA=2'b10;
  else if((MEMWB_RegWrite==1) & (MEMWB_RegisterRd!=0) & (MEMWB_RegisterRd==IDEX_RegisterRs))
    ForwardA=2'b01;
  else
    ForwardA=2'b00;
    
  if((EXMEM_RegWrite==1) & (EXMEM_RegisterRd!=0) & (EXMEM_RegisterRd==IDEX_RegisterRt))
    ForwardB=2'b10;
  else if((MEMWB_RegWrite==1) & (MEMWB_RegisterRd!=0) & (MEMWB_RegisterRd==IDEX_RegisterRt))
    ForwardB=2'b01;
  else
    ForwardB=2'b00;
end

endmodule

// referenced by the course slide
// chapter 7 p.12