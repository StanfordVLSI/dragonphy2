`ifndef CHUNK_WIDTH
    `define CHUNK_WIDTH 8
`endif

`ifndef NUM_CHUNKS
    `define NUM_CHUNKS 4
`endif

module tb;
    ///////////////
    // Constants //
    ///////////////

    import const_pack::Nti;
    localparam integer chunk_width=`CHUNK_WIDTH;
    localparam integer num_chunks=`NUM_CHUNKS;

    //////////////////
    // External IOs //
    //////////////////

    (* dont_touch = "true" *) logic rstb;
    (* dont_touch = "true" *) logic dump_start;

    (* dont_touch = "true" *) logic tdi;
	(* dont_touch = "true" *) logic tdo;
	(* dont_touch = "true" *) logic tck;
	(* dont_touch = "true" *) logic tms;
	(* dont_touch = "true" *) logic trst_n;

    (* dont_touch = "true" *) logic [31:0] prbs_eqn;

    ////////////////////
	// JTAG Interface //
	////////////////////

	jtag_intf jtag_intf_i ();
	assign jtag_intf_i.phy_tdi = tdi;
    assign tdo = jtag_intf_i.phy_tdo;
    assign jtag_intf_i.phy_tck = tck;
    assign jtag_intf_i.phy_tms = tms;
    assign jtag_intf_i.phy_trst_n = trst_n;

    ////////////////////
	//  Emulator I/O  //
	////////////////////

    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;

    ////////////////
	// Top module //
	////////////////

    logic [(Nti-1):0] data_rx_i;

	(* dont_touch = "true" *) dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(data_rx_i),
		.ext_rx_inn(0),

        // reset
        .ext_rstb(rstb),

        // SRAM dump
        .ext_dump_start(dump_start),

        // JTAG
		.jtag_intf_i(jtag_intf_i)

		// other I/O not used..
	);

    //////////
    // PRBS //
    //////////

    logic [($clog2(num_chunks+2)-1):0] counter;
    logic prbs_cke;

    assign prbs_cke = (counter == (num_chunks+1)) ? 1'b1 : 1'b0;

    always @(posedge emu_clk) begin
        if (emu_rst) begin
            counter <= 0;
        end else if (counter == (num_chunks+1)) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    genvar i;
    generate
        for(i=0; i<Nti; i=i+1) begin
            prbs_generator_syn #(
                .n_prbs(32)
            ) prbs_generator_syn_i (
                .clk(emu_clk),
                .rst(emu_rst),
                .cke(prbs_cke),
                .init_val(i+1),
                .eqn(prbs_eqn),
                .inj_err(1'b0),
                .inv_chicken(2'b00),
                .out(data_rx_i[i])
            );
        end
    endgenerate
endmodule
