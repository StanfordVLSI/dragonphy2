/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_u.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - A unit cell of a digitally-controlled, delay cell.

* Note       :
  -

* Todo       :
  - Currently, this is a very high-level model.
  - "en" does nothing.

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_u import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
`ifdef SIMULATION
    input `ANALOG_WIRE VREG,
`endif
	input sel_inj,	// 1: take inj_inp(n); 0: take inp(n) inputs
	input [2**N_DCO_O-2:0] ctl_offset_thm,// offset control of the delay (thermometer)
	input [2**(N_DCO_TI-N_PI)-2:0] ctl_fine_msb_thm,	// MSB fine control of the delay (thermometer)
	input [2**N_PI-2:0] ctl_fine_lsb_thm,	// LSB fine control of the delay (thermometer)
	input inp,		// (+)  osc feedback input
	input inn,		// (-)  osc feedback input
	input inj_inp, 	// (+) injection input
	input inj_inn, 	// (-) injection input
	output outp,	// (+) output of the delay line
	output outn,	// (-) output of the delay line
	output mux_p,	// (+) mux out 
	output mux_n,	// (-) mux out 
    output bb_out   // phase detector output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire coutp_o;	// (+) clock out of offset delay line
wire coutn_o;	// (-) clock out of offset delay line
wire coutp_f;	// (+) clock out of fine delay line
wire coutn_f;	// (-) clock out of fine delay line

//---------------------
// INSTANTIATION
//---------------------

// phase detector
// place this next to the clock mux inside uMXP, uMXN
mdll_pd_bb uPD ( .osc_0(inp), .clk_refp(inj_inp), .clk_refn(inj_inn), .sel_inj(sel_inj), .bb_out(bb_out));

defparam uDCDL_OFFSET.N_STG = 2**N_DCO_O-1;
defparam uDCDL_OFFSET.USE_VREG = 1'b1;

mdll_dcdl_coarse uDCDL_OFFSET (
`ifdef SIMULATION
    .VREG(VREG),
`endif
	.cinp(mux_p),
    .cinn(mux_n),
    .ctl_thm(ctl_offset_thm),
    .coutp(coutp_o),
    .coutn(coutn_o)
);

defparam uDCDL_FINE_MSB.N_STG = 2**(N_DCO_TI-N_PI)-1;

mdll_dcdl_coarse uDCDL_FINE_MSB (
`ifdef SIMULATION
    .VREG(),
`endif
    .cinp(coutp_o),
    .cinn(coutn_o),
    .ctl_thm(ctl_fine_msb_thm),
    .coutp(coutp_f),
    .coutn(coutn_f)
);

mdll_dcdl_pi uDCDL_PI (
`ifdef SIMULATION
	.VREG(),
`endif
    .cinp(coutp_f),
    .cinn(coutn_f),
    .ctl_thm(ctl_fine_lsb_thm),
    .coutp(outp),
    .coutn(outn)
);

mdll_ckmuxi uMXP ( .ZN(mux_n), .I0(inj_inp), .I1(inp), .S0(sel_inj) );
mdll_ckmuxi uMXN ( .ZN(mux_p), .I0(inj_inn), .I1(inn), .S0(sel_inj) );

//---------------------
// COMBINATIONAL
//---------------------



//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off


wire stat_in;
assign #1ps stat_in = inp ^ inn;	// input must be differential
always @(stat_in)
	assert (stat_in===1'b1) else $warning("[WARN][%m]: Inputs (inp,inn) are not differential");

// synopsys translate_on

endmodule

