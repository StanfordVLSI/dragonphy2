/****************************************************************

Copyright (c) 2018- Stanford University. All rights reserved.

The information and source code contained herein is the 
property of Stanford University, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from Stanford University. Contact bclim@stanford.edu for details.

* Filename   : sym2pwl.v
* Author     : Zach Myers and Byongchan Lim (bclim@stanford.edu)
* Description: 
  - sym2pwl converts a logical symbol to a pwl signal. 

* Note       :
  - It assumes that a pulse width is larger than the transition time, 
    tr (rise time) and tf (fall time).
  - If tr/tf is smaller than time unit (TU), TU will be selected.

* Revision   :
  - 12/28/2022: First Release

****************************************************************/

`include "mLingua_pwl.vh"

module sym2pwl #(
  parameter real vh=1.0,  // value corresponds to logic 'H'
  parameter real vl=0.0,  // value corresponds to logic 'L'
  parameter real tr=30e-12, // rise transition time
  parameter real tf=30e-12,  // fall transition time
  parameter integer sym_bitwidth=1
) (
  input [sym_bitwidth-1:0] in,      
  `output_pwl out 
);

parameter real level = (vh - vl)/(2**sym_bitwidth - 1);

timeunit `DAVE_TIMEUNIT ;
timeprecision `DAVE_TIMEUNIT ;

`get_timeunit
PWLMethod pm=new;

reg [sym_bitwidth-1:0] in_prev;
real val0, val1, slope;
real transition;
event wakeup;
event dummy_evt;

//`protect
//pragma protect 
//pragma protect begin

initial begin
  in_prev = in;
end

initial -> dummy_evt;

always @(dummy_evt) begin
  out = pm.write(get_value(in),0,0);
end

always @(in or wakeup) begin
  if ((in_prev != in) && ($time != 0)) begin
    val0 = get_value(in_prev);
    val1 = get_value(in);
    transition = (in > in_prev) ? tf:tr;
    transition = max(transition, TU); // handle if tr(tf) < TU
    slope = (val1-val0)/transition;
    out = pm.write(val0, slope, `get_time); 
    ->> `delay(transition) wakeup;
  end
  else 
    out = pm.write(get_value(in), 0.0, `get_time);
  in_prev = in;
end

function real get_value (logic [sym_bitwidth-1:0] _in);
  return vl + _in*level;
endfunction 

//pragma protect end
//`endprotect

endmodule
