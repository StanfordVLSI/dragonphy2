`default_nettype none

module test;

	jtag_intf jtag_intf_i ();

	dragonphy_top top_i (
	    .jtag_intf_i(jtag_intf_i)
	);

	initial begin
	    // declare success
	    $display("Success!");

	    // finish test
	    $finish;
	end

endmodule

`default_nettype wire
