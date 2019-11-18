module vio (
    output wire logic emu_rst,
    output wire logic prbs_rst,
    output wire logic [1:0] lb_mode,
    input wire logic [7:0] lb_latency,
    input wire logic [63:0] lb_correct_bits,
    input wire logic [63:0] lb_total_bits,
    input wire logic clk
);

endmodule
