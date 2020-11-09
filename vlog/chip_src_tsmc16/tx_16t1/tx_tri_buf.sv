`default_nettype none

module tx_tri_buf (
    input wire logic DIN,
    input wire logic en,
    output wire logic DOUT 
);

    BUFTD4BWP16P90 tri_buf (
        .I(DIN),  // Input
        .Z(DOUT), // Output
        .OE(en)
    );

endmodule

`default_nettype wire
