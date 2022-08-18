`default_nettype none

interface signed_dataflow_intf import const_pack::*; #(
    parameter integer bitwidth = 8,
    parameter integer width    = 16
)(

);
    logic signed [bitwidth-1:0] data [width-1:0];
    logic [bitwidth-1:0] cycle_delay;
    logic [$clog2(width)-1:0] shift_delay;

    modport snk (
        input data,
        input cycle_delay,
        input shift_delay
    );

    modport src (
        output data,
        output cycle_delay,
        output shift_delay
    );

endinterface

interface dataflow_intf import const_pack::*; #(
    parameter integer bitwidth = 8,
    parameter integer width    = 16
)(

);
    logic [bitwidth-1:0] data [width-1:0];
    logic [bitwidth-1:0] cycle_delay;
    logic [$clog2(width)-1:0] shift_delay;

    modport snk (
        input data,
        input cycle_delay,
        input shift_delay
    );

    modport src (
        output data,
        output cycle_delay,
        output shift_delay
    );

endinterface

`default_nettype wire