// dragon uses tb gen_emu_clks time_manager

`include "signals.sv"

module fpga_top(
    // NOTE: remember that this is actually "emu_clk_2x"
    input wire logic emu_clk
);

//////////////////////////////
// instantiate the test bench
//////////////////////////////
tb tb_i ();

//////////////////////////////////////
// instantiate the emulator interface
//////////////////////////////////////
emu_if emu ();

/////////////////////////////////
// generate all emulation clocks
/////////////////////////////////
localparam integer n_clks = 2;
logic clk_vals [n_clks];
logic clks [n_clks];
gen_emu_clks  #(.n(n_clks)) gc_i (
    .emu_clk_2x(emu_clk), // NOTE: "emu_clk" is really "emu_clk_2x"
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
`DT_T dt_req [n_dt];
time_manager  #(.n(n_dt)) tm_i (
    .dt_req(dt_req),
    .emu_dt(emu.dt)
);
// RX
assign dt_req[0] = `SVREAL_SIGNIFICAND(tb_i.rx_i.rx_clk_i.dt_req);
// TX
assign dt_req[1] = `SVREAL_SIGNIFICAND(tb_i.tx_clk_i.dt_req);

endmodule
