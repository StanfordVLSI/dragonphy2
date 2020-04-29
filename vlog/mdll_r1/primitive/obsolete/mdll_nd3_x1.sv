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

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

`ifndef SIMULATION
    ND3LVT u1 ( .Y(ZN), .A(A), .B(B), .C(C) );
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

