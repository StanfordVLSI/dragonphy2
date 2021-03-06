// simple model used for performance comparison with emulation

`timescale 1s/1fs

module V2T_clock_gen_S2D (
    input wire logic in,        // input signal
    output wire logic out,      // delayed output signal (+)
    output reg outb             // delayed output signal (-)
);

    assign out = in;
    assign outb = ~in;

endmodule
