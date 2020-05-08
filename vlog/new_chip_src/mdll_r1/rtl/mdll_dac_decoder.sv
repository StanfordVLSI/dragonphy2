`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dac_decoder.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  -

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dac_decoder import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input  [N_DAC_TI-1:0] din,
    output reg [2**N_DAC_TI-1:0] dinb_sel
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

always_comb begin
    dinb_sel = '1;
    dinb_sel[din] = 1'b0;
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

