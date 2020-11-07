module tx_inv(
    input wire logic DIN,
    output logic DOUT 
);

assign DOUT = ~DIN;
endmodule