module output_buf_tx (
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


    
    // instantiate BUFTD +

    generate 
        for (genvar i=0; i<8; i=i+1) begin: iBUFN
	        tx_tri_buf i_tri_buf (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N[i]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate


    generate 
        for (genvar j=0; j<8; j=j+1) begin: iBUFP
	        tx_tri_buf i_tri_buf (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P[j]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate

endmodule