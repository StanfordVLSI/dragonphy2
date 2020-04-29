/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_mx2i.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - 2-to-1 mux with inverting output for phase blender

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_mx2i #(
// parameters here

) (
// I/Os here
    input I0,
    input I1,
    input S0,
    output ZN
);

timeunit 1ps;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

`ifndef SIMULATION
    MXI2XLLVT u1(.Y(ZN), .A(I0), .B(I1), .S0(S0));  // gpdk 45nm
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

// synopsys translate_on

endmodule

