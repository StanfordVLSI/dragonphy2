module tx_inv(
    input wire logic DIN,
    output wire logic DOUT 
);

assign DOUT = ~DIN;

endmodule