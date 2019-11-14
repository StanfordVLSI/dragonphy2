// dragon uses tb time_manager

`include "signals.sv"

module fpga_top;

//////////////////////////////
// instantiate the test bench
//////////////////////////////
tb tb_i ();

//////////////////////////////////////
// instantiate the emulator interface
//////////////////////////////////////
emu_if emu ();

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
