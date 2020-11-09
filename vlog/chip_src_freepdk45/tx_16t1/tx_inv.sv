module tx_inv(
    input wire logic DIN,
    output wire logic DOUT 
);

INV_X4 inv_4_fixed (
		        // user-provided signals
		        .A(DIN), // Input
		        .ZN(DOUT)
	        );

endmodule