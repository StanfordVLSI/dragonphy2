`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_reset_sync.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Reset synchronoizer
  - Assume the reset is active low

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_reset_sync #(
// parameters here
    parameter int DEPTH = 3 // depth of flops

) (
// I/Os here
    input clk,
    input rstn, // async reset ; active low
    output rstn_sync    // synchronized reset ; active low

);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

reg [DEPTH-1:0] rstn_d;
wire [DEPTH-1:0] rstn_d_nxt;

//---------------------
// INSTANTIATION
//---------------------

//---------------------
// COMBINATIONAL
//---------------------

assign rstn_d_nxt = {rstn_d[DEPTH-2:0], 1'b1};
assign rstn_sync = rstn_d[DEPTH-1] & rstn;

//---------------------
// SEQ
//---------------------

always @(posedge clk) rstn_d <= rstn_d_nxt;

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

