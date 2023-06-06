module select_eight #(
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8
) (
    input logic [2*B_WIDTH-1:0] energies [7:0],
    input logic signed [1:0]    histories [7:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] selected_energy,
    output logic signed [1:0] selected_history [H_DEPTH-1:0]
);

    logic [2*B_WIDTH-1:0] selected_energy_stage0 [3:0];
    logic signed [1:0] selected_history_stage0 [3:0][H_DEPTH-1:0];

    genvar gi;

    generate 
        for(gi = 0; gi < 4; gi += 1) begin : select_two_stage0
            select_two #(H_DEPTH, B_WIDTH) st_i (
                .energies(energies[2*gi+1:2*gi]),
                .histories(histories[2*gi+1:2*gi]),
                .selected_energy(selected_energy_stage0[gi]),
                .selected_history(selected_history_stage0[gi])
            );
        end
    endgenerate

    select_four #(
        .H_DEPTH(H_DEPTH),
        .B_WIDTH(B_WIDTH)
    ) sf_i (
        .energies(selected_energy_stage0),
        .histories(selected_history_stage0),
        .selected_energy(selected_energy),
        .selected_history(selected_history)
    );


endmodule