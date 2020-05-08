`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_tieh.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - tie high

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/

`define SIMULATION

module mdll_tieh import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
    output HI
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
	// set_dont_touch udont1
	// synopsys dc_script_end
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

assign HI = 1'b1;

// synopsys translate_on

endmodule

