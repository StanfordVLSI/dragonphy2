module select_unit #(
    parameter integer N_B = 8,
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8,
    parameter integer S_LEN = 2,
) (
    input logic [2*B_WIDTH-1:0] path_energies [N_B-1:0],
    input logic [S_LEN-1:0] path_tags [N_B-1:0],
    input logic [1:0] path_histories [N_B-1:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] selected_path_energy,
    output logic [S_LEN-1:0] selected_path_tag,
    output logic [1:0] selected_path_history [H_DEPTH-1:0]
);

    always_comb begin
        selected_path_energy = path_energies[0];
        selected_path_history = path_histories[0];
        selected_path_tag = path_tags[0];
        for (int ii = 1; ii < N_B; ii += 1) begin
            if (path_energies[ii] < selected_path_energy) begin
                selected_path_energy = path_energies[ii];
                selected_path_history = path_histories[ii];
                selected_path_tag = path_tags[ii];
            end
        end    
    end
endmodule