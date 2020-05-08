`include "mdll_param.vh"
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
  - DVDD domain

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
	input jm_bb_out_pol,	// 1: take the internal bb_out_mon as it is, 0: invert it
	input jm_bb_out_mon,	// bb output from mdll_jmeas_core
	output [N_JIT_CNT-1:0] jm_cdf_out // 
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire inc_cntr;
wire sample;

wire [N_JIT_CNT-1:0] cntr_nxt; // 
reg [N_JIT_CNT-1:0] jm_cdf_out_r; // 
reg [N_JIT_CNT-1:0] pulse_cntr_r;
reg [N_JIT_CNT-1:0] cntr_r; // 

//---------------------
// INSTANTIATION
//---------------------

//---------------------
// COMBINATIONAL
//---------------------

assign jm_cdf_out = jm_cdf_out_r;
assign inc_cntr = jm_bb_out_pol ? jm_bb_out_mon : ~jm_bb_out_mon;
assign sample = (pulse_cntr_r == '1);
assign cntr_nxt = sample ? '0 : ((cntr_r=='1) ? cntr_r : (cntr_r + inc_cntr));

//FIXME

//---------------------
// SEQ
//---------------------

always @(posedge clk_monp, negedge en_monitor) begin
	if (!en_monitor) pulse_cntr_r <= '0;
	else pulse_cntr_r <= pulse_cntr_r + 1;
end

always @(posedge clk_monp, negedge en_monitor) begin
	if (!en_monitor) cntr_r <= '0;
	else cntr_r <= cntr_nxt;
end

always @(posedge clk_monp, negedge en_monitor) begin
	if (!en_monitor) jm_cdf_out_r <= '0;
	else if (sample) jm_cdf_out_r <= cntr_r;
end

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

