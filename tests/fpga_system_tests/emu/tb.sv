`include "iotype.sv"

module tb;
    //////////////////
    // External IOs //
    //////////////////

    logic rstb;
    logic prbs_rst;

    logic tdi;
	logic tdo;
	logic tck;
	logic tms;
	logic trst_n;

    ////////////////////
	// JTAG Interface //
	////////////////////

	jtag_intf jtag_intf_i ();
	assign jtag_intf_i.phy_tdi = tdi;
    assign tdo = jtag_intf_i.phy_tdo;
    assign jtag_intf_i.phy_tck = tck;
    assign jtag_intf_i.phy_tms = tms;
    assign jtag_intf_i.phy_trst_n = trst_n;

    /////////////////
    // Transmitter //
    /////////////////

    logic data_tx_i;
    `pwl_t data_tx_o;
    (* dont_touch = "true" *) logic clk_tx_i;  // written via abs path

    tx tx_i (
        .data_i(data_tx_i),
        .data_ana_o(data_tx_o),
        .clk_i(clk_tx_i)
    );

    /////////////
    // Channel //
    /////////////

    `pwl_t data_rx_i;

    (* dont_touch = "true" *) logic clk_tx_val;  // read via abs path
    chan chan_i (
        .data_ana_i(data_tx_o),
        .data_ana_o(data_rx_i),
        .cke(clk_tx_val)
    );

    ////////////////
	// Top module //
	////////////////

	dragonphy_top top_i (
	    // analog inputs
		.ext_rx_inp(data_rx_i),
		.ext_rx_inn(0),

        // reset
        .ext_rstb(rstb),

        // JTAG
		.jtag_intf_i(jtag_intf_i)

		// other I/O not used..
	);

    //////////////
	// TX clock //
    //////////////

    osc_model tx_clk_i (
        .clk_o_val(clk_tx_val)
    );

    //////////
    // PRBS //
    //////////

    prbs_generator_syn #(
        .n_prbs(32)
    ) prbs_generator_syn_i (
        .clk(clk_tx_i),
        .rst(prbs_rst),
        .cke(1'b1),
        .init_val(32'h00000001),
        .eqn(32'b00000000000000000000000001100000),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(data_tx_i)
    );

endmodule
