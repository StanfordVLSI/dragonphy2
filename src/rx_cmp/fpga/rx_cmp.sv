`include "signals.sv"

module rx_cmp (
    `ANALOG_INPUT in,
    output wire logic out
);

    // make a constant called zero
    `DECL_ANALOG(zero);
    `SVREAL_ASSIGN_CONST(zero, 0);

    // compare to input
    `SVREAL_GT(in, zero, out);

endmodule
