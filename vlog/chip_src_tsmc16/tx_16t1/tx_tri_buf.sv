module tx_tri_buf(
    input wire logic DIN,
    input wire logic en,
    output wire logic DOUT 
);

BUFTD4BWP16P90 tri_buf (
		        // user-provided signals
		        .I(DIN), // Input
		        .X(DOUT), // Output
		        .OE(en) 
	        );

endmodule