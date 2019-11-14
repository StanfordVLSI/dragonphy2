`ifndef __SIGNALS_SV__
`define __SIGNALS_SV__

typedef logic [31:0] dt_t;

`define ANALOG_WIDTH 18
`define ANALOG_EXPONENT -12

interface analog_if ();
    logic signed [((`ANALOG_WIDTH)-1):0] value;
    modport in (input value);
    modport out (output value);
endinterface

interface emu_if ();
    dt_t dt;
    logic clk;
    logic rst;
endinterface

`define ANALOG_INPUT analog_if.in
`define ANALOG_OUTPUT analog_if.out

`define DECL_ANALOG(x) analog_if x ()
`define DECL_DT(x) dt_t x

`define EMU stim.fpga_top_i.emu

`endif // `ifndef __SIGNALS_SV__
