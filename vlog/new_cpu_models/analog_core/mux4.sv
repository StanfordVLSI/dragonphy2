/********************************************************************
filename: mux4.sv

Description: 
a parameterized mux4 cell 

Assumptions:

Todo:

********************************************************************/

module mux4 #(
    parameter real td_nom = 15.0e-12,    // nominal delay in sec
    parameter real td_std = 0.0,         // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0          // rms random jitter in sec
) (
    input wire logic [3:0] in,           // input signal
    input wire logic [1:0] sel,          // selection signal
    output wire out                      // delayed output signal
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

// compute new jitter
always @(in or sel) begin
    rj = dly_obj.get_rj(rj_rms);
end

// assign to the output using an inertial delay
// ref: http://www-inst.eecs.berkeley.edu/~cs152/fa06/handouts/CummingsHDLCON1999_BehavioralDelays_Rev1_1.pdf
assign #((td+rj)*1s) out = in[sel];

endmodule
