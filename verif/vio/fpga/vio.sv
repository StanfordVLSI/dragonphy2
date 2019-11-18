module vio (
    output wire logic emu_rst,
    output wire logic prbs_rst,
    output wire logic [1:0] lb_mode,
    output wire logic [31:0] tm_stall,
    input wire logic [7:0] lb_latency,
    input wire logic [63:0] lb_correct_bits,
    input wire logic [63:0] lb_total_bits,
    input wire logic clk
);

    vio_0 vio_0_i (
        .clk(clk),
        .probe_in0(lb_latency),
        .probe_in1(lb_correct_bits),
        .probe_in2(lb_total_bits),
        .probe_out0(emu_rst),
        .probe_out1(prbs_rst),
        .probe_out2(lb_mode),
        .probe_out3(tm_stall)
    );

endmodule
