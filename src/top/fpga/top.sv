`include "signals.sv"

module top(
    input wire logic ext_clk
);

// instantiate the test bench
tb tb_i ();

// generate emu_clk_2x
logic emu_clk_2x;
mmcm mmcm_i (
    .ext_clk(ext_clk),
    .emu_clk_2x(emu_clk_2x)
);

// generate emu clk by halving emu_clk_2x
logic emu_clk_val;
clk_drv clk_drv_i (
    .in(emu_clk_val),
    .out(emu_clk)
);
assign emu_clk_val = ~clk_drv_i.unbuf;

// generate EMU_DT
`DECL_DT(emu_dt);
time_manager tm_i (
    .rx_dt(tb_i.rx_i.rx_clk_i.dt_req),
    .tx_dt(tb_i.tx_clk_i.dt_req),
    .emu_dt(emu_dt)
);

// instantiate vio
logic emu_rst;
vio vio_i (
    .emu_rst(emu_rst),
    .number(tb_i.number),
    .clk(emu_clk)
);

endmodule
