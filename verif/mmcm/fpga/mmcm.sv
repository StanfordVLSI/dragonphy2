module mmcm (
    `ifdef anasymod_diff_clk
        input wire logic clk_in1_p,
        input wire logic clk_in1_n,
    `else
        input wire logic clk_in1,
    `endif
    output var logic emu_clk_2x
);

    logic locked;
    logic dbg_clk;
    clk_wiz_0 wiz_i (
        .clk_out1(emu_clk_2x),
        .clk_out2(dbg_clk),
        .reset(0),
        .locked(locked),
        .clk_in1_p(clk_in1_p),
        .clk_in1_n(clk_in1_n)
    );

endmodule

