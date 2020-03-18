`include "signals.sv"

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;

    // don't use __emu_dt_req, just set it to the highest value possible
    assign __emu_dt_req = {1'b0, {((`DT_WIDTH)-1){1'b1}}};

    // declare format for timestep
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    generate
        chan_core #(
            `INTF_PASS_REAL(in_, data_ana_i.value),
            `INTF_PASS_REAL(out, data_ana_o.value),
            `PASS_REAL(dt, DT_FMT)
        ) chan_core_i (
            .in_(data_ana_i.value),
            .out(data_ana_o.value),
            .dt(__emu_dt),
            .clk(__emu_clk),
            .rst(__emu_rst)
        );
    endgenerate
endmodule
