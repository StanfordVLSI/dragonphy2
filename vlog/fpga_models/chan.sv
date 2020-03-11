`include "signals.sv"

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o
);
    generate
        chan_core #(
            `INTF_PASS_REAL(in_, data_ana_i.value),
            `INTF_PASS_REAL(out, data_ana_o.value)
        ) chan_core_i (
            .in_(data_ana_i.value),
            .out(data_ana_o.value)
        );
    endgenerate
endmodule
