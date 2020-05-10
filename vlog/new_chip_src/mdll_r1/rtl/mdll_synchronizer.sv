/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_synchronizer.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - multi-stage sampler for clock domain crossing

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_synchronizer #(
// parameters here
    parameter int DEPTH = 2 // # of flop stages (>=2)
) (
// I/Os here
    input clk,
    input din,
    output dout,
    output reg [DEPTH-1:0] din_d 
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire [DEPTH-1:0] din_d_nxt;

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign din_d_nxt = {din_d[DEPTH-2:0], din};
assign dout = din_d[DEPTH-1];

//---------------------
// SEQ
//---------------------

always @(posedge clk) din_d <= din_d_nxt;

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

