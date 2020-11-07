module qr_mux_fixed(
    input wire logic DIN0,
	input wire logic DIN1,
	input wire logic DIN2,
	input wire logic DIN3,
    input wire logic E0,
	input wire logic E1,
    output wire logic DOUT 
);

MUX4ND4BWP16P90ULVT mux_4_fixed (
		        // user-provided signals
		        .I0(DIN0), // Input
		        .I1(DIN1),
				.I2(DIN2),
				.I3(DIN3),
				.Z(DOUT), // Output
		        .S0(E0),  // SELECTION
				.S1(E1) 
	        );

endmodule