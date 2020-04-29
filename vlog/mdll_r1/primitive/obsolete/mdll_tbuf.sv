/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_tbuf.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - X1 tri-state inverter for phase blender

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_tbuf import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input A,
	input EN,
    output Z
);

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign #0ps Z = EN ? A : 1'bz;

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

