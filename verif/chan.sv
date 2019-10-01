`include "signals.sv"

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o
);

    assign data_ana_o.value = data_ana_i.value;

endmodule
