module static_select_unit #(
    parameter integer N_S = 4,
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8,
    parameter integer S_LEN = 2
) (
    input logic [2*B_WIDTH-1:0] state_energies [N_S-1:0],
    input logic signed [1:0] state_histories [N_S-1:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] best_state_energy,
    output logic signed [1:0] best_state_history [H_DEPTH-1:0]
);

    always_comb begin
        best_state_energy = state_energies[0];
        best_state_history = state_histories[0];
        for (int ii = 1; ii < N_S; ii += 1) begin
            if (state_energies[ii] < best_state_energy) begin
                best_state_energy = state_energies[ii];
                best_state_history = state_histories[ii];
            end
        end    
    end
endmodule