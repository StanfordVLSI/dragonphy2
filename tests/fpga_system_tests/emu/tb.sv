module tb;
    // External IOs
    logic rstb;
    logic tdi;
	logic tdo;
	logic tck;
	logic tms;
	logic trst_n;

	// JTAG Interface
	jtag_intf jtag_intf_i ();

	// Instantiate top module
	dragonphy_top top_i (
        .ext_rstb(rstb),
		.jtag_intf_i(jtag_intf_i)
	);
	
	// Assign interface signals
	assign jtag_intf_i.phy_tdi = tdi;
    assign tdo = jtag_intf_i.phy_tdo;
    assign jtag_intf_i.phy_tck = tck;
    assign jtag_intf_i.phy_tms = tms;
    assign jtag_intf_i.phy_trst_n = trst_n;
endmodule
