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
    inout S,    //
    input G,
    inout D
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

// `ifndef SIMULATION
// 	// synopsys dc_script_begin
// 	// set_dont_touch u1
// 	// synopsys dc_script_end
//     //	pch_svt_mac u1 ( .D(D), .S(S), .G(G), .B(1'b1) );
//    nand2 u1 ( .A1(S), .A2(G), .ZN(D) );
// `endif

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

