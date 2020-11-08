module mux_2(
    input wire logic DIN0,
	input wire logic DIN1,
	input wire logic DIN2,
	input wire logic DIN3,
    input wire logic E0,
	input wire logic E1,
    output wire logic DOUT 
);


logic lth0;
logic lth1;


mux_2 mux_high (
	.DIN0(lth0),
	.DIN1(lth1),
	.E0(E1),
	.DOUT(DOUT)
);

mux_2 mux_low_0 (
	.DIN0(DIN0),
	.DIN1(DIN1),
	.E0(E0),
	.DOUT(lth0)
);

mux_2 mux_low_1 (
	.DIN0(DIN2),
	.DIN1(DIN3),
	.E0(E0),
	.DOUT(lth1)
);





// logic SEL;

// assign SEL = {E1, E0};

// always_comb begin : MUX_4
// 	case (SEL)
// 		2'b00: DOUT = DIN0;
// 		2'b01: DOUT = DIN1;
// 		2'b10: DOUT = DIN2;
// 		2'b11: DOUT = DIN3;
// 	endcase
// end

endmodule