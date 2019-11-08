`include "signals.sv"

module rx_cmp (
    `ANALOG_INPUT in,
    output wire logic out
);

    generate
        // alias analog I/O
        `SVREAL_ALIAS_INPUT(in.value, in_value);

        // compare to zero
        `ANALOG_CONST(zero, 0);
        `SVREAL_GT(in_value, zero, out);
    endgenerate

endmodule
