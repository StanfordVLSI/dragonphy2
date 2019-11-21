`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

`include "svreal.sv"

// ANALOG representation
// resolution is about 0.2 mV
// range is about +/- 30 V

`define ANALOG_INPUT svreal.in
`define ANALOG_OUTPUT svreal.out

`define ANALOG_SIGNIFICAND_WIDTH 18
`define ANALOG_EXPONENT -12

`define DECL_ANALOG(name) \
    `MAKE_SVREAL_INTF(``name``, `ANALOG_SIGNIFICAND_WIDTH, `ANALOG_EXPONENT)

`define DECL_ANALOG_LOCAL(name) \
    `MAKE_SVREAL(``name``, `ANALOG_SIGNIFICAND_WIDTH, `ANALOG_EXPONENT)
`define ANALOG_CONST(name, value) \
    `DECL_ANALOG_LOCAL(``name``); \
    assign `SVREAL_SIGNIFICAND(``name``) = `FLOAT_TO_FIXED(``value``, `ANALOG_EXPONENT) 

// DT representation

`define DECL_DT_LOCAL(name) \
    `MAKE_SVREAL(``name``, `DT_WIDTH, `DT_EXPONENT)
`define DT_CONST(name, value) \
    `DECL_DT_LOCAL(``name``); \
    assign `SVREAL_SIGNIFICAND(``name``) = `FLOAT_TO_FIXED(``value``, `DT_EXPONENT) 

`endif // `ifndef __SIGNALS_SV__
