/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_nd2.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - NAND2 for delay cell

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_nd2 import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input `ANALOG_WIRE ana_vsupply,
    input A,
    input B,
    output ZN
);

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------

realtime td;

//---------------------
// INSTANTIATION
//---------------------

`ifndef SIMULATION
    NAND2X8LVT ( .Y(ZN), .A(A), .B(B) );
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

real k_vdd; // supply dependent derating factor

always @(ana_vsupply) k_vdd = (1 + (VDDNOM_DCDL-ana_vsupply)/VDDNOM_DCDL/2.0);

assign td = (TD0_DCDL_COARSE_ND2*k_vdd)*1s;

assign #(td) ZN = ~(A & B);

// synopsys translate_on

endmodule

