`default_nettype none

module output_buf_tx (
	input wire logic DINN,
	input wire logic DINP,
	input wire logic [17:0] CTL_SLICE_N0,
    input wire logic [17:0] CTL_SLICE_N1,
    input wire logic [17:0] CTL_SLICE_P0,
    input wire logic [17:0] CTL_SLICE_P1,
	inout wire logic DOUTN,
    inout wire logic DOUTP
);

    //////////////////////////////
    // Generate control signals //
    //////////////////////////////

    logic [35:0] CTL_SLICE_N; // Control Signal -
    logic [35:0] CTL_SLICE_P; // Control Signal +

    assign CTL_SLICE_N = {CTL_SLICE_N1, CTL_SLICE_N0};
    assign CTL_SLICE_P = {CTL_SLICE_P1, CTL_SLICE_P0};

    ///////////////////////////////////
    // Instantiate tri-state buffers //
    ///////////////////////////////////

    logic BTN; // Buffer to Termination -
    logic BTP; // Buffer to Termination +

    genvar i;
    generate 
        for (genvar i=0; i<36; i=i+1) begin: iBUF
            // Buffer -
            tx_tri_buf i_tri_buf_n (
                .DIN(DINN),
                .en(CTL_SLICE_N[i]),
                .DOUT(BTN) 
            );
            
            // Buffer +
            tx_tri_buf i_tri_buf_p (
                .DIN(DINP),
                .en(CTL_SLICE_P[i]),
                .DOUT(BTP) 
            );
        end
    endgenerate

    /////////////////
    // Termination //
    /////////////////
    
    termination i_term_n (
        .VinP(BTN),
        .VinN(BTN),
        .Vcm(DOUTN)
    );

    termination i_term_p (
        .VinP(BTP),
        .VinN(BTP),
        .Vcm(DOUTP)
    );

endmodule

`default_nettype wire
