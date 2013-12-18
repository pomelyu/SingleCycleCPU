module Hazard_Detection_Unit
(
    IDEX_MemRead,
    IDEX_RegisterRt,
    IFID_RegisterRs,
    IFID_RegisterRt,
    PC_Write,
    IFID_Write,
    Control_select
);

input             IDEX_MemRead;
input   [4:0]     IDEX_RegisterRt, IFID_RegisterRs, IFID_RegisterRt;
output     reg       PC_Write, IFID_Write, Control_select;

initial begin
    PC_Write=1;
    IFID_Write=1;
    Control_select=0;
end

always@(IDEX_MemRead or IDEX_RegisterRt or IFID_RegisterRs or IFID_RegisterRt) begin
  if((IDEX_MemRead==1) & ((IDEX_RegisterRt==IFID_RegisterRs) | (IDEX_RegisterRt==IFID_RegisterRt)))
  begin
    // stall the pipeline
    // zero of PC_Write & IFID_Write means use old value(don't write)??
    // zero of Control_select means let mux8 choose 0
    PC_Write=0;
    IFID_Write=0;
    Control_select=1;
  end
  else begin
    // don't stall
    // one of PC_Write & IFID_Write means use new value??
    // one of Control_select means let mux8 choose the value from control
    PC_Write=1;
    IFID_Write=1;
    Control_select=0;
  end
end

endmodule

// referenced by the course slide
// chapter 7 p.23~p.25