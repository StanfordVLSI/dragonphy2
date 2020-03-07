`include "signals.sv"

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o
);

    generate
        // alias I/O
        `INTF_INPUT_TO_REAL(data_ana_i.value, data_ana_i_value);
        `INTF_OUTPUT_TO_REAL(data_ana_o.value, data_ana_o_value);

        // pass input straight to output
        `ASSIGN_REAL(data_ana_i_value, data_ana_o_value);
    endgenerate

endmodule
