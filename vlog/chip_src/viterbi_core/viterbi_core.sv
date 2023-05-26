module viterbi_core #(
    parameter integer B_WIDTH=8,
    parameter integer B_LEN = 2,
    parameter integer S_LEN = 2,
    parameter integer SH_DEPTH=18,
    parameter integer est_channel_width=8,
    parameter integer est_chan_depth=30,
    parameter integer H_DEPTH=6
)(
    input logic clk,
    input logic rst_n,

    input logic signed [est_channel_width-1:0] est_channel [est_chan_depth-1:0],
    input logic update,

    input logic signed [B_WIDTH-1:0] rse_vals [B_LEN-1:0],

    output logic signed [1:0] final_symbols [B_LEN-1:0]


);

    import viterbi_22_pkg::*;

    logic signed [B_WIDTH-1:0] branch_vals_reg [max_number_of_branch_connections-1:0][B_LEN-1:0];
    logic signed [B_WIDTH-1:0] state_vals_reg [number_of_state_units-1:0][B_LEN-1:0];

    logic signed [1:0] state_history_interconnect [number_of_state_units-1:0][H_DEPTH + B_LEN - 1:0];
    logic signed [1:0] old_state_histories [number_of_state_units-1:0][1:0];
    logic [2*B_WIDTH-1:0] state_energies [number_of_state_units-1:0];

    logic signed [B_WIDTH-1:0] precomputed_static_val [B_LEN-1:0];

    logic [2*B_WIDTH-1:0] global_static_energy;

    logic signed [B_WIDTH-1:0] state_val_interconnect [number_of_state_units-1:0][B_LEN-1:0];
    logic signed [2*B_WIDTH-1:0] state_energy_interconnect [number_of_state_units-1:0];

    logic [2*B_WIDTH-1:0] branch_energy_out_interconnect [number_of_branch_units-1:0];
    logic signed [1:0] branch_history_out_interconnect [number_of_branch_units-1:0][H_DEPTH +S_LEN + B_LEN -1:0];

    global_static_unit #(
        .B_WIDTH(B_WIDTH),
        .B_LEN(B_LEN),
        .S_LEN(S_LEN),
        .H_DEPTH(H_DEPTH),
        .est_chan_depth(est_chan_depth),
        .est_channel_width(est_channel_width),
        .N_S(7),
        .SH_DEPTH(SH_DEPTH)
    ) gsu_i (
        .clk(clk),
        .rst_n(rst_n),

        .est_channel(est_channel),

        .rse_vals(rse_vals),

        .state_energies(state_energies),
        .state_histories(old_state_histories),

        .final_symbols(final_symbols),

        .precomputed_static_val(precomputed_static_val),
        .global_static_energy(global_static_energy)
    );

    genvar gi, gj, gk;
    generate
        for (gi = 0; gi < number_of_state_units; gi += 1) begin : state_unit
            state_register_unit #(
                .B_WIDTH(8),
                .B_LEN(2),
                .S_LEN(2),
                .est_channel_width(est_channel_width),
                .est_channel_depth(est_chan_depth),
                .est_channel_shift(1),
                .TAG(s_map[gi])
            ) sru_i (
                .clk(clk),
                .rst_n(rst_n),

                .est_channel(est_channel),
                .update(update),

                .precomputed_state_val(state_vals_reg[gi])
            );
            initial begin
                $display("s_map[%0d] = %p", gi, s_map[gi]);
            end

            logic signed [1:0] branch_history_in_interconnect [number_of_branch_connections[gi]-1:0][H_DEPTH +S_LEN + B_LEN -1:0];
            logic [2*B_WIDTH-1:0] branch_energy_in_interconnect [number_of_branch_connections[gi]-1:0];
            for(gj = 0; gj < number_of_branch_connections[gi]; gj += 1) begin
                assign branch_history_in_interconnect[gj] = branch_history_out_interconnect[bs_map[gi][gj]];
                assign branch_energy_in_interconnect[gj] = branch_energy_out_interconnect[bs_map[gi][gj]];
            end

            state_unit #(
                .B_WIDTH(8),
                .H_DEPTH(H_DEPTH),
                .B_LEN(2),
                .N_B(number_of_branch_connections[gi]),
                .S_LEN(2),
                .STATE_TAG(s_map[gi])
            ) su_i (
                .clk(clk),
                .rst_n(rst_n),
                
                .est_channel(est_channel),

                .precomputed_state_val(state_vals_reg[gi]),
    
                .path_energies(branch_energy_in_interconnect),
                .path_histories(branch_history_in_interconnect),
                
                .precomputed_static_val(precomputed_static_val),
                .static_energy(global_static_energy),

                .new_static_energy(state_energies[gi]),
                .new_static_history(old_state_histories[gi]),

                .state_energy(state_energy_interconnect[gi]),
                .state_val(state_val_interconnect[gi]),
                .state_history(state_history_interconnect[gi])
            );
        end

        for(gi = 0; gi < max_number_of_branch_connections; gi += 1) begin : branch_register_unit       
            branch_register_unit #(
                .B_WIDTH(8),
                .B_LEN(2),
                .est_channel_width(est_channel_width),
                .est_channel_depth(est_chan_depth),
                .est_channel_shift(1),
                .TAG(bt_map[gi])
            ) bru_i (
                .clk(clk),
                .rst_n(rst_n),

                .est_channel(est_channel),
                .update(update),

                .precomputed_branch_val(branch_vals_reg[gi])
            );
        end

        for (gi =0; gi < number_of_branch_units; gi += 1) begin : branch_unit
            branch_unit #(
                .B_WIDTH(8),
                .P_WIDTH(8),
                .H_DEPTH(6),
                .B_LEN(2),
                .S_LEN(2),
                .TAG(bt_map[b_map[gi]])
            ) bu_i (
                .branch_val(branch_vals_reg[b_map[gi]]),
                
                .precomp_val(state_val_interconnect[sb_map[gi]]),
                .state_energy(state_energy_interconnect[sb_map[gi]]),
                .state_history(state_history_interconnect[sb_map[gi]]),

                .path_energy(branch_energy_out_interconnect[gi]),
                .path_history(branch_history_out_interconnect[gi])
            );
        end
    endgenerate

    

endmodule