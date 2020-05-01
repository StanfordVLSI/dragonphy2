/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : dcdl_fine_unit.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Single-ended fine delay cell

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module dcdl_fine_unit import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input `ANALOG_WIRE vsupply, // supply
    input [N_DCO_TI-1:0] ctl,   // delay control
	input cin,			// clock input
	output coutn		// inverting output
);

timeunit 1ps;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------

realtime td;	// propagation delay

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign #(td) coutn = ~cin;

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

real td_gain;	// [sec/code]
real td_offset; // [sec]
real k_vdd; // supply dependent derating factor

initial begin
	td_offset = TD0_DCDL_FINE;
	td_gain   = TD0_K_DCDL_FINE;
end
//initial begin 
//    #60us;
//    force vsupply=0.8;
//end

always @(vsupply) k_vdd = (1 + (VDDNOM_DCDL-vsupply)/VDDNOM_DCDL/2.0);

assign td = (k_vdd*(td_offset + td_gain * ctl))*1s;

// synopsys translate_on

endmodule

