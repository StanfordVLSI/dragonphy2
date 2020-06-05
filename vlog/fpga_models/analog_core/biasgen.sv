`include "iotype.sv"

module biasgen import const_pack::Nbias; (
    input wire logic en,                 // enable this block
    input wire logic [Nbias-1:0] ctl,    // control current
    inout `voltage_t Vbias               // gate bias voltage
);

    // needed to convince Vivado this is not a black box
    logic dummy;
    assign dummy = en;

endmodule
