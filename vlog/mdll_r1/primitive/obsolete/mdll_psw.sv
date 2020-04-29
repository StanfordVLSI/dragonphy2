/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_psw.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - PMOS switch for R-DAC decoder and R-DAC

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_psw #(
// parameters here

) (
// I/Os here
    input D,    //
    input G,
    output S
);

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

//`ifndef SIMULATION
//	pch_svt_mac u1 ( .D(D), .S(S), .G(G), .B(1'b1) );
//`endif

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

