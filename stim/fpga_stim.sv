// dragon uses fpga_top

module stim;
    logic clk_in1_p, clk_in1_n;

    fpga_top fpga_top_i(
        .clk_in1_p(clk_in1_p),
        .clk_in1_n(clk_in1_n)
    );

    always begin
        clk_in1_p = 1'b0;
        clk_in1_n = 1'b1;
        #(0.5/200e6*1s);
        clk_in1_p = 1'b1;
        clk_in1_n = 1'b0;
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
