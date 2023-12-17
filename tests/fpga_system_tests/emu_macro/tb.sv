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

    logic [(2+Nti*2-1):-2] data_rx_i;
    logic [(Nti*2-1):0] puls_out;
    logic [(2+Nti*2-1):-2] prbs_out;

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

    logic pi_late;
    logic pi_early;

    assign pi_late = top_i.iacore.pi_late_ext;
    assign pi_early = top_i.iacore.pi_early_ext;

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
    logic [31:0] prbs_init_vals  [33:-2];
    logic [31:0] prbs_state_vals [33:-2];




    assign prbs_init_vals[-2] = 32'h39406d25;
    assign prbs_init_vals[-1] = 32'h1fa44802;
    assign prbs_init_vals[0]  = 32'h5bda4b69;
    assign prbs_init_vals[1]  = 32'h25fdb240;
    assign prbs_init_vals[2]  = 32'h397bbecb;
    assign prbs_init_vals[3]  = 32'h4dbfed92;
    assign prbs_init_vals[4]  = 32'h2ccb4df6;
    assign prbs_init_vals[5]  = 32'h126dff6d;
    assign prbs_init_vals[6]  = 32'h562c834d;
    assign prbs_init_vals[7]  = 32'h3726ddbf;
    assign prbs_init_vals[8]  = 32'h37db2092;
    assign prbs_init_vals[9]  = 32'h4b6dbfff;
    assign prbs_init_vals[10] = 32'h3a827964;
    assign prbs_init_vals[11] = 32'h1b4949b6;
    assign prbs_init_vals[12] = 32'h5924d249;
    assign prbs_init_vals[13] = 32'h2492db6d;
    assign prbs_init_vals[14] = 32'h3c214412;
    assign prbs_init_vals[15] = 32'h4ed01b49;
    assign prbs_init_vals[16] = 32'h2fe99200;
    assign prbs_init_vals[17] = 32'h16f692db;
    assign prbs_init_vals[18] = 32'h55afad92;
    assign prbs_init_vals[19] = 32'h36ff6db6;
    assign prbs_init_vals[20] = 32'h322dff6d;
    assign prbs_init_vals[21] = 32'h49b6db6d;
    assign prbs_init_vals[22] = 32'h3832edff;
    assign prbs_init_vals[23] = 32'h1d9b0092;
    assign prbs_init_vals[24] = 32'h5f6dffff;
    assign prbs_init_vals[25] = 32'h2db64924;
    assign prbs_init_vals[26] = 32'h2b0949b6;
    assign prbs_init_vals[27] = 32'h6d249249;
    assign prbs_init_vals[28] = 32'h6492db6d;
    assign prbs_init_vals[29] = 32'h92492493;
    assign prbs_init_vals[30] = 32'h7280da4b;
    assign prbs_init_vals[31] = 32'h3f489004;
    assign prbs_init_vals[32] = 32'hb7b496d3;
    assign prbs_init_vals[33] = 32'h4bfb6480;

    localparam integer pulse_width_period = 34;
    logic [4:0] counter_puls, next_counter_puls;

    logic [pulse_width_period-1:0] puls_count;
    logic [pulse_width_period-1:0] next_puls_count;
    logic [pulse_width_period-1:0] puls_count_shift_left;
    logic [pulse_width_period-1:0] puls_count_shift_right;

    assign puls_count_shift_left  = {puls_count[31:0], puls_count[33:32]};
    assign puls_count_shift_right = {puls_count[1:0], puls_count[33:2]};

    always_comb begin
        if (pi_late && ~pi_early) begin
            next_puls_count = puls_count_shift_left;
        end else if (~pi_late && pi_early) begin
            next_puls_count = puls_count_shift_right;
        end else begin
            next_puls_count = puls_count;
        end
        next_puls_count = {next_puls_count[31:0], next_puls_count[33:32]};
    end

    always_ff @(posedge prbs_cke or negedge rstb) begin
        if(~rstb) begin
            puls_count <= 2;
        end else begin
            puls_count <= next_puls_count;
        end
    end


    genvar i;
    generate
        prbs_generator_syn #(
            .n_prbs(32)
        ) prbs_generator_syn_i_m2 (
            .clk(emu_clk),
            .rst(emu_rst),
            .cke(prbs_cke),
            .init_val(prbs_init_vals[-2]),
            .eqn(prbs_eqn),
            .inj_err(1'b0),
            .inv_chicken(2'b00),
            .out(prbs_out[-2]),
            .late_load(pi_late),
            .late_load_val(prbs_state_vals[Nti*2-4]),
            .early_load(pi_early),
            .early_load_val(prbs_state_vals[0]),
            .run_twice(0),
            .stall(pi_late),
            .prbs_state_ext(prbs_state_vals[-2])
        );

        prbs_generator_syn #(
            .n_prbs(32)
        ) prbs_generator_syn_i_m1 (
            .clk(emu_clk),
            .rst(emu_rst),
            .cke(prbs_cke),
            .init_val(prbs_init_vals[-1]),
            .eqn(prbs_eqn),
            .inj_err(1'b0),
            .inv_chicken(2'b00),
            .out(prbs_out[-1]),
            .late_load(pi_late),
            .late_load_val(prbs_state_vals[Nti*2-3]),
            .early_load(pi_early),
            .early_load_val(prbs_state_vals[1]),
            .run_twice(0),
            .stall(pi_late),
            .prbs_state_ext(prbs_state_vals[-1])
        );

        for(i=0; i<Nti*2; i=i+1) begin
            assign puls_out[i] = puls_count[i];

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
                .out(prbs_out[i]),
                .late_load(pi_late),
                .late_load_val(prbs_state_vals[i-2]),
                .early_load(pi_early),
                .early_load_val(prbs_state_vals[i+2]),
                .run_twice(0),
                .stall(0),
                .prbs_state_ext(prbs_state_vals[i])
            );
        end

        prbs_generator_syn #(
            .n_prbs(32)
        ) prbs_generator_syn_i_p1 (
            .clk(emu_clk),
            .rst(emu_rst),
            .cke(prbs_cke),
            .init_val(prbs_init_vals[32]),
            .eqn(prbs_eqn),
            .inj_err(1'b0),
            .inv_chicken(2'b00),
            .out(prbs_out[32]),
            .late_load(pi_late),
            .late_load_val(prbs_state_vals[2*Nti-2]),
            .early_load(pi_early),
            .early_load_val(prbs_state_vals[2]),
            .run_twice(pi_early),
            .stall(0),
            .prbs_state_ext(prbs_state_vals[32])
        );

        prbs_generator_syn #(
            .n_prbs(32)
        ) prbs_generator_syn_i_p2 (
            .clk(emu_clk),
            .rst(emu_rst),
            .cke(prbs_cke),
            .init_val(prbs_init_vals[33]),
            .eqn(prbs_eqn),
            .inj_err(1'b0),
            .inv_chicken(2'b00),
            .out(prbs_out[33]),
            .late_load(pi_late),
            .late_load_val(prbs_state_vals[2*Nti-1]),
            .early_load(pi_early),
            .early_load_val(prbs_state_vals[3]),
            .run_twice(pi_early),
            .stall(0),
            .prbs_state_ext(prbs_state_vals[33])
        );
        for(i=-2; i<34; i=i+1) begin
            assign data_rx_i[i] = prbs_out[i];
        end

//        for(i=-2; i<0; i=i+1) begin
//            assign data_rx_i[i] = puls_count[34+i];
//        end
//
//        for(i=0; i<(Nti*2); i=i+1) begin
//            assign data_rx_i[i] = puls_out[i];
//        end
//
//        for(i=Nti*2; i<Nti*2+2; i=i+1) begin
//            assign data_rx_i[i] = puls_count[i];
//        end

    endgenerate
 


endmodule
