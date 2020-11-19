module test;

	dragonphy_top top_i (
	);

	initial begin
        // Set up probing
        // $shm_open("waves.shm");
        // $shm_probe(top_i.idcore.tx_data_gen_i);

		// Finish test
		$display("Test complete.");
		$finish;
	end

endmodule
