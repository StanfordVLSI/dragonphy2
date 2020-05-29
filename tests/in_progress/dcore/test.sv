module test;
    acore_debug_intf ad_intf_i();
    jtag_intf jtag_intf_i();

	digital_core idcore(
	    .adbg_intf_i(ad_intf_i),
	    .jtag_intf_i(jtag_intf_i)
	);

	initial begin
	    // declare success
	    $display("Success!");

	    // finish test
	    $finish;
	end
endmodule