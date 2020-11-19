`default_nettype none

module mdll_inv (
    input wire logic DIN,
    output wire logic DOUT 
);

    BUFFD2BWP16P90ULVT inv_1_fixed (
        .I(DIN), // Input
        .Z(DOUT) // Output
    );

endmodule

`default_nettype wire
