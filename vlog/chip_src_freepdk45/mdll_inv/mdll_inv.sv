`default_nettype none

module mdll_inv (
    input wire logic DIN,
    output wire logic DOUT 
);

    // TODO: is this the right model?
    assign DOUT = ~DIN;

endmodule

`default_nettype wire
