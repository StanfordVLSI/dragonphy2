// dragon uses fpga_top

module stim;

    localparam real emu_clk_2x_freq = 20e6;
    logic emu_clk_2x;

    fpga_top fpga_top_i(
        // NOTE: the port "emu_clk" on fpga_top is really
        // emu_clk_2x, but could not be given that name yet
        // due to an implementation issue.
        .emu_clk(emu_clk_2x)
    );

    always begin
        emu_clk_2x = 1'b0;
        #((0.5/emu_clk_2x_freq)*1s);
        emu_clk_2x = 1'b1;
        #((0.5/emu_clk_2x_freq)*1s);
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
