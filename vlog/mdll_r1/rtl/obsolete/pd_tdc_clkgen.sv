/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : pd_tdc_clkgen.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Generate masked clocks for sub-sampling TDC.

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module pd_tdc_clkgen import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input clk_0,          // dco I clock (after mux)
    input last_cycle_m1,  // two cycles of clk_0 ahead of clk_refp posedge
    output reg ck_rise,   // rise clock 
    output reg ck_fall    // fall clock 
);

timeunit 1ps;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------


//---------------------
// SEQ
//---------------------

always @(posedge clk_0) ck_rise <= last_cycle_m1;
always @(posedge clk_0) ck_fall <= ck_rise;


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule
