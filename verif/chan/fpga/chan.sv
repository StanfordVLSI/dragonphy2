`include "signals.sv"

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o
);

    generate
        // alias I/O
        `SVREAL_ALIAS_INPUT(data_ana_i.value, data_ana_i_value);
        `SVREAL_ALIAS_OUTPUT(data_ana_o.value, data_ana_o_value);

        // pass input straight to output
        `SVREAL_ASSIGN(data_ana_i_value, data_ana_o_value);
    endgenerate

endmodule
