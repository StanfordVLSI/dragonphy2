/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : dcdl_fine.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  -

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module dcdl_fine import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input `ANALOG_WIRE vsupply,
    input cinp,
    input cinn,
    input [N_DCO_TI-1:0] ctl_fine,
    //input [N_DCO_DITH-1:0] dither,
    output coutp,
    output coutn

);

timeunit 1ps;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

dcdl_fine_unit uP ( 
    .vsupply(vsupply),
    .ctl(ctl_fine),
	.cin(cinp),
	.coutn(coutn)
);

dcdl_fine_unit uN ( 
    .vsupply(vsupply),
    .ctl(ctl_fine),
	.cin(cinn),
	.coutn(coutp)
);

dcdl_fine_coupler uXCOUPLER (
	  .cinp(coutp),
	  .cinn(coutn)
);

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

