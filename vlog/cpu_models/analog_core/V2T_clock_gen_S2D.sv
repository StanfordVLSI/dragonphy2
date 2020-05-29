/********************************************************************
filename: V2T_clock_gen_S2D.sv

Description: 
Lumped model of V2T_clock_gen_S2D, which produces a differential
clock signal from a single-ended clock signal using cross-coupled
gates.

Assumptions:

Todo:

********************************************************************/

module V2T_clock_gen_S2D #(
    parameter real td_nom = 37.5e-12,    // nominal delay in sec
    parameter real td_std = 0.0,         // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0          // rms random jitter in sec
) (
    input wire logic in,                 // input signal
    output reg out,                      // delayed output signal (+)
    output reg outb                      // delayed output signal (-)
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
always @(in) begin
    rj = dly_obj.get_rj(rj_rms);
    out <= #((td+rj)*1s) in;
    outb <= #((td+rj)*1s) (~in);
end

endmodule
