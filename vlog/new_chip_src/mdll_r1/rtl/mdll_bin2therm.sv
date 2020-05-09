/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_bin2therm.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Generic binary to thermometer decoder

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_bin2therm #(
// parameters here
	parameter int N=2	// # of binary input bit width

) (
// I/Os here
	input [N-1:0] din,
	output reg [2**N-2:0] dout
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

int unsigned j;

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------


always_comb begin
    dout = '0;
    for (j=0;j<din;j++) dout[j] = 1'b1;	
end

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

