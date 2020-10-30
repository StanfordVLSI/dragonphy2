module output_buf_tx #(

) (
	input wire logic DINN,
	input wire logic DINP,
	input wire logic [7:0] CTL_SLICE_N,
    input wire logic [7:0] CTL_SLICE_P,
	output wire logic DOUTN,
    output wire logic DOUTP
);
	// Internal connections
    wire logic BTN; // Buffer to Termination -
    wire logic BTP; // Buffer to Termination +


    // Termination 
    `ifndef VIVADO
        
        termination iterm_n(
            .VinP(DOUTN),
            .VinN(DOUTN),
            .Vcm(BTN)
        );

        termination iterm_p(
            .VinP(DOUTP),
            .VinN(DOUTP),
            .Vcm(BTP)
        );

    `endif
    
    // instantiate BUFTD +
    genvar i;
    generate 
        for (i=0; i<8; i=i+1) begin: iBUF
	        BUFTD4BWP16P90 tri_buf (
		        // user-provided signals
		        .I(DINN), // Input
		        .X(BTN), // Output
		        .OE(CTL_SLICE_N[i]) 
	        );
        end
    endgenerate

    genvar j;
    generate 
        for (j=0; j<8; j=j+1) begin: iBUF
	        BUFTD4BWP16P90 tri_buf (
		        // user-provided signals
		        .I(DINP), // Input
		        .X(BTP), // Output
		        .OE(CTL_SLICE_P[j]) 
	        );
        end
    endgenerate



endmodule