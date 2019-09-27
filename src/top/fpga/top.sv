module top(
    input wire logic ext_clk
);

// instantiate the test bench
tb tb_i ();

// instantiate the emulator interface
emu_if emu ();

// generate emu_clk_2x
logic emu_clk_2x;
mmcm mmcm_i (
    .ext_clk(ext_clk),
    .emu_clk_2x(emu_clk_2x)
);

// generate other clocks
gen_emu_clks  #(.n(2)) gc_i (
    .emu_clk_2x(emu_clk_2x),
    .emu_clk(emu.clk),
    .clk_vals('{tb_i.rx_i.rx_clk_i.clk_val,
                tb_i.tx_clk_i.clk_val}),
    .clks('{tb_i.rx_i.rx_clk_i.clk_int,
            tb_i.tx_clk_i.clk_int})
);

// generate emu_dt
time_manager  #(.n(2)) tm_i (
    .dt_req('{tb_i.rx_i.rx_clk_i.dt_req,
              tb_i.tx_clk_i.dt_req}),
    .emu_dt(emu.dt)
);

// instantiate vio
vio vio_i (
    .emu_rst(emu.rst),
    .rst_user(tb_i.rst_user),
    .number(tb_i.number),
    .clk(emu.clk)
);

endmodule
