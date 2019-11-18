module sim_ctrl(
    output var logic rst_user = 1'b1,
    input var logic [63:0] number
);
    initial begin
        // wait for emulator reset to complete
        #(10us);

        // run the test
        rst_user = 1'b0; 
        #(100us);

        // check the results
        assert (number >= 400) else
            $error("Not enough successful bits.");
        $finish;
    end
endmodule
