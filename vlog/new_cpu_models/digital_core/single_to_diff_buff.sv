/********************************************************************
filename: single_to_diff_buff.sv

Description: 
Lumped model of single_to_diff_buff, which produces a differential
clock signal from a single-ended clock signal using cross-coupled
gates.

Assumptions:

Todo:

********************************************************************/

module single_to_diff_buff #(
    parameter real td_nom = 37.5e-12,    // nominal delay in sec (TODO update this)
    parameter real td_std = 0.0,         // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0          // rms random jitter in sec
) (
    input wire logic IN,                 // input signal
    output reg OUTP,                     // delayed output signal (+)
    output reg OUTN                      // delayed output signal (-)
);

timeunit 1fs;
timeprecision 1fs;

import model_pack::Delay;

// design parameter class

Delay dly_obj;

// variables

real td;    // delay w/o jitter
real rj;    // random jitter

// initialize class parameters
initial begin
    dly_obj = new(td_nom, td_std);
    td = dly_obj.td;
end

///////////////////////////
// Model Body
///////////////////////////

// compute new jitter value and drive output
// transport delay is used because this is a lumped model
always @(IN) begin
    rj = dly_obj.get_rj(rj_rms);
    OUTP <= #((td+rj)*1s) IN;
    OUTN <= #((td+rj)*1s) (~IN);
end

endmodule
