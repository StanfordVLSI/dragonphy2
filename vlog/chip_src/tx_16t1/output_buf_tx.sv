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


    
    // instantiate BUFTD -

    generate 
        for (genvar i=0; i<1; i=i+1) begin: iBUFN
	        tx_tri_buf_2 i_tri_buf (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N[i]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate

    generate 
        for (genvar i=0; i<4; i=i+1) begin: iBUFN
	        tx_tri_buf_4 i_tri_buf (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N[2+i]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate

    generate 
        for (genvar i=0; i<3; i=i+1) begin: iBUFN
	        tx_tri_buf_6 i_tri_buf (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N[5+i]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate


    // instantiate BUFTD +

    generate 
        for (genvar i=0; i<1; i=i+1) begin: iBUFP
	        tx_tri_buf_2 i_tri_buf (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P[i]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate

    generate 
        for (genvar i=0; i<4; i=i+1) begin: iBUFP
	        tx_tri_buf_4 i_tri_buf (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P[2+i]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate

    generate 
        for (genvar i=0; i<3; i=i+1) begin: iBUFP
	        tx_tri_buf_6 i_tri_buf (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P[5+i]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate

endmodule