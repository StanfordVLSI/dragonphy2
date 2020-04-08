/********************************************************************
filename: biasgen.sv

Description: 
Bias generator of V2T ramp current source.

Assumptions:

Todo:
    - bias current dependency on ctrl

********************************************************************/

module biasgen import const_pack::Nbias; (
    input wire logic en,                 // enable this block
    input wire logic [Nbias-1:0] ctl,    // control current
    input real Vbias                     // gate bias voltage
);

import model_pack::V2TParameter;

// effective resistance when on/off
// TODO: update these values to match the design!

localparam r_on  = 1e2;
localparam r_off = 1e7;

// design parameter class instantiation, initialization

V2TParameter v2t_obj;
real Iunit;    // unit ramp current source

initial begin
	v2t_obj = new();
	Iunit = v2t_obj.Iunit;
end

// Model body
// TODO: re-implement impedance modeling

endmodule
