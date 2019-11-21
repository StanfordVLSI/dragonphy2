`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);

    generate
        // constants
        `ANALOG_CONST(zero,   0);
        `ANALOG_CONST(volt0, v_lo);
        `ANALOG_CONST(volt1, v_hi);

        // mux between +/- 1
        `DECL_ANALOG_LOCAL(out_imm);
        `SVREAL_MUX(data_i, volt0, volt1, out_imm);

        // assign to output with DFF
        `SVREAL_ALIAS_OUTPUT(data_ana_o.value, data_ana_o_value);
        `SVREAL_DFF(out_imm, data_ana_o_value, 1'b0, clk_i, 1'b1, zero);
    endgenerate

endmodule
