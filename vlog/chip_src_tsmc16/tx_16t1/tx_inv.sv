`default_nettype none

module tx_inv (
    input wire logic DIN,
    output wire logic DOUT 
);

    INVD4BWP16P90ULVT inv_4_fixed (
        .I(DIN), // Input
        .ZN(DOUT) // Output
    );

endmodule

`default_nettype wire
