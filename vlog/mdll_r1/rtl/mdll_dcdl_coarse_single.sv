/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_coarse_single.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
    - Single-ended coarse delay line
   

* Note       :
    - If N stages are on, the delay is about (2*TD)*N.

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_coarse_single import mdll_pkg::*; #(
// parameters here
    parameter N_STG = 2, // number of statges
    parameter USE_VREG = 1'b0 // delay cell using regulated supply
) (
// I/Os here
`ifdef SIMULATION
    input `ANALOG_WIRE VREG,
`endif
    input cin,  // clock input
    input [N_STG-1:0] ctl_thm, // coarse delay control in thermometer
    output cout // non-inverting clock output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

genvar k;

wire [N_STG-1:0] cin_ff;
wire [N_STG-1:0] cin_fb;
wire [N_STG-1:0] cout_ff;
wire [N_STG-1:0] cout_fb;

wire tiehigh;

//---------------------
// INSTANTIATION
//---------------------

mdll_tieh uTIEH ( .HI(tiehigh) );

generate
    for (k=0;k<N_STG;k++) begin: genblk1
        mdll_dcdl_coarse_unit #(.USE_VREG(USE_VREG)) uDLYU (
		  `ifdef SIMULATION
            .VREG(VREG),
		  `endif
	        .cin_ff(cin_ff[k]),
	        .cin_fb(cin_fb[k]),
	        .en_ff(ctl_thm[k]),
	        .cout_ff(cout_ff[k]),
	        .cout_fb(cout_fb[k])
        );
    end
endgenerate


//---------------------
// COMBINATIONAL
//---------------------

// wiring

assign cout = cout_fb[0];
assign cin_ff[0] = cin;
assign cin_fb[N_STG-1] = tiehigh;

generate
    for (k=1;k<N_STG;k++) begin: genblk2
        assign cin_ff[k] = cout_ff[k-1];
    end
    for (k=0;k<(N_STG-1);k++) begin: genblk3
        assign cin_fb[k] = cout_fb[k+1];
    end
endgenerate


//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

