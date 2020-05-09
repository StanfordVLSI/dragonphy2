/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#. Contact #EMAIL# for details.

* Filename   : mdll_pfd.v
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description: Phase detector

* Note       :

* Revision   :
  - 00/00/00: First release

****************************************************************/


module mdll_pfd import mdll_pkg::*; (
    input sel_inj,
    input clk_ref, 
    input osc_0,
    output reg bb_out
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire up, dn;
wire sel_inj_b1, sel_inj_b2;
wire sel_inj_1;
wire sel_inj_d;
wire resetn;
wire tiehigh;

//---------------------
// INSTANTIATION
//---------------------

mdll_tieh uTIEH ( .HI(tiehigh) );

// reset delay cell
mdll_inv_x1 uINVC1 ( .A(sel_inj), .ZN(sel_inj_b1) );
mdll_inv_x1 uINVC2 ( .A(sel_inj_b1), .ZN(sel_inj_1) );
mdll_inv_x1 uINVC3 ( .A(sel_inj_1), .ZN(sel_inj_b2) );
mdll_inv_x1 uINVC4 ( .A(sel_inj_b2), .ZN(sel_inj_d) );

mdll_or2 uRSTN ( .A(sel_inj), .B(sel_inj_d), .Z(resetn) );
mdll_dff_sampler_rstn uUPFF ( .clk(osc_0), .d(tiehigh), .rstn(resetn), .q(up) );
mdll_dff_sampler_rstn uDNFF ( .clk(clk_ref), .d(tiehigh), .rstn(resetn), .q(dn) );
mdll_dff_sampler uBBFF ( .clk(dn), .d(up), .q(bb_out) );

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

defparam uINVC1.TD = TD_PFD_RESET;
initial uUPFF.q_reg = $urandom();
initial uDNFF.q_reg = $urandom();

// synopsys translate_on


endmodule
