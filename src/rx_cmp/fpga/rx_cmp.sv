module rx_cmp (
    `ANALOG_INPUT in,
    output wire logic out
);

    assign out = in.value > 0;

endmodule
