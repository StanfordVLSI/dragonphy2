/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_coarse_unit.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  	- Unit coarse delay cell using NAND
	- If N stages of this cell is enabled

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_coarse_unit import mdll_pkg::*; #(
// parameters here
    parameter USE_VREG = 1'b0 // delay cell using regulated supply

) (
// I/Os here
`ifdef SIMULATION
    input real VREG,
`endif
	input cin_ff,	// clock input from the previous stage
	input cin_fb,	// clock input from the next stage
	input en_ff,	// enable feedforward clock (from cin_ff to cout_ff); active high.
					// otherwise, enable feedback (from cin_ff to cout_fb)
	output cout_ff,	// clock output to next delay stage
	output cout_fb	// clock output to the previous stage

);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire en_fb;
wire cout_fb_int;


//---------------------
// INSTANTIATION
//---------------------

generate

if (USE_VREG) begin
    mdll_dcdl_nd2_vreg u1 ( `ifdef SIMULATION .VREG(VREG), `endif .A(cin_ff), .B(en_ff), .ZN(cout_ff) );
    mdll_dcdl_nd2_vreg u2 ( `ifdef SIMULATION .VREG(VREG), `endif .A(cin_ff), .B(en_fb), .ZN(cout_fb_int) );
    mdll_dcdl_nd2_vreg u3 ( `ifdef SIMULATION .VREG(VREG), `endif .A(cout_fb_int), .B(cin_fb), .ZN(cout_fb) );
end else begin
    mdll_dcdl_nd2 u1 ( `ifdef SIMULATION .VREG(VREG), `endif .A(cin_ff), .B(en_ff), .ZN(cout_ff) );
    mdll_dcdl_nd2 u2 ( `ifdef SIMULATION .VREG(VREG), `endif .A(cin_ff), .B(en_fb), .ZN(cout_fb_int) );
    mdll_dcdl_nd2 u3 ( `ifdef SIMULATION .VREG(VREG), `endif .A(cout_fb_int), .B(cin_fb), .ZN(cout_fb) );
end
endgenerate
mdll_inv_x1 u4 	 ( .A(en_ff), .ZN(en_fb) );


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

