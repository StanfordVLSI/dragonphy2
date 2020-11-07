module tx_inv(
    input wire logic DIN,
    output wire logic DOUT 
);

INVD4BWP16P90ULVT inv_4_fixed (
		        // user-provided signals
		        .I(DIN0), // Input
		        .ZN(DOUT)
	        );

endmodule