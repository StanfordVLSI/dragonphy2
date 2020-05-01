/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_aux_osc.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Auxiliary oscillator for sub-sampling TDC.

* Note       :
  - Current version works only if N_PH_AUXOSC >= 4

* Todo       :
  - Make it synthesizable
  - test N_PH_AUXOSC with {2, 3, 4, 5, 6}

* Fixme      :
  - Currently, N_PH_AUXOSC must be >= 4

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_aux_osc import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
	input en_osc,	// enable oscillator; active high
	output aux_clk,	// oscillator clock output
	output reg [N_PH_AUXOSC-1:0] mclk	// multi-phase clock output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

localparam int IS_N_PH_ODD = (N_PH_AUXOSC % 2);	// is the number of phase odd ?
localparam PH_MOD = IS_N_PH_ODD ? 0.5/N_PH_AUXOSC : (0.5/(N_PH_AUXOSC/2));	// phase modulo


//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign aux_clk = mclk[0];

generate

if (~IS_N_PH_ODD)
	always @(mclk[N_PH_AUXOSC/2-1:0]) mclk[N_PH_AUXOSC-1:N_PH_AUXOSC/2] = ~mclk[N_PH_AUXOSC/2-1:0];

endgenerate

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

let MAX(a,b) = (a>=b)? a : b ;

integer seed;
real phase;
real t_cur, t0;
event trigger;	// self event trigger to update states
real _f;		// instantaneous frequency
real freq;		// frequency to compute phase
int ck_istate;	// initial clock states
realtime dT;	// delta t to schedule a next event

// initialization
initial begin
	INIT_CLK_STATE;	// initialize mclk state
	_f = FREQ_AUXOSC;		// take oscillator frequency parameter
end

// stop oscillator
always @(negedge en_osc) 
	disable Phase_Timer;

// take a new frequency information or enable state
always @(_f, en_osc) begin
	if (en_osc) begin
		disable Phase_Timer;
		UPDATE_PHASE;
		freq = _f;
		->> trigger;
	end
end

// self triggered event to update clock states & phase state
real ph_modulo;
initial ph_modulo = PH_MOD;
always @(trigger) begin: Phase_Timer
	UPDATE_PHASE;
	if (phase >= ph_modulo) begin
		ROTATE_MCLK;
		phase -= ph_modulo;
		ph_modulo = PH_MOD + 0.01*$dist_normal(seed,0,10000)/10000.0;
	end
	if (freq > 0) begin
		dT = MAX(1, (ph_modulo-phase)/freq*1s);
		#(dT);
		->> trigger;
	end
end

// initialize mclk to start at a valid state
task INIT_CLK_STATE;
	ck_istate = $urandom % N_PH_AUXOSC;
	mclk = 1;
	for (int k=0;k<ck_istate;k++) begin
		ROTATE_MCLK;
	end
endtask // INIT_CLK_STATE

// compute phase
task UPDATE_PHASE;
	t_cur = $realtime/1s;
	phase += freq*(t_cur-t0);
	t0 = t_cur;
endtask


task ROTATE_MCLK;
	if (IS_N_PH_ODD) 	// odd phases
		mclk[N_PH_AUXOSC-1:0] = {mclk[N_PH_AUXOSC-2:0],~mclk[N_PH_AUXOSC-1]};
	else if (N_PH_AUXOSC==2)	// two phases (0, 180)
		mclk[0] = ~mclk[0];
	else 				// even (> two) phases
		mclk[N_PH_AUXOSC/2-1:0] = {mclk[N_PH_AUXOSC/2-2:0],~mclk[N_PH_AUXOSC/2-1]};
endtask
//generate 
//	if (IS_N_PH_ODD) begin
//		function ROTATE_MCLK;
//			mclk[N_PH_AUXOSC-1:0] = {mclk[N_PH_AUXOSC-2:0],~mclk[N_PH_AUXOSC-1]};
//		endfunction
//	end else if (N_PH_AUXOSC==2) begin
//		function ROTATE_MCLK;
//			mclk[0] = ~mclk[0];
//		endfunction
//	end else begin
//		function ROTATE_MCLK;
//			mclk[N_PH_AUXOSC/2-1:0] = {mclk[N_PH_AUXOSC/2-2:0],~mclk[N_PH_AUXOSC/2-1]};
//		endfunction
//	end
//endgenerate 


initial assert (N_PH_AUXOSC >= 4) else $error("[ERROR][%m]: N_PH_AUXOSC must be larger than 4.");

// simple oscillator model
//real tp_half;
//real residue;
//realtime tp_half_aligned;
//
//always begin
//	tp_half = 0.5/FREQ_AUXOSC + residue;
//	tp_half_aligned = tp_half * 1s;
//	residue = tp_half - tp_half_aligned / 1s;
//	#(tp_half_aligned);
//end

// synopsys translate_on

endmodule

