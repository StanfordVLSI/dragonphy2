// dragon uses tb

module stim;

    tb tb_i();

    initial begin
        // reset everything
        force tb_i.prbs_rst = 1'b1;
        force tb_i.rx_rstb = 1'b0
        force tb_i.lb_mode = 2'b00;
        #(20ns);
        // align the loopback tester
        force tb_i.prbs_rst = 1'b0;
        force tb_i.rx_rstb = 1'b1;
        force tb_i.lb_mode = 2'b01;
        #(2500ns);
        // run the loopback test
        force tb_i.lb_mode = 2'b10;
        #(21000ns);
        // print results
        $display("Loopback latency: %0d cycles.", tb_i.lb_latency);
        $display("Loopback correct bits: %0d.", tb_i.lb_correct_bits);
        $display("Loopback total bits: %0d.", tb_i.lb_total_bits);
        // check results
        assert (tb_i.lb_total_bits >= 10000) else
            $error("Not enough total bits transmitted.");
        assert (tb_i.lb_total_bits == tb_i.lb_correct_bits) else
            $error("Bit error detected.");
        $finish;
    end

endmodule
