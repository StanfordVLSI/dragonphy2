`default_nettype none
module inserter #(
    parameter integer num_of_channels = 40,
    parameter integer num_of_viterbi_fifos = 4,
    parameter integer num_of_chunks = 5,
    parameter integer rse_width=8,
    parameter integer flag_width=8,
    parameter integer sym_width=3
)(
    input wire logic clk,
    input wire logic rstn,

    input wire logic en_fifo,

    input logic signed [rse_width-1:0] rse_vals [num_of_channels-1:0],
    input logic signed [flag_width-1:0] flags [num_of_channels-1:0],
    input logic signed [sym_width-1:0] symbols [num_of_channels-1:0],

    output logic signed [sym_width-1:0] symbols_main [num_of_channels-1:0],
    output logic [num_of_viterbi_fifos-1:0] tag,
    output logic push_n_main,

    //Global Write Values
    output logic flags_v [num_of_channels-1:0],
    output logic [num_of_chunks-1:0] cflags_v,
    output logic signed [rse_width-1:0] rse_v [num_of_channels-1:0],

    //Viterbi Selection Logic and Meta-Data
    output logic [$clog2(num_of_chunks)-1:0] start_loc [num_of_viterbi_fifos-1:0],
    output logic [num_of_viterbi_fifos-1:0] push_n_v,
    output logic [num_of_viterbi_fifos-1:0] clr_v,
    output logic [num_of_viterbi_fifos-1:0] init_n_v

);

    genvar gi;
    generate
        for(gi = 0; gi <num_of_channels; gi += 1) begin
            assign symbols_main[gi] = symbols[gi];
            assign rse_v[gi] = rse_vals[gi];
        end
    endgenerate

    assign tag = ~push_n_v;
    assign push_n_main = ~en_fifo;
    logic [num_of_chunks-1:0] coarse_flags;

    coarse_flag_blocker #(
        .num_of_chunks(num_of_chunks),
        .flag_width(flag_width),
        .num_of_channels(num_of_channels)
    ) cfb_i (
        .flags(flags),
        .coarse_flags(coarse_flags),
        .unpacked_bit_flags(flags_v)
    );

    logic is_there_edge;
    logic [$clog2(num_of_chunks)-1:0] loc_1, loc_2;
    logic [$clog2(num_of_chunks)-1:0] num_of_writes;

    start_frame_decoder #(
        .num_of_chunks(num_of_chunks)
    ) sfd_i (
        .clk(clk),
        .rst_n(rstn),
        .en_fifo(en_fifo),
        .coarse_flags(coarse_flags),
        
        .is_there_edge(is_there_edge),
        .loc_1(loc_1),
        .loc_2(loc_2),
        .num_of_writes(num_of_writes)
    );

    assign cflags_v = coarse_flags;

    fifo_controller #(
        .num_of_chunks(num_of_chunks),
        .num_of_viterbi_fifos(num_of_viterbi_fifos)
    ) fc_i (
        .clk(clk),
        .rst_n(rstn),
        
        .en_fifo(en_fifo),

        .is_there_edge(is_there_edge),
        .loc_1(loc_1),
        .loc_2(loc_2),
        .num_of_writes(num_of_writes),

        .push_n(push_n_v),
        .clr(clr_v),
        .init_n(init_n_v),
        .start_loc(start_loc)
    );

endmodule // inserter
`default_nettype wire