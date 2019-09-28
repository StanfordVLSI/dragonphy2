module mmcm (
    input wire logic ext_clk,
    output var logic emu_clk_2x
);

    logic locked;
    logic dbg_clk;
    clk_wiz_0 wiz_i (
        .clk_out1(emu_clk_2x),
        .clk_out2(dbg_clk),
        .reset(0),
        .locked(locked),
        .clk_in1(ext_clk)
    );

endmodule

