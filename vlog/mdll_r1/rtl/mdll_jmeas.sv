/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_jmeas.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Jitter measurement by sweeping samping clock phase

* Note       :
  - CVDD domain

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_jmeas import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
	input clk_monp,     //(+) clk for jitter measurement
	input clk_monn,     //(-) clk for jitter measurement
    input en_monitor,   // enable jitter monitor circuit (active high)
    input [2:0] jm_sel_clk,    // select clock being measured
	input jm_bb_out_pol,	// 1: take the internal bb_out_mon as it is, 0: invert it
    input osc_0,            // I clock for jitter measurement
    input osc_90,           // Q clock for jitter measurement
    input osc_180,          // /I clock for jitter measurement
    input osc_270,          // /Q clock for jitter measurement
    input clk_fb_mon,       // 1/32 feedback clock to jitter measurement module
    output jm_clk_fb_out,   // 1/32 feedback clock output for direct jitter measurement by sampling scope
	output [N_JIT_CNT-1:0] jm_cdf_out // 
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire bb_out_mon;	// bang-bang pd output for measurement (early, thus increase delay)
wire inc_cntr;
wire sample;

reg clk_ut;        // clock being measured
reg [N_JIT_CNT-1:0] jm_cdf_out_reg; // 
reg [N_JIT_CNT-1:0] pulse_cntr_reg;
reg [N_JIT_CNT-1:0] cntr_reg; // 

//---------------------
// INSTANTIATION
//---------------------

// bang-bang phase detector (structural) for measurement
mdll_pd_bb_mon uPDBB_MEAS ( .clk_refp(clk_monp), .clk_refn(clk_monn), .osc_0(clk_ut), .early(bb_out_mon) );

//---------------------
// COMBINATIONAL
//---------------------

assign jm_clk_fb_out = clk_fb_mon;  // feedthrough
assign jm_cdf_out = jm_cdf_out_reg;

always_comb begin
    case(jm_sel_clk)
        3'd0: clk_ut    = osc_0;
        3'd1: clk_ut    = osc_90;
        3'd2: clk_ut    = osc_180;
        3'd3: clk_ut    = osc_270;
        3'd4: clk_ut    = clk_fb_mon;
        default: clk_ut = osc_180;
    endcase
end

assign inc_cntr = jm_bb_out_pol ? bb_out_mon : ~bb_out_mon;
assign sample = (pulse_cntr_reg == '1);
assign cntr_nxt = sample ? '0 : ((cntr_reg=='1) ? cntr_reg : cntr_reg + inc_cntr);

//FIXME

//---------------------
// SEQ
//---------------------

always @(posedge clk_monp, negedge en_monitor) begin
	if (!en_monitor) pulse_cntr_reg <= '0;
	else pulse_cntr_reg <= pulse_cntr_reg + 1;
end

always @(posedge clk_monp, negedge en_monitor) begin
	if (!en_monitor) cntr_reg <= '0;
	else cntr_reg <= cntr_nxt;
end

always @(posedge clk_monp, negedge en_monitor) begin
	if (!en_monitor) jm_cdf_out_reg <= '0;
	else jm_cdf_out_reg <= cntr_reg;
end

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

