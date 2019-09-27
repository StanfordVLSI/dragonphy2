module vio (
    output wire logic emu_rst,
    input wire logic [63:0] number,
    input wire logic clk
);

    // instantiate vio here...

    vio_0 vio_0_i (
        .clk(clk),
        .probe_in0(number),
        .probe_out0(emu_rst)
    );

endmodule
