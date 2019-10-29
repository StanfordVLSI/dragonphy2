`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

`include "svreal.sv"

typedef logic [31:0] dt_t;

interface emu_if ();
    dt_t dt;
    logic clk;
    logic rst;
endinterface

`define ANALOG_INPUT svreal.in
`define ANALOG_OUTPUT svreal.out

`define DECL_ANALOG(x) `MAKE_SVREAL(x, 18, -12)
`define DECL_DT(x) dt_t x

`define EMU stim.fpga_top_i.emu

`endif // `ifndef __SIGNALS_SV__
