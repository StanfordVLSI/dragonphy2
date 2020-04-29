/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#. Contact #EMAIL# for details.

* Filename   : pfd.v
* Author     : Byongchan Lim (bclim@stanford.edu)
* Description: Phase-frequency detector

* Note       :

* Revision   :
  - 7/26/2016: First release

****************************************************************/


module pfd(
  input clk_ref, clk_fb,
  output reg bb_out);

timeunit 1ps;
timeprecision 1fs;

reg up, dn;
wire reset;
assign reset = (up & dn) ;

initial up = 0;
initial dn = 0;

// actual PFD operation
always @(posedge clk_ref or posedge reset)
  if (reset) #(30ps) up <= 0;
  else up <= 1'b1;

always @(posedge clk_fb or posedge reset)
  if (reset) #(30ps) dn <= 0;
  else dn <= 1'b1;

always @(posedge dn) bb_out <= up;

endmodule
