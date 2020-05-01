/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_muxsel_gen.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Generates a MUX select signal of the injection oscillator.

* Note       :
  -

* Todo       :

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_muxsel_gen #(
// parameters here
) (
// I/Os here
    input clk_refp,
    input clk_refn,
    input osc_0,      // injection osc. 0 degree (before mux)
    input osc_90,     // for load balancing
    input osc_180,    // for load balancing
    input osc_270,    // for load balancing
    input en_osc,
	input en_inj,		// enable injection; active high
	input last_cycle,	// flag indicating feedback divider in its last cycle of the input clock
	output reg sel_inj	// mux select; 1: reference clock; 0: oscillator clock
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire osc_0_b;
wire osc_0_bb;
wire enb;
wire resetb;

//---------------------
// INSTANTIATION
//---------------------

// ignored miller effect
mdll_inv_x1 uDMY1 ( .A(osc_90), .ZN() );
mdll_inv_x1 uDMY2 ( .A(osc_180), .ZN() );
mdll_inv_x1 uDMY3 ( .A(osc_270), .ZN() );

// muxsel logic
mdll_inv_x1 uINV1 ( .A(osc_0), .ZN(osc_0_b) );
mdll_inv_x1 uINV2 ( .A(osc_0_b), .ZN(osc_0_bb) );
mdll_nd2_x1 uND1 ( .A(osc_0_b), .B(last_cycle), .ZN(enb) );
mdll_nd3_x1 uND2 ( .A(osc_0_bb), .B(clk_refp), .C(enb), .ZN(resetb) );
mdll_nd3_x1 uND2_DMY ( .A(1'b1), .B(clk_refn), .C(1'b1), .ZN() );
mdll_latn_sr uLAT1 ( .Q(sel_inj), .D(en_inj), .SETN(en_osc), .GN(enb), .RESETN(resetb) );


//---------------------
// COMBINATIONAL
//---------------------


//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

//synopsys translate_off

//initial sel_inj = $urandom(); // simulation purpose
//
//assign en = last_cycle & ~osc_0;
//assign reset = clk_refp & osc_0 & ~en;
//
//// latch
//always @* begin
//    if (reset) sel_inj = 1'b0;
//    else if (en) sel_inj = en_inj;
//end
//initial begin
//    force resetb = 1'b0;
//    #200ns release resetb;
//end

//synopsys translate_on


endmodule
