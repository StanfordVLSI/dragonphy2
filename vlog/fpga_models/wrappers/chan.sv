`include "iotype.sv"

module chan (
    input `pwl_t data_ana_i,
    output `pwl_t data_ana_o,
    input wire logic cke
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] emu_dt;

    // declare formats
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(PWL_FMT, `PWL_WIDTH, `PWL_EXPONENT);

    chan_core #(
        `PASS_REAL(in_, PWL_FMT),
        `PASS_REAL(out, PWL_FMT),
        `PASS_REAL(dt_sig, DT_FMT)
    ) chan_core_i (
        .in_(data_ana_i),
        .out(data_ana_o),
        .dt_sig(emu_dt),
        .clk(emu_clk),
        .rst(emu_rst),
        .cke(cke)
    );
endmodule