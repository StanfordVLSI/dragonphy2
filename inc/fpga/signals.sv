`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

`include "svreal.sv"

// analog representation
// resolution is about 0.2 mV
// range is about +/- 30 V

interface svreal #(
    `INTF_DECL_REAL(value)
);
    `INTF_MAKE_REAL(value);
    logic valid;
    modport in(`MODPORT_IN_REAL(value), input valid);
    modport out(`MODPORT_OUT_REAL(value), output valid);
endinterface

`define ANALOG_INPUT svreal.in
`define ANALOG_OUTPUT svreal.out

`define ANALOG_WIDTH 18
`define ANALOG_EXPONENT -12

`define DECL_ANALOG(name) \
    svreal #(`REAL_INTF_PARAMS(value, `ANALOG_WIDTH, `ANALOG_EXPONENT)) ``name`` ()

// clock representation

interface clock_intf;
    logic clock;
    logic value;
    modport in(input clock, input value);
    modport out(output clock, output value);
endinterface

`define CLOCK_INPUT clock_intf.in
`define CLOCK_OUTPUT clock_intf.out

`define DECL_CLOCK(name) \
    clock_intf ``name`` ()

`define CLOCK_NET(name) ``name``.clock

`define ASSIGN_CLOCK(lhs, rhs) \
    assign lhs.clock = rhs.clock; \
    assign lhs.value = rhs.value

`endif // `ifndef __SIGNALS_SV__
