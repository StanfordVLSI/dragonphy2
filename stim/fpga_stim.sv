// dragon uses fpga_top

module stim;
    logic ext_clk;

    fpga_top fpga_top_i(.ext_clk(ext_clk));

    always begin
        ext_clk = 1'b0;
        #(0.5/125e6*1s);
        ext_clk = 1'b1;
        #(0.5/125e6*1s);
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
