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
        // mux between +/- 1
        `ANALOG_CONST(volt0, v_lo);
        `ANALOG_CONST(volt1, v_hi);
        `DECL_ANALOG_LOCAL(out_imm);
        `ITE_INTO_REAL(data_i, volt1, volt0, out_imm);

        // assign to output with DFF
        `INTF_OUTPUT_TO_REAL(data_ana_o.value, data_ana_o_value);
        `DFF_INTO_REAL(out_imm, data_ana_o_value, 1'b0, clk_i, 1'b1, 0.0);
    endgenerate

endmodule
