`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

// analog representation

interface analog_if ();
    // internal signals
    real value;
    event req;
    event ack;
    // task to request and wait for a value update
    task update();
        ->>req;
        @(ack);
    endtask
endinterface

`define ANALOG_INPUT analog_if
`define ANALOG_OUTPUT analog_if
`define DECL_ANALOG(name) analog_if ``name`` ()

// clock representation

interface clock_intf;
    logic clock;
    modport in(input clock);
    modport out(output clock);
endinterface

`define CLOCK_INPUT clock_intf.in
`define CLOCK_OUTPUT clock_intf.out

`define DECL_CLOCK(name) \
    clock_intf ``name`` ()

`define CLOCK_NET(name) ``name``.clock

`define ASSIGN_CLOCK(lhs, rhs) \
    assign lhs.clock = rhs.clock

`endif // `ifndef __SIGNALS_SV__
