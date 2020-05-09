module mux4_fixed #(
) (
    input wire logic [3:0] in,           // input signal
    input wire logic [1:0] sel,          // selection signal
    output wire out                      // delayed output signal
);

assign out = in[sel];

endmodule
