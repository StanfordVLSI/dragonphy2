/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_supply_dac_buffer.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Source follower

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/

`include "iotype.sv"

module mdll_supply_dac_buffer import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input `real_t ana_vref,
    output `real_t vout
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

`ifndef SIMULATION

//---------------------
// INSTANTIATION
//---------------------


    // source follower
    mdll_sourcefollower uBUFFER[3:0] ( .G(ana_vref), .S(vout) ); // connect S to VREG
    // decap at the SF output
    mdll_decap u_decap[69:0] (.TOP(vout), .BOT(1'b0));

`endif // ~SIMULATION
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

assign vout = ana_vref - V_GS_LDO;  // source follower

// synopsys translate_on

endmodule

