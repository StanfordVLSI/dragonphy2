/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : dcdl_fine_coupler.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Cross-coupled inverter between +/- clock outputs

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module dcdl_fine_coupler import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input cinp,
    input cinn
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
mdll_inv_x1 u1 ( .A(cinp), .ZN(cinn) );
mdll_inv_x1 u2 ( .A(cinn), .ZN(cinp) );
`endif  // ~SIMULATION

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

