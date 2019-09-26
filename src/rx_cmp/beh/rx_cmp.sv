module rx_cmp (
    interface in,
    output wire logic out
);

    assign out = in.value > 0;

endmodule
