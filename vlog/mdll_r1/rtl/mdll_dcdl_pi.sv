/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_pi.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Phase interpolator for fine delay cell

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dcdl_pi import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
`ifdef SIMULATION
    input `ANALOG_WIRE VREG, // supply
`endif
    input cinp, // (+) input clock
    input cinn, // (-) input clock
    input [2**N_PI-2:0] ctl_thm,  // control bits
    output coutp, // (+) interpolated clock
    output coutn  // (-) interpolated clock
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire cinp_lag, cinn_lag;
wire cinp_buf, cinn_buf;
wire cinp_lag_buf, cinn_lag_buf;

//---------------------
// INSTANTIATION
//---------------------

mdll_dcdl_coarse_unit uDLYP (
`ifdef SIMULATION
    .VREG(VREG),
`endif
	.cin_ff(cinp),
	.cin_fb(1'b1),
	.en_ff(1'b0),
	.cout_ff(),
	.cout_fb(cinp_lag)
);

mdll_dcdl_coarse_unit uDLYN (
`ifdef SIMULATION
    .VREG(VREG),
`endif
	.cin_ff(cinn),
	.cin_fb(1'b1),
	.en_ff(1'b0),
	.cout_ff(),
	.cout_fb(cinn_lag)
);

mdll_inv_x4 uBUF1 ( .A(cinp), .ZN(cinn_buf) );
mdll_inv_x4 uBUF2 ( .A(cinn), .ZN(cinp_buf) );
mdll_inv_x4 uBUF3 ( .A(cinp_lag), .ZN(cinn_lag_buf) );
mdll_inv_x4 uBUF4 ( .A(cinn_lag), .ZN(cinp_lag_buf) );

mdll_dcdl_phase_blender uPI ( 
    .cinp_lead(cinp_buf), 
    .cinn_lead(cinn_buf),
    .cinp_lag(cinp_lag_buf), 
    .cinn_lag(cinn_lag_buf),
    .ctl_thm(ctl_thm),
    .coutp(coutp),
    .coutn(coutn)
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

