`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

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

`endif // `ifndef __SIGNALS_SV__
