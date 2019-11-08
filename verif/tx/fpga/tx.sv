`include "signals.sv"

module tx (
    input wire logic data_i,
    input wire logic clk_i,
    `ANALOG_OUTPUT data_ana_o
);

    generate
        // constants
        `ANALOG_CONST(zero,   0);
        `ANALOG_CONST(volt0, -1);
        `ANALOG_CONST(volt1, +1);

        // mux between +/- 1
        `DECL_ANALOG(out_imm);
        `SVREAL_MUX(data_i, volt0, volt1, out_imm);

        // assign to output with DFF
        `SVREAL_ALIAS_OUTPUT(data_ana_o.value, data_ana_o_value);
        `SVREAL_DFF(out_imm, data_ana_o_value, 1'b0, clk_i, 1'b1, zero);
    endgenerate

endmodule
