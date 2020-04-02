`default_nettype none

module test;
	
	jtag_intf jtag_intf_i ();

	butterphy_top top_i (.jtag_intf_i(jtag_intf_i));

endmodule

`default_nettype wire
