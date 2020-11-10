/********************************************************************
filename: qr_mux_fixed.sv

Description: 
A 4-input mux with an inverted output
Corresponding to tsmc 16nm ulvt standard cell
********************************************************************/

module qr_mux_fixed #(
    ////////////////////////////////////
    // TODO: update this!             //
    parameter real td_nom = 2.3e-11,  //
    ////////////////////////////////////
    parameter real td_std = 0.0,  // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0   // rms random jitter in sec
) (
    input wire logic DIN0,
	input wire logic DIN1,
	input wire logic DIN2,
	input wire logic DIN3,
    input wire logic E0,
	input wire logic E1,
    output reg DOUT 
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

always @(*) begin
    rj = dly_obj.get_rj(rj_rms);
    case ({E1, E0}) 
        2'b00: DOUT <= #((td+rj)*1s) ~DIN0;
        2'b01: DOUT <= #((td+rj)*1s) ~DIN1;
        2'b10: DOUT <= #((td+rj)*1s) ~DIN2;
        2'b11: DOUT <= #((td+rj)*1s) ~DIN3;
    endcase
end

endmodule
