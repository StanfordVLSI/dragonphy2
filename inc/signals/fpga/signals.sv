`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

`include "svreal.sv"

// ANALOG representation
// resolution is about 0.2 mV
// range is about +/- 30 V

interface svreal #(
    `INTF_DECL_REAL(value)
);
    `INTF_MAKE_REAL(value);
    modport in(`MODPORT_IN_REAL(value));
    modport out(`MODPORT_OUT_REAL(value));
endinterface

`define ANALOG_INPUT svreal.in
`define ANALOG_OUTPUT svreal.out

`define ANALOG_WIDTH 18
`define ANALOG_EXPONENT -12

`define DECL_ANALOG(name) \
    svreal #(`REAL_INTF_PARAMS(value, `ANALOG_WIDTH, `ANALOG_EXPONENT)) ``name`` ()

`define DECL_ANALOG_LOCAL(name) \
    `REAL_FROM_WIDTH_EXP(``name``, `ANALOG_WIDTH, `ANALOG_EXPONENT)

`define ANALOG_CONST(name, value) \
    `DECL_ANALOG_LOCAL(``name``); \
    `ASSIGN_CONST_REAL(``value``, ``name``)

// DT representation

`define DECL_DT_LOCAL(name) \
    `REAL_FROM_WIDTH_EXP(``name``, `DT_WIDTH, `DT_EXPONENT)

`define DT_CONST(name, value) \
    `DECL_DT_LOCAL(``name``); \
    `ASSIGN_CONST_REAL(``value``, ``name``)

`endif // `ifndef __SIGNALS_SV__
