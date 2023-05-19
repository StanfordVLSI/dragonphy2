module viterbi_core #(

)(


);

    import viterbi_226_pkg::*;

    logic [B_WIDTH-1:0] branch_vals_reg [N_B-1:0][B_LEN-1:0];

    logic [1:0] state_history_interconnect [number_of_state_units-1:0][H_DEPTH-1:0];
    logic [1:0] old_state_histories [number_of_state_units-1:0][H_DEPTH-1:0];
    logic [2*B_WIDTH-1:0] state_energies [number_of_state_units-1:0];

    logic signed [B_WIDTH-1:0] precomputed_static_val [B_LEN-1:0];
    logic [2*B_WIDTH-1:0] global_static_energy;

    logic signed [B_WIDTH-1:0] state_val_interconnect [number_of_state_units-1:0][B_LEN-1:0];
    logic signed [B_WIDTH-1:0] state_energy_interconnect [number_of_state_units-1:0];

    logic [2*B_WIDTH-1:0] branch_energy_interconnect [number_of_branch_units-1:0];

    global_static_unit #(

    ) gsu_i (
        .clk(clk),
        .rst_n(rst_n),

        .state_energies(state_energies),
        .state_histories(old_state_histories),

        .est_channel(),

        .rse_vals(),

        .precomputed_static_val(precomputed_static_val)
        .global_static_energy(global_static_energy)
    );

    genvar gi, gj, gk;
    generate 
        for (gi = 0; gi < number_of_state_units; gi += 1) begin
            state_unit #(
                
            ) su_i (
                .clk(clk),
                .rst_n(rst_n),
                
                .est_channel(est_channel),

                .new_precomputed_state_val(),
                .store(),

                .path_energies(branch_history_interconnect[bs_map[gi]]),
                .path_histories(branch_history_interconnect[bs_map[gi]]),
                
                .precomputed_static_val(precomputed_static_val),
                .static_energy(global_static_energy),

                .new_static_energy(state_energies[gi]),
                .new_static_history(old_state_histories[gi]),

                .state_energy(state_energy_interconnect[gi]),
                .state_val(state_val_interconnect[gi]),
                .state_history(state_history_interconnect[gi])
            );
        end

        for (gi =0; gi < number_of_branch_units; gi += 1) begin
            branch_unit #(
            
            ) bu_i (
                .branch_val(branch_vals_reg[b_map[gi]]),
                
                .precomp_val(state_val_interconnect[sb_map[gi]]),
                .state_energy(state_energy_interconnect[sb_map[gi]]),
                .state_history(state_history_interconnect[sb_map[gi]]),

                .path_energy(branch_energy_interconnect[gi]),
                .path_history(branch_history_interconnect[gi])
            );
        end
    endgenerate

    

endmodule