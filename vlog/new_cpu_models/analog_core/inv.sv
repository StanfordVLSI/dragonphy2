/********************************************************************
filename: inv.sv

Description: 
a parameterized inv cell 

Assumptions:

Todo:

********************************************************************/

module inv #(
    parameter real td_nom = 0.0,    // nominal delay in sec
    parameter real td_std = 0.0,    // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0     // rms random jitter in sec
) (
    input wire logic in,            // input signal
    output reg out                  // delayed output signal
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

// delay behavior from `in` to `out`
always @(in) begin
    rj = dly_obj.get_rj(rj_rms);
    out <= #((td+rj)*1s) ~in ;
end

endmodule
