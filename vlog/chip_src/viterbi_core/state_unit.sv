module state_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer P_WIDTH = 8,
    parameter integer B_LEN = 4,
    parameter integer N_B   = 4,
    parameter integer S_LEN = 2,
    parameter logic [S_LEN-1:0] STATE_TAG = {S_LEN{1'b1}}
) (
    input logic clk,
    input logic rst_n,

    input logic signed [est_channel_width-1:0] est_channel [est_chan_depth-1:0],

    input logic [B_WIDTH-1:0] new_precomputed_state_val [N_B-1:0],
    input logic store,

    input logic [2*B_WIDTH-1:0] path_energies [N_B-1:0],
    input logic [S_LEN-1:0] path_tags [N_B-1:0],
    input logic [1:0] path_histories [N_B-1:0][H_DEPTH-1:0],

    input logic [B_WIDTH-1:0] precomputed_static_val [N_B-1:0],
    input logic [2*B_WIDTH-1:0] static_energy [N_B-1:0],

    output logic [2*B_WIDTH-1:0] new_static_energy,
    output logic [1:0] new_static_history [SH_DEPTH-1:0]

    output logic [2*B_WIDTH-1:0] state_energy,
    output logic [B_WIDTH-1:0] state_val [N_B-1:0],
    output logic [1:0] state_history [H_DEPTH-1:0]
);

    logic [2*B_WIDTH-1:0] state_energy_reg;
    logic [1:0] state_history_reg [H_DEPTH-1:0];
    logic [B_WIDTH-1:0] total_precomputed_val_reg [N_B-1:0];
    logic [B_WIDTH-1:0] precomputed_state_val_reg [N_B-1:0];

    logic [2*B_WIDTH-1:0] best_path_energy;
    logic [1:0] best_path_history [H_DEPTH-1:0];
    logic [S_LEN-1:0] best_path_tag;

    assign new_static_energy = state_energy_reg;
    assign new_static_history = state_history_reg[DH_DEPTH+SH_DEPTH-1:DH_DEPTH];


    select_unit #() su_i (
        .path_energies(path_energies),
        .path_tags(path_tags),
        .path_histories(path_histories),

        .selected_path_energy(best_path_energy),
        .selected_path_tag(best_path_tag),
        .selected_path_history(best_path_history)
    );

    conv #() conv_i (
        .in(state_history_reg),
        .filter(est_channel),
        .out(base_path_val)
    );

    assign state_energy = state_energy_reg - static_energy;
    assign state_val = total_precomputed_val_reg + base_path_val;
    assign state_history = state_history_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (int ii = 0; ii < N_B; ii++) begin
                precomputed_state_val_reg[ii] <= 0;
                total_precomputed_val_reg[ii] <= 0;
            end
            state_energy_reg <= 0;
            //state_history_reg <= 0;
        end
        else begin
            for (int ii = 0; ii < N_B; ii++) begin
                if(store) begin
                    precomputed_state_val_reg[ii]  <= new_precomputed_state_val[ii];
                end
                total_precomputed_val_reg[ii] <= precomputed_static_val[ii] + precomputed_state_val_reg[ii];
            end
            state_energy_reg <= best_path_energy;
            //state_history_reg <= best_path_history;
        end
    end



endmodule 