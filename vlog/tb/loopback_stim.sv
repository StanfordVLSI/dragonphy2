`define MM_PD_I tb_i.rx_i.mm_pd_i
module loopback_stim;

    tb tb_i();

    initial begin
        // reset everything
        $display("Resetting everything...");
        force tb_i.prbs_rst = 1'b1;
        force tb_i.rx_rstb = 1'b0;
        force tb_i.lb_mode = 2'b00;
        #(20ns);
        // take the rx out of reset
        $display("Taking the RX out of reset...");
        force tb_i.prbs_rst = 1'b0;
        force tb_i.rx_rstb = 1'b1;
        #(10000ns);
        // align the loopback tester
        $display("Aligning the loopback tester...");
        force tb_i.lb_mode = 2'b01;
        #(2500ns);
        $display("Loopback latency: %0d cycles.", tb_i.lb_latency);
        // run the loopback test
        $display("Running the loopback test...");
        force tb_i.lb_mode = 2'b10;
        #(21000ns);
        // print results
        $display("Loopback correct bits: %0d.", tb_i.lb_correct_bits);
        $display("Loopback total bits: %0d.", tb_i.lb_total_bits);
        // check results
        assert (tb_i.lb_total_bits >= 10000) else
            $error("Not enough total bits transmitted.");
        assert (tb_i.lb_total_bits == tb_i.lb_correct_bits) else
            $error("Bit error detected.");
        $finish;
    end

    // Simulation debugging
    integer count=0, curr_margin=0, min_margin=1000;
    always @(posedge `MM_PD_I.clk) begin
        count = count + 1;
        curr_margin = `MM_PD_I.val * `MM_PD_I.data_i;
        min_margin = (curr_margin < min_margin) ? curr_margin : min_margin;
        if (count == 1000) begin
            $display("pi_ctl: %0d, min_margin: %0d", `MM_PD_I.pi_ctl, min_margin);
            count = 0;
            min_margin = 1000;
        end
    end
endmodule
