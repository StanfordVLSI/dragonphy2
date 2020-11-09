`default_nettype none

module tx_inv (
    input wire logic DIN,
    output wire logic DOUT 
);

    INV_X4 inv_4_fixed (
        .A(DIN),  // Input
        .ZN(DOUT) // Output
    );

endmodule

`default_nettype wire
