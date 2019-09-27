module vio (
    output wire logic emu_rst,
    output wire logic rst_user,
    input wire logic [63:0] number,
    input wire logic clk
);

    // instantiate vio here...

    vio_0 vio_0_i (
        .clk(clk),
        .probe_in0(number),
        .probe_out0(emu_rst),
        .probe_out1(rst_user)
    );

endmodule
