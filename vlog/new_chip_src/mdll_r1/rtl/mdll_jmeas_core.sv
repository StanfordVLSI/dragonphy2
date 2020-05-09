/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_jmeas_core.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Jitter measurement by sweeping samping clock phase

* Note       :
  - CVDD domain

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_jmeas_core import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
	input clk_monp,     //(+) clk for jitter measurement
	input clk_monn,     //(-) clk for jitter measurement
    input en_monitor,   // enable jitter monitor circuit (active high)
    input [2:0] jm_sel_clk,    // select clock being measured
    input osc_0,            // I clock for jitter measurement
    input osc_90,           // Q clock for jitter measurement
    input osc_180,          // /I clock for jitter measurement
    input osc_270,          // /Q clock for jitter measurement
    input clk_fb_mon,       // 1/32 feedback clock to jitter measurement module
    output jm_clk_fb_out,   // 1/32 feedback clock output for direct jitter measurement by sampling scope
	output jm_bb_out_mon		// bang-bang pd output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

reg clk_ut;        // clock being measured

//---------------------
// INSTANTIATION
//---------------------

// bang-bang phase detector (structural) for measurement
mdll_pd_bb_mon uPDBB_MEAS ( .clk_refp(clk_monp), .clk_refn(clk_monn), .osc_0(clk_ut), .early(jm_bb_out_mon) );

//---------------------
// COMBINATIONAL
//---------------------

assign jm_clk_fb_out = clk_fb_mon;  // feedthrough

always_comb begin
    case(jm_sel_clk)
        3'd0: clk_ut    = osc_0;
        3'd1: clk_ut    = osc_90;
        3'd2: clk_ut    = osc_180;
        3'd3: clk_ut    = osc_270;
        3'd4: clk_ut    = clk_fb_mon;
        default: clk_ut = osc_180;
    endcase
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

