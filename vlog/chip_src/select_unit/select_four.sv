module select_four #(
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8
) (
    input logic [2*B_WIDTH-1:0] energies [3:0],
    input logic signed [1:0]    histories [3:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] selected_energy,
    output logic signed [1:0] selected_history [H_DEPTH-1:0]
);

    logic [2*B_WIDTH-1:0] selected_energy_stage0 [1:0];
    logic signed [1:0] selected_history_stage0 [1:0][H_DEPTH-1:0];

    select_two #(H_DEPTH, B_WIDTH) st1_i (
        .energies(energies[1:0]),
        .histories(histories[1:0]),
        .selected_energy(selected_energy_stage0[0]),
        .selected_history(selected_history_stage0[0])
    );

    select_two #(H_DEPTH, B_WIDTH) st2_i (
        .energies(energies[3:2]),
        .histories(histories[3:2]),
        .selected_energy(selected_energy_stage0[1]),
        .selected_history(selected_history_stage0[1])
    );

    select_two #(H_DEPTH, B_WIDTH) st3_i (
        .energies(selected_energy_stage0),
        .histories(selected_history_stage0),
        .selected_energy(selected_energy),
        .selected_history(selected_history)
    );

endmodule