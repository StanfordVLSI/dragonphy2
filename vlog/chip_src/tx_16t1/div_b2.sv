`default_nettype none

module div_b2 (
    input wire logic clkin,
    input wire logic rst,
    output wire logic clkout
);

    // use instance of ff_c_rn because it
    // has a model with timing in cpu_models
    ff_c_rn ff_i (
        .D(~clkout),
        .CP(clkin),
        .CDN(~rst),
        .Q(clkout)
    );

endmodule

`default_nettype wire
