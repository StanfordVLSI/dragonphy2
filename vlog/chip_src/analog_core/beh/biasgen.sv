/********************************************************************
filename: biasgen.sv

Description: 
Bias generator of V2T ramp current source.

Assumptions:

Todo:
    - bias current dependency on ctrl

********************************************************************/

`include "voltage_net.sv"

module biasgen import const_pack::*; (
    input wire logic en,    		// enable this block
    input wire logic [Nbias-1:0] ctl,		// control current
    output voltage Vbias      		// gate bias voltage
);

// effective resistance when on/off
// TODO: update these values to match the design!

localparam r_on  = 1e2;
localparam r_off = 1e7;

// design parameter class instantiation, initialization

V2TParameter v2t_obj;
real Iunit; // unit ramp current source

initial begin
	v2t_obj = new();
	`ifdef RANDOMIZE
		void'(v2t_obj.randomize());
	`endif
	Iunit = v2t_obj.Iunit;
end

// Model body

assign Vbias = '{v2t_obj.get_voltage(Iunit), (en == 1'b1) ? r_on : r_off};

endmodule
