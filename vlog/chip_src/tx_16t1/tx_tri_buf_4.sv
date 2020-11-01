module tx_tri_buf_4(
    input wire logic DIN,
    input wire logic en,
    output wire logic DOUT 
);
		generate
			for (genvar i=0; i<4; i=i+1) begin: iBUF
			tx_tri_buf tri_buf (
		        // user-provided signals
		        .I(DIN), // Input
		        .X(DOUT), // Output
		        .OE(en) 
	        );
			end
		endgenerate
			
endmodule