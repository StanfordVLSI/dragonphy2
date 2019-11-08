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

`define ANALOG_SIGNIFICAND_WIDTH 18
`define ANALOG_EXPONENT -12
`define DECL_ANALOG(name) \
    `MAKE_SVREAL(``name``, `ANALOG_SIGNIFICAND_WIDTH, `ANALOG_EXPONENT)
`define DECL_ANALOG_INTF(name) \
    `MAKE_SVREAL_INTF(``name``, `ANALOG_SIGNIFICAND_WIDTH, `ANALOG_EXPONENT)
`define ANALOG_CONST(name, value) \
    `DECL_ANALOG(``name``); \
    assign `SVREAL_SIGNIFICAND(``name``) = `FLOAT_TO_FIXED(``value``, `ANALOG_EXPONENT)

`define DECL_DT(x) dt_t x

// define location of emulator interface
// if it has not already been overridden
`ifndef EMU
    `define fpga_top.emu
`endif

`endif // `ifndef __SIGNALS_SV__
