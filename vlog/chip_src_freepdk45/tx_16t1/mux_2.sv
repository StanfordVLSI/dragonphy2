module mux_2(
    input wire logic DIN0,
	input wire logic DIN1,
    input wire logic E0,
    output wire logic DOUT 
);

MUX2_X2 mux_2_fixed (
		        // user-provided signals
		        .A(DIN0), // Input
		        .B(DIN1),
				.Z(DOUT), // Output
		        .S(E0) 
	        );

endmodule