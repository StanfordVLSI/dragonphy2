`include "iotype.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    input `pwl_t data_ana_o,
    input wire logic clk_i
);
    // declare formats
    `REAL_FROM_WIDTH_EXP(PWL_FMT, `PWL_WIDTH, `PWL_EXPONENT);

    tx_core #(
        `PASS_REAL(out, PWL_FMT)
    ) tx_core_i (
        .in_(data_i),
        .out(data_ana_o),
        .clk(clk_i)
    );
endmodule