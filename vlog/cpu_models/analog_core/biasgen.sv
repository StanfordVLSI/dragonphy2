/********************************************************************
filename: biasgen.sv

Description: 
Bias generator of V2T ramp current source.

Assumptions:

Todo:
    - bias current dependency on ctrl

********************************************************************/

`include "voltage_net.sv"

module biasgen import const_pack::Nbias; (
    input wire logic en,                 // enable this block
    input wire logic [Nbias-1:0] ctl,    // control current
    output voltage Vbias                 // gate bias voltage
);

// effective resistance when on/off
// TODO: update these values to match the design!

localparam real r_on  = 1e2;
localparam real r_off = 1e7;
localparam real v_nom = 0.23;

// Model body
// TODO: implement variation with ctl
assign Vbias = '{v_nom, (en == 1'b1) ? r_on : r_off};

endmodule
