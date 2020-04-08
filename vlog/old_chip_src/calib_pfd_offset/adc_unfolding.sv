/********************************************************************
filename: stochastic_adc.sv

Description: 
Unfold adc out. This includes calibration logic. Need to be synthesized

Assumptions:

Todo:

********************************************************************/


`default_nettype none

module adc_unfolding import const_pack::*; (
	input wire logic clk_retimer,
	input wire logic rstb,
	input wire logic clk_avg,   // divided clock of clk ???
	//input wire logic signed [Nadc-1:0] din, I am not sure this should be signed
	input wire logic [Nadc-1:0] din,
	input wire logic sign_out,
	
	input wire logic en_pfd_cal,
	input wire logic en_ext_pfd_offset,
	input wire logic [Nadc-1:0] ext_pfd_offset,
	input wire logic [Nrange-1:0] Nbin,
	input wire logic [Nrange-1:0] Navg,
	input wire logic [Nrange-1:0] DZ,
	
	output reg signed [Nadc-1:0] dout,
	output reg signed [Nadc-1:0] dout_avg,
	output reg signed [Nadc+2**Nrange-1:0] dout_sum,
	output reg  [2**Nrange-1:0] hist_center,
	output reg  [2**Nrange-1:0] hist_side,
	output reg signed [Nadc-1:0] pfd_offset
);

// wires, regs
wire signed [1:0] hist_comp_out;
wire signed [Nadc-1:0] pfd_offset_pre;
wire signed [Nadc:0]  dout_pre1a, dout_pre2a, dout_pre1b, dout_pre2b;
wire signed [Nadc-1:0] dout_pre;
wire signed [Nadc-1:0] pfd_offset_add_hist_comp_out;
wire update;

reg [1:0] clk_avg_d;

// detect posedge of clk_avg
always @(posedge clk_retimer) clk_avg_d <= clk_avg;


assign update = ({clk_avg_d,clk_avg} == 2'b01) ; 


// instances
calib_sample_avg iavg(
.rstb(rstb), 
.din(dout), 
.clk(clk_retimer), 
.update(update), 
.Navg(Navg), 
.avg_out(dout_avg), 
.sum_out(dout_sum) 
);

calib_hist_measure ihist(
.rstb(rstb), 
.din(dout), 
.din_avg(dout_avg), 
.clk(clk_retimer), 
.update(update), 
.Nbin(Nbin),
.DZ(DZ), 
.hist_center(hist_center), 
.hist_side(hist_side), 
.hist_comp_out(hist_comp_out) 
); 


// pfd offset estimation
assign pfd_offset_add_hist_comp_out = pfd_offset + hist_comp_out; //this needs to saturate
assign pfd_offset_pre = en_pfd_cal ? pfd_offset_add_hist_comp_out : ext_pfd_offset;

always @(posedge clk_retimer, negedge rstb) 
	if (~rstb) pfd_offset <= '0;
	else if (update) pfd_offset <= pfd_offset_pre;


// output unfolding
assign dout_pre1a = sign_out ? (din - ext_pfd_offset) : (ext_pfd_offset - din);
assign dout_pre2a = sign_out ? (din - pfd_offset) : (pfd_offset - din);
assign dout_pre1b = (dout_pre1a > +9'sd127) ? +9'sd127 :  ((dout_pre1a < -9'sd128) ? -9'sd128 : dout_pre1a);
assign dout_pre2b = (dout_pre2a > +9'sd127) ? +9'sd127 :  ((dout_pre2a < -9'sd128) ? -9'sd128 : dout_pre2a);
assign dout_pre = en_ext_pfd_offset ? dout_pre1b[7:0] : dout_pre2b[7:0];

always @(posedge clk_retimer) 
    dout <= dout_pre;


endmodule

`default_nettype wire
