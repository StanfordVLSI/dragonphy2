
module x_nor #(
) (
    input wire logic in1,                // input signal
    input wire logic in2,                // input signal
    output wire out                      // delayed output signal
);


assign out = ~(in1 ^ in2);

endmodule
