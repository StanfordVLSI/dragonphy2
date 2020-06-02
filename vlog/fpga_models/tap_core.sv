`timescale 1ns / 1ps

module tap_core (
    input tck,
    input trst_n,
    input tms,
    input tdi,
    input so,
    input bypass_sel,
    input [3:0] sentinel_val,

    output clock_dr,
    output shift_dr,
    output update_dr,
    output tdo,
    output tdo_en,
    output [15:0] tap_state,
    output extest,
    output samp_load,
    output [4:0] instructions,
    output sync_capture_en,
    output sync_update_dr,

    input test
) /* synthesis syn_black_box */; 
endmodule