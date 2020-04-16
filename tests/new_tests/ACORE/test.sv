module test;
    acore_debug_intf adbg_intf_i();

	analog_core acore_i (
	    .adbg_intf_i(adbg_intf_i)
	);

	initial begin
	    // declare success
	    $display("Success!");

	    // finish test
	    $finish;
	end
endmodule