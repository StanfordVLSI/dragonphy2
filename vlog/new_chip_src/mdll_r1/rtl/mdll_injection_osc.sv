`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_injection_osc.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Injection oscillator

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/
`include "iotype.sv"


module mdll_injection_osc import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
	input clk_refp,		// (+) reference clock
	input clk_refn,		// (-) reference clock
	input en_osc,		// enable this oscillator; active high; asynchronous
                        // it breaks the oscillator loop if low
    input inj_mode,     // 0: ring oscillator mode; 1: injection oscillator mode
    input last_cycle,	// the last cycle of osc_0 (before rising edge of clk_fb) for sel_inj gen
    input [2**N_DCO_O-2:0] ctl_offset_thm,  // # of delay coarse stages for supply modulation
    input [2**(N_DCO_TI-N_PI)-2:0] ctl_fine_msb_thm, // fine control (MSB) of the delay
    input [2**N_PI-2:0] ctl_fine_lsb_thm, // fine control (LSB) of the delay by a phase blender
    input [2**N_DAC_TI-1:0] ctlb_dac_sel, // R-dac voltage output select (one-cold)
	input [N_DAC_BW-1:0] ctl_dac_bw_thm, // DAC bandwidth control 
	input [N_DAC_GAIN-1:0] ctlb_dac_gain_oc,	// r-dac gain control, one-cold
	output bb_out_inc,	// bang-bang pd output (early, thus increase delay)
	output clk_0,		// I clock ( after mux )
	output clk_90,		// Q clock ( after mux )
	output clk_180,		// /I clock ( after mux )
	output clk_270,		// /Q clock ( after mux )
    output osc_0,       // mux delay ahead of clk_0 ( before mux )
    output osc_90,      // mux delay ahead of clk_90 ( before mux )
    output osc_180,     // mux delay ahead of clk_180 ( before mux )
    output osc_270      // mux delay ahead of clk_270 ( before mux )
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire clk_0_int;
wire clk_90_int;
wire clk_180_int;
wire clk_270_int;
wire osc_0_int;
wire osc_90_int;
wire osc_180_int;
wire osc_270_int;
wire sel_inj;
wire en_osc_b;

real vout;

wire tiehigh;
wire tielow;

//---------------------
// INSTANTIATION
//---------------------

mdll_tieh uTIEH ( .HI(tiehigh) );
mdll_tiel uTIEL ( .LO(tielow) );

mdll_inv_x1 uINV_EN_OSC ( .A(en_osc), .ZN(en_osc_b) );

mdll_inv_x1 uINV_C_0 ( .A(clk_0_int), .ZN(clk_180));
mdll_inv_x1 uINV_C_90 ( .A(clk_90_int), .ZN(clk_270));
mdll_inv_x1 uINV_C_180 ( .A(clk_180_int), .ZN(clk_0));
mdll_inv_x1 uINV_C_270 ( .A(clk_270_int), .ZN(clk_90));

mdll_inv_x1 uINV_O_0 ( .A(osc_0_int), .ZN(osc_180));
mdll_inv_x1 uINV_O_90 ( .A(osc_90_int), .ZN(osc_270));
mdll_inv_x1 uINV_O_180 ( .A(osc_180_int), .ZN(osc_0));
mdll_inv_x1 uINV_O_270 ( .A(osc_270_int), .ZN(osc_90));

// mux select signal generator of the injection oscillator
mdll_muxsel_gen uMXSEL ( .clk_refp(clk_refp), .clk_refn(clk_refn), .osc_0(osc_0_int), .osc_90(osc_90_int), .osc_180(osc_180_int), .osc_270(osc_270_int), .en_osc(en_osc), .en_inj(inj_mode), .last_cycle(last_cycle), .sel_inj(sel_inj) );

// fine delayline supply dac
mdll_dcdl_supply_dac uDAC (
`ifdef SIMULATION
    .iir_clk(osc_0),
`endif
    .ctl_dac_bw_thm(ctl_dac_bw_thm),
    .ctlb_dac_gain_oc(ctlb_dac_gain_oc),
    .dinb_sel(ctlb_dac_sel),
    .vout(vout)
);

mdll_dcdl_u uDCDL1 (
	.vout(vout),
	.sel_inj(sel_inj),
	.ctl_offset_thm(ctl_offset_thm),
	.ctl_fine_msb_thm(ctl_fine_msb_thm),
	.ctl_fine_lsb_thm(ctl_fine_lsb_thm),
	.inp(osc_0_int),
	.inn(osc_180_int),
	.inj_inp(clk_refp), 
	.inj_inn(clk_refn), 
	.outp(osc_90_int),
	.outn(osc_270_int),
	.mux_p(clk_0_int),
	.mux_n(clk_180_int),
	.bb_out(bb_out_inc)
);

mdll_dcdl_u uDCDL2 (
	.vout(vout),
	.sel_inj(tielow),
	.ctl_offset_thm(ctl_offset_thm),
	.ctl_fine_msb_thm(ctl_fine_msb_thm),
	.ctl_fine_lsb_thm(ctl_fine_lsb_thm),
	.inp(osc_90_int),
	.inn(osc_270_int),
	.inj_inp(tielow), 
	.inj_inn(tiehigh), 
	.outp(osc_180_int),
	.outn(osc_0_int),
	.mux_p(clk_90_int),
	.mux_n(clk_270_int),
	.bb_out()
);


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

// measure the phase difference between clk_0 and osc_0
realtime t_osc;
realtime t_clk;
real phase_err_in_psec;
initial begin
	#10ns;
	forever begin
		fork
			@(posedge osc_0) t_osc = $realtime;
			@(posedge clk_0) t_clk = $realtime;
		join	
			phase_err_in_psec = (t_clk - t_osc - TD_DCDL_MUX)/1ps;
	end
end

// synopsys translate_on

endmodule

