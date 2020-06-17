`include "iotype.sv"

module tb;
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
    (* dont_touch = "true" *) `DECL_DT(emu_dt);
    (* dont_touch = "true" *) `DECL_DT(dt_req);

    //////////////
	// TX clock //
    //////////////

    (* dont_touch = "true" *) logic clk_tx_val_posedge;
    my_edgedet det_i (
        .val(clk_tx_val),
        .clk(emu_clk),
        .rst(emu_rst),
        .edge_p(clk_tx_val_posedge),
        .edge_n()
    );

    `DECL_DT(t_lo);
    `ASSIGN_CONST_REAL(31.25e-12, t_lo);

    `DECL_DT(t_hi);
    `ASSIGN_CONST_REAL(31.25e-12, t_hi);

    (* dont_touch = "true" *) osc_model_core #(
        `PASS_REAL(t_lo, t_lo),
        `PASS_REAL(t_hi, t_hi),
        `PASS_REAL(emu_dt, emu_dt),
        `PASS_REAL(dt_req, dt_req)
    ) tx_clk_i (
        .emu_rst(emu_rst),
        .emu_clk(emu_clk),
        .t_lo(t_lo),
        .t_hi(t_hi),
        .emu_dt(emu_dt),
        .dt_req(dt_req),
        .clk_val(clk_tx_val)
    );

    /////////////////
    // Transmitter //
    /////////////////

    (* dont_touch = "true" *) logic data_tx_i;
    (* dont_touch = "true" *) `DECL_PWL(data_tx_o);

    (* dont_touch="true" *) tx_core #(
        `PASS_REAL(out, data_tx_o)
    ) tx_core_i (
        .in_(data_tx_i),
        .out(data_tx_o),
        .cke(clk_tx_val),
        .clk(emu_clk),
        .rst(emu_rst)
    );

    /////////////
    // Channel //
    /////////////

    (* dont_touch = "true" *) `DECL_PWL(data_rx_i);

    (* dont_touch = "true" *) chan_core #(
        `PASS_REAL(in_, data_tx_o),
        `PASS_REAL(out, data_rx_i),
        `PASS_REAL(dt_sig, emu_dt)
    ) chan_i (
        .in_(data_tx_o),
        .out(data_rx_i),
        .dt_sig(emu_dt),
        .clk(emu_clk),
        .rst(emu_rst),
        .cke(clk_tx_val_posedge)
    );

    ///////////////////
	// Clock divider //
	///////////////////

    (* dont_touch = "true" *) logic ext_clkp;

    // divide 16 GHz clock by two to get 8 GHz clock
    always @(posedge emu_clk) begin
        if (emu_rst == 1'b1) begin
            ext_clkp <= 1'b0;
        end else if (clk_tx_val_posedge) begin
            ext_clkp <= ~ext_clkp;
        end else begin
            ext_clkp <= ext_clkp;
        end
    end

    ////////////////
	// Top module //
	////////////////

	(* dont_touch = "true" *) dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(data_rx_i),
		.ext_rx_inn(0),

        // clock inputs
        .ext_clkp(ext_clkp),
        .ext_clkn(1'b0),

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

    (* dont_touch = "true" *) prbs_generator_syn #(
        .n_prbs(32)
    ) prbs_generator_syn_i (
        .clk(emu_clk),
        .rst(emu_rst),
        .cke(clk_tx_val_posedge),
        .init_val(32'h00000001),
        .eqn(32'b00000000000000000000000001100000),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(data_tx_i)
    );

endmodule
