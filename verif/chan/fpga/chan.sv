`include "signals.sv"

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o
);

    `SVREAL_ASSIGN(data_ana_i, data_ana_o);

endmodule
