/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_feedback_div.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Feedback divider of the MDLL.

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_feedback_div import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
    input osc_0,        // I clock before mux
    input [$clog2(N_DIV):0] ndiv, // 2**ndiv feedback divider ratio
    input [$clog2(N_DIV)-1:0] sel_sdm_clk, // select SDM clock
	output reg clk_fb,		// feedback divided clock output
    output reg clk_sdm, // SDM clock
    output reg last_cycle,	// the last cycle of osc_0 (before rising edge of clk_fb)
	output clk_fb_mon	// feedback clock monitor for RJ measurement
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

reg osc_0_div2;

wire [N_DIV-2:0] cntr; // counter outputs from the feedback divider
wire clk_sdm_pre;
wire [$clog2(N_DIV-1):0] ndiv_m1;
wire clk_fb_pre;
wire last_cycle_pre;

//---------------------
// INSTANTIATION
//---------------------

// feedback frequency divider
defparam uDIV.N = (N_DIV-1);
mdll_freq_div_radix2 uDIV ( .cki(osc_0_div2), .ndiv(ndiv_m1), .cko(clk_fb_pre), .cntr(cntr), .ckob() );

// monitoring output

// synopsys dc_script_begin
// set_dont_touch uCLK_FB_MON
// synopsys dc_script_end

mdll_inv_x4 uCLK_FB_MON ( .A(clk_fb), .ZN(clk_fb_mon) );

//---------------------
// COMBINATIONAL
//---------------------

assign ndiv_m1 = ndiv - 1;
assign last_cycle_pre = ~osc_0_div2 & (&cntr) ;
assign clk_sdm_pre = (sel_sdm_clk=='0)? osc_0_div2 : cntr[sel_sdm_clk-1];


//---------------------
// SEQ
//---------------------

always @(posedge osc_0) osc_0_div2 <= ~osc_0_div2;  // divided by two
always @(posedge osc_0) clk_fb <= clk_fb_pre;
always @(posedge osc_0) last_cycle <= last_cycle_pre;
always @(posedge osc_0) clk_sdm <= clk_sdm_pre;

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

initial osc_0_div2 = $urandom();
initial clk_fb = $urandom();

// synopsys translate_on

endmodule

