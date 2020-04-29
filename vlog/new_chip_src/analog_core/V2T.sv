module V2T #(
)(
input clk_v2t_e, 
input clk_v2t_eb, 
input clk_v2t, 
input clk_v2tb, 
input clk_v2t_l, 
input clk_v2t_lb, 
input clk_v2t_gated, 
input clk_v2tb_gated,
input Vin, 
input Vcal, 
input [31:0]  ctl,
output v2t_out
);
//synopsys dc_script_begin
// set_dont_touch {mid* *out* Vdch}
//synopsys dc_script_end

SW  ISW4 (  .OUT(CS_DRN), .CLK(clk_v2t_l), .CLKB(clk_v2t_lb), .IN(1'b1));
SW  ISW3 (  .OUT(CS_DRN), .CLK(clk_v2t_lb), .CLKB(clk_v2t_l), .IN(Vdch));
SW  ISW5 (  .OUT(1'b1), .CLK(clk_v2t_e), .CLKB(clk_v2t_eb), .IN(Vdch));
SW  ISW1 (  .OUT(Vch), .CLK(clk_v2t), .CLKB(clk_v2tb), .IN(Vin));
SW  ISW2 (  .OUT(Vch), .CLK(clk_v2tb_gated), .CLKB(clk_v2t_gated), .IN(1'b0));
MOMcap  IMOM ( .Cbot(Vdch), .Ctop(Vch) );
CS_cell  ICS_dont_touch[31:0] ( .CS_DRN(CS_DRN), .Vbias(Vcal), .CTRL(ctl));
CS_cell_dmm  ICSdmm_dont_touch[7:0] ();

n_or iinv_skewed (  .in1(Vdch), .in2(Vdch), .out(nor_out) );
inv iinv_buff1 (  .in(nor_out), .out(mid1) );
inv iinv_buff2 (  .in(mid1), .out(mid2) );
inv iinv_buff3 (  .in(mid2), .out(mid3) );
inv iinv_buff4 (  .in(mid3), .out(v2t_out) );

endmodule

