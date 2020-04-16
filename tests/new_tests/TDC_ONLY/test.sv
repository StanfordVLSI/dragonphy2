`timescale 1fs/1fs

`ifndef DELAY_TXT
    `define DELAY_TXT
`endif

`ifndef ADDER_TXT
    `define ADDER_TXT
`endif

module test;
    import const_pack::Nadc;

	logic clk_adder;
	clock #(
		.freq(1e9),
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(clk_adder),
		.ckoutb()
	);

    logic clk_TDC_d;
    dcdl_coarse idcdl_coarse (
        .thm(0),
        .out(clk_TDC_d),
        .in(clk_adder)
    );

    logic pfd_out = 1'b0;
    logic [(2**Nadc)-2:0] ff_out;
    TDC_delay_chain_PR idchain (
        .Tin(pfd_out),
        .del_out(),
        .ff_out(ff_out),
        .clk(clk_TDC_d),
        .en_phase_reverse(1'b0),
        .clk_phase_reverse(1'b0)
    );

    logic [Nadc-1:0] adder_out;
    wallace_adder iadder (
        .d_out(adder_out),
        .d_in(ff_out),
        .sign_out(),
        .sign_in(1'b0),
        .clk(clk_adder)
    );

    task pulse(input real width);
        pfd_out = 1'b1;
        #(width*1s);
        pfd_out = 1'b0;
    endtask

    // stimulus parameters
	localparam real delay = 100e-12;
	localparam real width_min = 0e-12;
	localparam real width_max = 0.8e-9;
	localparam real width_delta = 1e-12;

    // Data recording

    logic record=1'b0;

    real width;
    real_recorder #(
        .filename(`DELAY_TXT)
    ) delay_recorder_i (
		.in(width),
		.clk(record),
		.en(1'b1)
	);

    logic_recorder #(
        .n(Nadc),
        .filename(`ADDER_TXT)
    ) adder_recorder_i (
        .in(adder_out),
        .clk(record),
        .en(1'b1)
    );

	// Main test
	initial begin
        // Wait a little bit
        #(10ns);

        // Walk through the different delays input voltages
		for (width = width_min;
		     width <= width_max + width_delta;
		     width = width + width_delta
		) begin
			$display("Width: %0.3f ps", width*1e12);

            @(posedge clk_adder);
            #(delay*1s);
            pulse(width);

            // wait two cycles: one to sample data, and the
            // other to sum data
            @(posedge clk_adder);
            #1;
            @(posedge clk_adder);
            #1;

			record = 1'b1;
			#1;
			record = 1'b0;
		    #1;
		end

		$finish;
	end
endmodule


