module test;
	tx_debug_intf tx ();

	tx_top top_i (
	    .tx(tx)
	);

	initial begin
	    // declare success
	    $display("Success!");

	    // finish test
	    $finish;
	end
endmodule