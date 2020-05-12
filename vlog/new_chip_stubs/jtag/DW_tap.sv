module DW_tap #(
    parameter width= 2,
    parameter id=0,
    parameter version=0,
    parameter part=0,
    parameter man_num=0,
    parameter sync_mode=0
) (
    input tck,
    input trst_n,
    input tms,
    input tdi,
    input so,
    input bypass_sel,
    input [(width-2):0] sentinel_val,

    output clock_dr,
    output shift_dr,
    output update_dr,
    output tdo,
    output tdo_en,
    output [15:0] tap_state,
    output extest,
    output samp_load,
    output [(width-1):0] instructions,
    output sync_capture_en,
    output sync_update_dr,

    input test
);
endmodule