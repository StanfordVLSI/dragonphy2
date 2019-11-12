// dragon uses fpga_top

module stim;

    logic clk_in1;

    `ifdef ANASYMOD_DIFF_CLK
        logic clk_in1_p;
        logic clk_in1_n;
        assign clk_in1_p =  clk_in1;
        assign clk_in1_n = ~clk_in1;
    `endif

    fpga_top fpga_top_i(
        `ifdef ANASYMOD_DIFF_CLK
            .clk_in1_p(clk_in1_p),
            .clk_in1_n(clk_in1_n)
        `else
            .clk_in1(clk_in1)
        `endif
    );

    always begin
        clk_in1 = 1'b0;
        #(0.5/200e6*1s);
        clk_in1 = 1'b1;
        #(0.5/200e6*1s);
    end

    initial begin
        force fpga_top_i.emu.rst = 1'b1;
        force fpga_top_i.tb_i.rst_user = 1'b1;
        #(3us);
        force fpga_top_i.emu.rst = 1'b0;
        #(3us);
        force fpga_top_i.tb_i.rst_user = 1'b0; 
        #(100us);
        assert (fpga_top_i.tb_i.number >= 400) else
            $error("Not enough successful bits.");
        $finish;
    end
endmodule
