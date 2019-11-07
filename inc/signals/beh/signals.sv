`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

interface analog_if ();
    real value;
endinterface

`define ANALOG_INPUT interface
`define ANALOG_OUTPUT interface

`define DECL_ANALOG(x) analog_if x ()

`endif // `ifndef __SIGNALS_SV__
