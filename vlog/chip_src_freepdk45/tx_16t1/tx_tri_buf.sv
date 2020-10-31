module tx_tri_buf(
    input wire logic DIN,
    input wire logic en,
    output wire logic DOUT 
);

TBUF_X4 tri_buf (
		        // user-provided signals
		        .A(DIN), // Input
		        .Z(DOUT), // Output
		        .EN(en) 
	        );

endmodule