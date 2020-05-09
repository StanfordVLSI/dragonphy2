/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_nd3_x1.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - x1 three-input nand

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_nd3_x1 import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input A,
    input B,
    input C,
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
    nand3 u1 ( .A1(A), .A2(B), .A3(C), .ZN(ZN) );
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

assign #0ps ZN = ~(A & B & C);

// synopsys translate_on

endmodule

