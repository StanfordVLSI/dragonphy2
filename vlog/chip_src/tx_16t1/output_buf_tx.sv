module output_buf_tx (
	input wire logic DINN,
	input wire logic DINP,
	input wire logic [17:0] CTL_SLICE_N0,
    input wire logic [17:0] CTL_SLICE_N1,
    input wire logic [17:0] CTL_SLICE_P0,
    input wire logic [17:0] CTL_SLICE_P1,
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
        
        for (genvar i=0; i<18; i=i+1) begin: iBUF_N0
	        tx_tri_buf i_tri_buf_n0 (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N0[i]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate

    generate 
        
        for (genvar ii=0; ii<18; ii=ii+1) begin: iBUF_N1
	        tx_tri_buf i_tri_buf_n1 (
		        // user-provided signals
		        .DIN(DINN), // Input
		        .en(CTL_SLICE_N1[ii]), // Output
		        .DOUT(BTN) 
	        );
        end
    endgenerate


    // instantiate BUFTD +

    generate 
        for (genvar j=0; j<18; j=j+1) begin: iBUF_P0
	        tx_tri_buf i_tri_buf_p0 (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P0[j]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate

    generate 
        for (genvar jj=0; jj<18; jj=jj+1) begin: iBUF_P1
	        tx_tri_buf i_tri_buf_p1 (
		        // user-provided signals
		        .DIN(DINP), // Input
		        .en(CTL_SLICE_P1[jj]), // Output
		        .DOUT(BTP) 
	        );
        end
    endgenerate



endmodule