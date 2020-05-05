/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_phase_blender.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - phase blender

* Note       :
  - Assumed cinp(n)_lead always leads cinp(n)_lag, which is always true for this design.

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_phase_blender import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    //input `ANALOG_WIRE VREG,
    input cinp_lead,
    input cinn_lead,
    input cinp_lag,
    input cinn_lag,
    input [2**N_PI-2:0] ctl_thm,
    output coutp,
    output coutn
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

`ifndef SIMULATION

	wire coutp_pre, coutn_pre;
	
	genvar k;
	generate
		for (k=0;k<2**N_PI-1;k++) begin: genblk1
            //mdll_mx2i uMX_P ( .I0(cinp_lead), .I1(cinp_lag), .S0(ctl_thm[k]), .ZN(coutn_pre) );
            //mdll_mx2i uMX_N ( .I0(cinn_lead), .I1(cinn_lag), .S0(ctl_thm[k]), .ZN(coutp_pre) );
            mdll_mx2i uMX_P ( .I0(cinp_lag), .I1(cinp_lead), .S0(ctl_thm[k]), .ZN(coutn) );
            mdll_mx2i uMX_N ( .I0(cinn_lag), .I1(cinn_lead), .S0(ctl_thm[k]), .ZN(coutp) );
		end
	
	endgenerate
	
	//mdll_inv_x4 uINVP ( .A(coutn_pre), .ZN(coutp) );
	//mdll_inv_x4 uINVN ( .A(coutp_pre), .ZN(coutn) );
	mdll_dcdl_coarse_coupler uXCPL ( .cinp(coutp), .cinn(coutn) );

`endif	// ~SIMULATION

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

wire cinp_lead_d;
realtime tdi;	// intrinsic relay
real pi_weight;	// phase interpolation weight
realtime t_lead, tdiff, tout;
real k_vdd; // supply dependent derating factor

assign k_vdd = 1.0;
assign tdi = (TD0_PI*k_vdd)*1s;

assign pi_weight = $countones(ctl_thm)/2.0**N_PI;

always @(cinp_lead,cinp_lag) begin
	if (cinp_lead ^ cinp_lag) t_lead = $realtime;
	else begin
		tdiff = $realtime - t_lead;
		tout = tdiff * PI_GAIN * pi_weight;
	end
end

assign coutn = ~coutp;
assign #(tdi) cinp_lead_d =  cinp_lead;
assign #(tout) coutp = cinp_lead_d;


// assertion
wand stat_in;

assign #1ps stat_in = cinp_lead ^ cinn_lead;	// input must be differential
assign #1ps stat_in = cinp_lag ^ cinn_lag;		// input must be differential

always @(stat_in) assert (stat_in===1'b1) else $warning("[WARN][%m]: Inputs are not differential");

// synopsys translate_on

endmodule

