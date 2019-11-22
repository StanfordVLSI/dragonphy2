module sim_ctrl(
    input wire logic [7:0] lb_latency,
    input wire logic [63:0] lb_correct_bits,
    input wire logic [63:0] lb_total_bits,
    output var logic prbs_rst=1'b1,
    output var logic [1:0] lb_mode=2'b00,
    output var logic [31:0] tm_stall=27'h3FFFFFF
);
    logic [7:0] lb_latency_local;
    logic [63:0] lb_correct_bits_local;
    logic [63:0] lb_total_bits_local;

    initial begin
        // wait for emulator reset to complete
        #(10us);

        // initialize signals
        tm_stall = 27'h3FFFFFF;
        prbs_rst = 1'b1;
        lb_mode = 2'b00;
        #(1us);

        // align the loopback tester
        prbs_rst = 1'b0;
        lb_mode = 2'b01;
        #(100us);

        // run the loopback test
        lb_mode = 2'b10;
        #(5500us);

        // halt emulation
        tm_stall = 27'h0000000;
        #(10us);

        // read results
        lb_latency_local = lb_latency;
        #(10us);
        lb_correct_bits_local = lb_correct_bits;
        #(10us);
        lb_total_bits_local = lb_total_bits;
        #(10us);

        // print results
        $display("Loopback latency: %0d cycles.", lb_latency_local);
        $display("Loopback correct bits: %0d.", lb_correct_bits_local);
        $display("Loopback total bits: %0d.", lb_total_bits_local);

        // check results
        assert (lb_total_bits_local >= 10000) else
            $error("Not enough total bits transmitted.");
        assert (lb_total_bits_local == lb_correct_bits_local) else
            $error("Bit error detected.");
        $finish;
    end
endmodule
