// dragon uses tb mmcm gen_emu_clks time_manager vio

`include "signals.sv"

module fpga_top(
    input wire logic ext_clk_p,
    input wire logic ext_clk_n
);

//////////////////////////////
// instantiate the test bench
//////////////////////////////
tb tb_i ();

//////////////////////////////////////
// instantiate the emulator interface
//////////////////////////////////////
emu_if emu ();

////////////////////////////////////
// Generate clock from which others
// are derived
////////////////////////////////////
logic emu_clk_2x;
mmcm mmcm_i (
    .ext_clk_p(ext_clk_p),
    .ext_clk_n(ext_clk_n),
    .emu_clk_2x(emu_clk_2x)
);

/////////////////////////////////
// generate all emulation clocks
/////////////////////////////////
localparam integer n_clks = 2;
logic clk_vals [n_clks];
logic clks [n_clks];
gen_emu_clks  #(.n(n_clks)) gc_i (
    .emu_clk_2x(emu_clk_2x),
    .emu_clk(emu.clk),
    .clk_vals(clk_vals),
    .clks(clks)
);
// RX
assign clk_vals[0] = tb_i.rx_i.rx_clk_i.clk_val;
assign tb_i.rx_i.rx_clk_i.clk_i = clks[0];
// TX
assign clk_vals[1] = tb_i.tx_clk_i.clk_val;
assign tb_i.tx_clk_i.clk_i = clks[1];

///////////////////////////////////
// generate the emulation timestep
///////////////////////////////////
localparam integer n_dt = 2;
dt_t dt_req [n_dt];
time_manager  #(.n(n_dt)) tm_i (
    .dt_req(dt_req),
    .emu_dt(emu.dt)
);
// RX
assign dt_req[0] = tb_i.rx_i.rx_clk_i.dt_req;
// TX
assign dt_req[1] = tb_i.tx_clk_i.dt_req;

/////////////////////////////////
// Read/Write signals externally
/////////////////////////////////
vio vio_i (
    .emu_rst(emu.rst),
    .prbs_rst(tb_i.prbs_rst),
    .lb_mode(tb_i.lb_mode),
    .lb_latency(tb_i.lb_latency),
    .lb_total_bits(tb_i.lb_total_bits),
    .lb_correct_bits(tb_i.lb_correct_bits),
    .clk(emu.clk)
);

endmodule
