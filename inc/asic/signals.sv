`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

// analog representation

`define ANALOG_INPUT inout wire
`define ANALOG_OUTPUT inout wire
`define DECL_ANALOG(name) wire ``name``

// clock representation

`define CLOCK_INPUT input wire
`define CLOCK_OUTPUT output wire

`define DECL_CLOCK(name) \
    wire ``name``

`define CLOCK_NET(name) ``name``

`define ASSIGN_CLOCK(lhs, rhs) \
    assign lhs = rhs

`endif // `ifndef __SIGNALS_SV__
