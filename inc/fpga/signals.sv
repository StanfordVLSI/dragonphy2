`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

`include "svreal.sv"

// svreal interface
interface svreal #(
    `INTF_DECL_REAL(value)
);
    `INTF_MAKE_REAL(value);
    modport in(`MODPORT_IN_REAL(value));
    modport out(`MODPORT_OUT_REAL(value));
endinterface

// analog representation
// resolution is about 0.2 mV
// range is about +/- 30 V

`define ANALOG_INPUT svreal.in
`define ANALOG_OUTPUT svreal.out

`define ANALOG_WIDTH 18
`define ANALOG_EXPONENT -12

`define DECL_ANALOG(name) \
    svreal #(`REAL_INTF_PARAMS(value, `ANALOG_WIDTH, `ANALOG_EXPONENT)) ``name`` ()

`endif // `ifndef __SIGNALS_SV__
