/********************************************************************
filename: delay_pi.sv

Description: 
a delay cell in PI

Assumptions:

Todo:

********************************************************************/

module inc_delay (
    input wire logic in,         // input signal
    input wire logic inc_del,    // (act. high) increase the delay by a factor of gain
    output reg out               // delayed output signal
);

timeunit 1fs;
timeprecision 1fs;

import model_pack::PIParameter;

// design parameter class

PIParameter pi_obj;

// variables

real td;      // delay w/o jitter
real td0;     // delay w/o jitter when inc_del=0
real gain;    // delay gain by inc_del
real rj;      // random jitter

// initialize class parameters
initial begin
    pi_obj = new();
    td0 = pi_obj.td_chain_unit;
    gain = pi_obj.td_chain_unit_gain;
end

///////////////////////////
// Model Body
///////////////////////////

// delay control
assign td = inc_del ? td0*gain : td0;

// delay behavior from `in` to `out`
always @(in) begin
    rj = pi_obj.get_rj_chain_unit();
    out <= #((td+rj)*1s) in ;
end

endmodule