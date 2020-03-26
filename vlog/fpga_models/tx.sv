`include "svreal.sv"
`include "signals.sv"

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    `ANALOG_OUTPUT data_ana_o,
    `CLOCK_INPUT clk_i
);
    generate
        tx_core #(
            `INTF_PASS_REAL(out, data_ana_o.value)
        ) tx_core_i (
            .in_(data_i),
            .out(data_ana_o.value),
            .clk(clk_i.clock)
        );
    endgenerate
endmodule
