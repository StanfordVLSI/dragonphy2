module trellis_neighbor_checker #(
    parameter integer est_channel_bitwidth = 10,
    parameter integer depth = 30,
    parameter integer width = 16,
    parameter integer branch_bitwidth  = 2,
    parameter integer trellis_neighbor_checker_depth = 2,
    parameter integer num_of_trellis_patterns = 3,
    parameter integer trellis_pattern_depth = 4,
    parameter integer seq_length = 3,
    parameter integer ener_bitwidth = 18,
    parameter integer est_err_bitwidth=9
) (
    input logic  signed [est_channel_bitwidth-1:0]  channel   [depth-1:0],
    input logic signed [branch_bitwidth-1:0]        trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
    input logic nrz_mode,
    input logic signed [est_err_bitwidth-1:0]     errstream [width*trellis_neighbor_checker_depth-1:0],

    output logic [$clog2(2*num_of_trellis_patterns+1)-1:0] flags [width-1:0]

);
    logic signed [est_channel_bitwidth-1:0]  channel_slice [seq_length+trellis_pattern_depth-1-1:0];
    logic signed [est_err_bitwidth-1:0] errstream_slice [width-1:0][seq_length-1:0];
    logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0];
    logic [ener_bitwidth-1:0] null_energies [width-1:0];

    assign channel_slice = channel[seq_length+trellis_pattern_depth-1-1:0];

    error_injection_engine #(
        .seq_length(seq_length),
        .est_err_bitwidth(est_err_bitwidth),
        .trellis_pattern_depth(trellis_pattern_depth),
        .branch_bitwidth(branch_bitwidth),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .cp(2),
        .est_channel_bitwidth(est_channel_bitwidth)
    ) eie_i (
        .channel(channel_slice),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(0),
        .injection_error_seqs(injection_error_seqs)
    );

    genvar gi, gj;
    generate

        for(gi = 0; gi < width; gi += 1) begin
            for(gj = 0; gj < seq_length; gj += 1) begin
                assign errstream_slice[gi][gj] = errstream[width-seq_length+gi+gj];
            end

            always_comb begin
                null_energies[gi] = 0;
                for(int ii =0; ii < seq_length; ii += 1) begin
                        null_energies[gi] += (errstream_slice[gi][ii]**2) >> 4;
                end
            end

            trellis_neighbor_checker_slice #(
                .num_of_trellis_patterns(num_of_trellis_patterns),
                .seq_length(seq_length),
                .est_err_bitwidth(est_err_bitwidth),
                .ener_bitwidth(ener_bitwidth)
            ) tnc_slice_i (
                .injection_error_seqs(injection_error_seqs),
                .est_error(errstream_slice[gi]),
                .null_energy(null_energies[gi]),
                .best_ener_idx(flags[gi])
            );
        end
    endgenerate

endmodule 