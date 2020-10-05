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
);
    DW_tap #(
        .width(5),
        .id(1),
        .version(1),
        .part(55948),
        .man_num(153),
        .sync_mode(1)
    ) DW_tap_i (
        .tck(tck),
        .trst_n(trst_n),
        .tms(tms),
        .tdi(tdi),
        .so(so),
        .bypass_sel(bypass_sel),
        .sentinel_val(sentinel_val),
        
        .clock_dr(clock_dr),
        .shift_dr(shift_dr),
        .update_dr(update_dr),
        .tdo(tdo),
        .tdo_en(tdo_en),
        .tap_state(tap_state),
        .extest(extest),
        .samp_load(samp_load),
        .instructions(instructions),
        .sync_capture_en(sync_capture_en),
        .sync_update_dr(sync_update_dr),

        .test(test)
    );
endmodule