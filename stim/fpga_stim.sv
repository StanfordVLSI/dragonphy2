// dragon uses fpga_top

module stim;
    logic ext_clk_p, ext_clk_n;

    fpga_top fpga_top_i(
        .ext_clk_p(ext_clk_p),
        .ext_clk_n(ext_clk_n)
    );

    always begin
        ext_clk_p = 1'b0;
        ext_clk_n = 1'b1;
        #(0.5/200e6*1s);
        ext_clk_p = 1'b1;
        ext_clk_n = 1'b0;
        #(0.5/200e6*1s);
    end

    logic [7:0] lb_latency;
    logic [63:0] lb_correct_bits;
    logic [63:0] lb_total_bits;

    initial begin
        // reset emulator
        force fpga_top_i.tm_stall = 32'hFFFFFFFF;
        force fpga_top_i.emu.rst = 1'b1;
        #(1us);
        force fpga_top_i.emu.rst = 1'b0;
        #(1us);
        // reset everything else
        force fpga_top_i.tb_i.prbs_rst = 1'b1;
        force fpga_top_i.tb_i.lb_mode = 2'b00;
        #(1us);
        // align the loopback tester
        force fpga_top_i.tb_i.prbs_rst = 1'b0;
        force fpga_top_i.tb_i.lb_mode = 2'b01;
        #(100us);
        // run the loopback test
        force fpga_top_i.tb_i.lb_mode = 2'b10;
        #(5500us);
        // halt emulation
        force fpga_top_i.tm_stall = 32'h00000000;
        #(10us);
        // read results
        lb_latency = fpga_top_i.tb_i.lb_latency;
        #(10us);
        lb_correct_bits = fpga_top_i.tb_i.lb_correct_bits;
        #(10us);
        lb_total_bits = fpga_top_i.tb_i.lb_total_bits;
        #(10us);
        // print results
        $display("Loopback latency: %0d cycles.", lb_latency);
        $display("Loopback correct bits: %0d.", lb_correct_bits);
        $display("Loopback total bits: %0d.", lb_total_bits);
        // check results
        assert (lb_total_bits >= 10000) else
            $error("Not enough total bits transmitted.");
        assert (lb_total_bits == lb_correct_bits) else
            $error("Bit error detected.");
        $finish;
    end
endmodule
