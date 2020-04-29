/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_nd2_vreg.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - NAND2 for delay cell used in supply regulated offset control 

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_nd2_vreg import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
`ifdef SIMULATION
    input `ANALOG_WIRE VREG,
`endif
    input A,
    input B,
    output ZN
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
	// synopsys dc_script_begin
	// set_dont_touch u1
	// synopsys dc_script_end
    nand2 u1 ( .A1(A), .A2(B), .ZN(ZN) );
`endif // ~SIMULATION

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

realtime td;
real k_vdd; // supply dependent derating factor
initial k_vdd = 1.0;

always @(VREG) k_vdd = (1 + (VDDNOM_DCDL-VREG)/VDDNOM_DCDL*KD_VDD);

assign td = (TD0_DCDL_COARSE_ND2*k_vdd)*1s;

assign #(td) ZN = ~(A & B);

// synopsys translate_on

endmodule

