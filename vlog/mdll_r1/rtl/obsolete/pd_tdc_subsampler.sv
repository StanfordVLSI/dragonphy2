/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : pd_tdc_subsampler.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - This is a top block of a sub-sampling TDC. The purpose is to measure the period of the injection edge and an non-injection edge and take their difference.

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module pd_tdc_subsampler import mdll_pkg::*; #(
// parameters here
	parameter N_TDC = 10
) (
// I/Os here
	input clk_ref,	// a reference clock to latch sampled information
	input clk_0,	// a clock from dco, being sampled
	input clk_aux,	// sampling clock, async to clk_0
	input last_cycle_m1,
	output reg ss_update,	// latch phase difference between injecting 
							// and non-injecting edges; reset the 
							// accumulators as well
	output reg signed [N_TDC-1:0] ss_err_out	// phase error output 

);

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------

wire sample_rise, sample_fall;	// sampled values of clk_aux in a window
wire inc;				// increase accumulator by 1
wire ck_rise;
wire ck_fall;
wire update;

reg  [N_TDC-2:0] acc_inj, acc_noninj;	// accumulator regs	
reg  [N_TDC-2:0] cntr;					// counter to generatet a ss_update signal
wire [N_TDC-2:0] acc_inj_nxt, acc_noninj_nxt;	// accumulator adder
wire [N_TDC-2:0] cntr_nxt;				// cntr adder out
wire signed [N_TDC-1:0] acc_diff;		// acc_inj - acc_noninj


//---------------------
// INSTANTIATION
//---------------------

// masking clk_0 to create out* (ck_rise, ck_fall)

pd_tdc_clkgen uCLKGEN ( .clk_0(clk_0), .last_cycle_m1(last_cycle_m1), .ck_rise(ck_rise), .ck_fall(ck_fall) );

// two samplers

defparam usampler_rise.POSEDGE = 1;
defparam usampler_fall.POSEDGE = 1;

dff_sampler usampler_rise ( .clk(ck_rise), .d(clk_aux), .q(sample_rise), .qb() );
dff_sampler usampler_fall ( .clk(ck_fall), .d(clk_aux), .q(sample_fall), .qb() );


//---------------------
// COMBINATIONAL
//---------------------

// acc_diff: (+) means that injection period is wider than osc period,
// which means that osc period needs to be longer.  Thus increase delay.


assign inc = ~sample_rise & sample_fall;
assign acc_inj_nxt = ss_update ? '0 : (acc_inj + inc);
assign acc_noninj_nxt = update ? '0 : (acc_noninj + inc);
assign acc_diff = {1'b0,acc_inj} - {1'b0,acc_noninj};
assign cntr_nxt = cntr + 1;
assign update = (cntr_nxt == '1);


//---------------------
// SEQ
//---------------------

// # of ones of clk_aux for injection edge (errorneous) of clk_0
always @(negedge clk_ref) acc_inj <= acc_inj_nxt;

// # of ones of clk_aux for non-injection edge of clk_0
always @(posedge clk_ref) acc_noninj <= acc_noninj_nxt;

// counter to generate ss_update
always @(posedge clk_ref) cntr <= cntr_nxt;

// latch tdc output 
always @(posedge clk_ref) if (update) ss_err_out <= acc_diff;

// produce ss_update
always @(posedge clk_ref) ss_update <= update;


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

initial cntr = $urandom();

real tw_inj;
real tw_noninj;
real tr, tw;

always @(posedge ck_rise) tr = $realtime/1s;
always @(posedge ck_fall) tw = ($realtime/1s-tr);

always @(posedge clk_ref) tw_noninj = tw;
always @(negedge clk_ref) tw_inj = tw;

reg [12:0] cntr_avg;
real tdiff_sum;
real tdiff;
initial cntr_avg = 0;
logic update_x;
initial begin
	update_x = 1'b0;
	#800us;
	update_x = 1'b1;
end

real extra;
real delta;
real ss;
time ex;

let abs(x)= x>=0 ? x : -x;
let sgn(x) = x>=0 ? 1.0 : -1.0;

//always @(posedge clk_ref) cntr_avg <= cntr_avg + 1;
//always @(posedge clk_ref) begin
//	if (cntr_avg == 0) begin
//		tdiff = -tdiff_sum/2.0**13;
//		tdiff_sum = (tw_noninj-tw_inj);
//		if (update_x) begin
//			delta = tdiff/2**N_FBDIV/4;
//			extra += delta;
//			ex = abs(extra)*1s;
//			ss = sgn(extra);
//			extra -= ss*ex/1s;
//			tb_mdll_core.uDUT.uMOSC.uDCDL1.td_fine_add = ss*(ex/1s);
//			tb_mdll_core.uDUT.uMOSC.uDCDL2.td_fine_add = ss*(ex/1s);
//		end
//	end else begin
//		tdiff_sum += (tw_noninj-tw_inj);
//	end
//end

// synopsys translate_on

endmodule

