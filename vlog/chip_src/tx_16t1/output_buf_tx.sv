module output_buf_tx (
	input wire logic DINN,
	input wire logic DINP,
	input wire logic [35:0] CTL_SLICE_N,
    input wire logic [35:0] CTL_SLICE_P,
	output wire logic DOUTN,
    output wire logic DOUTP
);
	// Internal connections
    wire logic BTN; // Buffer to Termination -
    wire logic BTP; // Buffer to Termination +


    // Termination 

        
        termination iBUF_n(
            .VinP(DOUTN),
            .VinN(DOUTN),
            .Vcm(BTN)
        );

        termination iBUF_p(
            .VinP(DOUTP),
            .VinN(DOUTP),
            .Vcm(BTP)
        );


    
    // instantiate BUFTD -

    generate 
        
        for (genvar i=0; i<36; i=i+1) begin: iBUF_N
	        tx_tri_buf i_tri_buf_n (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N[i]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate


    // instantiate BUFTD +

    generate 
        for (genvar j=0; j<36; j=j+1) begin: iBUF_P
	        tx_tri_buf i_tri_buf_p (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P[j]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate

endmodule