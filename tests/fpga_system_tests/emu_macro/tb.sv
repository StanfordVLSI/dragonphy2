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

    ////////////////////
	// JTAG Interface //
	////////////////////

    //initial begin
    //   $dumpvars(0, top_i);
    //end

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
    (* dont_touch = "true" *) logic [31:0] prbs_eqn;

    ////////////////
	// Top module //
	////////////////
    logic inp_sel;

    logic [(Nti*2-1):0] data_rx_i;
    logic [(Nti*2-1):0] puls_out;
    logic [(Nti*2-1):0] prbs_out;

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

    // initial values for the PRBS generators that have been selected
    // to match the behavior of a single PRBS generator seeded with 32'h1
    // see experiments/prbs/gather.py for more details
    logic [31:0] prbs_init_vals [32];
    assign prbs_init_vals[0]  = 32'h00100043;
    assign prbs_init_vals[1]  = 32'h0123049a;
    assign prbs_init_vals[2]  = 32'h1060428b;
    assign prbs_init_vals[3]  = 32'h25ce814c;
    assign prbs_init_vals[4]  = 32'h0103041c;
    assign prbs_init_vals[5]  = 32'h12264bbf;
    assign prbs_init_vals[6]  = 32'h050e045a;
    assign prbs_init_vals[7]  = 32'h4a9e0684;
    assign prbs_init_vals[8]  = 32'h10204387;
    assign prbs_init_vals[9]  = 32'h21429324;
    assign prbs_init_vals[10] = 32'h40820e30;
    assign prbs_init_vals[11] = 32'h851c4e8f;
    assign prbs_init_vals[12] = 32'h0102142a;
    assign prbs_init_vals[13] = 32'h02072878;
    assign prbs_init_vals[14] = 32'h041852ee;
    assign prbs_init_vals[15] = 32'h0b3a8934;
    assign prbs_init_vals[16] = 32'h0003002c;
    assign prbs_init_vals[17] = 32'h0016021e;
    assign prbs_init_vals[18] = 32'h030a2ce8;
    assign prbs_init_vals[19] = 32'h16761245;
    assign prbs_init_vals[20] = 32'h00100246;
    assign prbs_init_vals[21] = 32'h032628d4;
    assign prbs_init_vals[22] = 32'h10624b95;
    assign prbs_init_vals[23] = 32'h2cfc26cc;
    assign prbs_init_vals[24] = 32'h03062c58;
    assign prbs_init_vals[25] = 32'h162e1a3d;
    assign prbs_init_vals[26] = 32'h0c38b1e6;
    assign prbs_init_vals[27] = 32'h5afe61c1;
    assign prbs_init_vals[28] = 32'h1022428d;
    assign prbs_init_vals[29] = 32'h2064859c;
    assign prbs_init_vals[30] = 32'h428f020c;
    assign prbs_init_vals[31] = 32'ha5de810f;

    localparam integer pulse_width_period = 32*31;

    logic [pulse_width_period-1:0] puls_count;
    always_ff @(posedge prbs_cke or negedge rstb) begin
        if(~rstb) begin
            puls_count <= 1;
        end else begin
            puls_count <= {puls_count[29:0], puls_count[pulse_width_period-1:30]};
        end
    end

    genvar i;
    generate
        for(i=0; i<Nti*2; i=i+1) begin
            assign puls_out[i] = puls_count[i];
            assign data_rx_i[i] = puls_out[i];

            prbs_generator_syn #(
                .n_prbs(32)
            ) prbs_generator_syn_i (
                .clk(emu_clk),
                .rst(emu_rst),
                .cke(prbs_cke),
                .init_val(prbs_init_vals[i]),
                .eqn(prbs_eqn),
                .inj_err(1'b0),
                .inv_chicken(2'b00),
                .out(prbs_out[i])
                //.out(data_rx_i[i])
            );
        end
    endgenerate


endmodule
