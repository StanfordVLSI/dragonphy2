interface analog_if ();
    logic signed [31:0] value;
endinterface

 typedef logic signed [31:0] dt_t;

`define ANALOG_INPUT interface
`define ANALOG_OUTPUT interface

`define DECL_ANALOG(x) analog_if x ()
`define DECL_DT(x) dt_t x

// need to define these values
`define EMU_CLK top.emu_clk
`define EMU_RST top.emu_rst
`define EMU_DT top.emu_dt
`define EMU_CLK_VAL top.emu_clk_val
`define EMU_CLK_2X top.emu_clk_2x
