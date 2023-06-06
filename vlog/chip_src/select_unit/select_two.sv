module select_two #(
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8
) (
    input logic [2*B_WIDTH-1:0] energies [1:0],
    input logic signed [1:0]    histories [1:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] selected_energy,
    output logic signed [1:0] selected_history [H_DEPTH-1:0]
);

    assign selected_energy = (energies[0] < energies[1]) ? energies[0] : energies[1];
    assign selected_history = (energies[0] < energies[1]) ? histories[0] : histories[1];

endmodule