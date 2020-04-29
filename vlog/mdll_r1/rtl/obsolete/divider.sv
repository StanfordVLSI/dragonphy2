/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#. Contact #EMAIL# for details.

* Filename   : divider.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description: frequency divider 

* Note       :

* Revision   :
  - 7/26/2016: First release

****************************************************************/


module divider #(
  parameter integer NDIV = 2  // divider ratio
) (
  input cki,    // input clock
  output cko,   // divided clock
  output ckob   // ~cko
);

//---------------------
// VARIABLES, WIRES
//---------------------

localparam Nbw = $clog2(NDIV);  // bit width of cntr counter reg.

integer hNDIV = NDIV >> 1;      // ~ NDIV / 2
logic [Nbw-1:0] cntr = 0;       // counter reg
wire [Nbw-1:0] cntr_nxt ;

//---------------------
// COMBINATIONAL
//---------------------

assign cntr_nxt = (cntr == (NDIV-1)) ? '0 : (cntr + 1) ;
assign cko = (cntr >= hNDIV) ? 1'b1 : 1'b0;
assign ckob = ~cko;

//---------------------
// SEQ
//---------------------

always @(posedge cki) cntr <= cntr_nxt;

//---------------------
// OTHERS
//---------------------

`SYNTHESIS_OFF

initial assert (NDIV > 1) else $error("[ERROR][%m]: NDIV must be larger than one.");

`SYNTHESIS_ON

endmodule
