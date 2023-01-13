module trellis_neighbor_checker_slice #(
    parameter integer num_of_trellis_patterns = 4,
    parameter integer seq_length = 3,
    parameter integer est_err_bitwidth = 9,
    parameter integer ener_bitwidth = 18

) (
    input logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0], 
    input logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0],
    input logic signed [ener_bitwidth-1:0] null_energy,

    output logic [$clog2(num_of_trellis_patterns)+2-1:0] best_ener_idx
);

    logic [ener_bitwidth-1:0] energies [2*num_of_trellis_patterns:0];


    assign energies[0] = null_energy;

    genvar gi;
    generate
        for(gi = 1; gi < 2*num_of_trellis_patterns+1; gi += 1) begin
            energy_metric #(
                .est_err_bitwidth(est_err_bitwidth),
                .ener_bitwidth(ener_bitwidth)
            ) ener_metric_i (
                .injection_error_seq(injection_error_seqs[gi]),
                .est_error(est_error),

                .energy(energies[gi])
            );
        end
    endgenerate

    argmin #(
        .num_of_energies(2*num_of_trellis_patterns+1),
        .ener_bitwidth(ener_bitwidth)
    ) argmin_i (
        .energies(energies),

        .lowest_energy_idx(best_ener_idx),
        .lowest_energy()
    );

endmodule 