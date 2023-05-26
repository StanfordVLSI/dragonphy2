module state_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer H_DEPTH = 6,
    parameter integer B_LEN = 4,
    parameter integer N_B   = 4,
    parameter integer S_LEN = 2,
    parameter integer est_channel_width = 8,
    parameter integer est_channel_depth = 30,
    parameter integer STATE_TAG [S_LEN-1:0] = {S_LEN{1'b1}}
) (
    input logic clk,
    input logic rst_n,

    input logic signed [est_channel_width-1:0] est_channel [est_channel_depth-1:0],

    input logic signed [B_WIDTH-1:0] precomputed_state_val [B_LEN-1:0],

    input logic [2*B_WIDTH-1:0] path_energies [N_B-1:0],
    input logic signed [1:0] path_histories [N_B-1:0][H_DEPTH + S_LEN + B_LEN-1:0],

    input logic signed [B_WIDTH-1:0] precomputed_static_val [B_LEN-1:0],
    input logic [2*B_WIDTH-1:0] static_energy,

    output logic [2*B_WIDTH-1:0] new_static_energy,
    output logic signed [1:0] new_static_history [B_LEN-1:0],

    output logic [2*B_WIDTH-1:0] state_energy,
    output logic signed [B_WIDTH-1:0] state_val [B_LEN-1:0],
    output logic signed [1:0] state_history [H_DEPTH+S_LEN-1:0]
);

    logic [2*B_WIDTH-1:0] state_energy_reg;
    logic signed [1:0] state_history_reg [H_DEPTH-1:0];

    logic signed [B_WIDTH-1:0] base_path_val [B_LEN-1:0];

    logic [B_WIDTH-1:0] total_precomputed_val_reg [B_LEN-1:0];

    logic [2*B_WIDTH-1:0] best_path_energy;
    logic signed [1:0] best_path_history [H_DEPTH + S_LEN + B_LEN-1:0];

    assign new_static_energy = state_energy_reg;
    //Each branch adds two symbols to the history and pushes off two symbols from the dynamic history
    assign new_static_history = state_history_reg[H_DEPTH-1:H_DEPTH-B_LEN];


    select_unit #(
        .N_B(N_B),
        .H_DEPTH(H_DEPTH + S_LEN + B_LEN),
        .B_WIDTH(B_WIDTH),
        .S_LEN(S_LEN)
    ) su_i (
        .path_energies(path_energies),
        .path_histories(path_histories),

        .selected_path_energy(best_path_energy),
        .selected_path_history(best_path_history)
    );

    conv_unit #(
        .i_width(2),
        .i_depth(H_DEPTH),
        .f_width(est_channel_width),
        .f_depth(H_DEPTH + B_LEN - 1),
        .o_width(B_WIDTH),
        .o_depth(B_LEN),
        .shift(1)
    ) conv_i (
        .in(state_history_reg),
        // (B_LEN + S_LEN) represents the shifting implicit in this convolution when you consider the entire history
        // The (B_LEN-1) represents the effect of sliding the filter along multiple values (for unrolling the branches)
        .filter(est_channel[H_DEPTH + (B_LEN -1) + (B_LEN + S_LEN)- 1: (B_LEN + S_LEN)]),
        .out(base_path_val)
    );

    assign state_energy = state_energy_reg - static_energy; //Remove 'dead' energy from the system

    genvar gi;

    generate
        for(gi = 0; gi < B_LEN; gi += 1) begin 
            assign state_val[gi] = total_precomputed_val_reg[gi] + base_path_val[gi];
        end
    endgenerate

    // Combine the current state history and the state's symbolic values. These feed into the branches, which will attach the branch tag.
    assign state_history[S_LEN-1:0] = STATE_TAG;
    assign state_history[H_DEPTH+S_LEN-1:S_LEN] = state_history_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (int ii = 0; ii < B_LEN; ii++) begin
                total_precomputed_val_reg[ii] <= 0;
            end
            state_energy_reg <= 0;
            for(int ii = 0; ii < H_DEPTH; ii++ ) begin 
                state_history_reg[ii] <= 0; //Trim the state symbols from the history (implicit)
            end        
        end else begin
            for (int ii = 0; ii < B_LEN; ii++) begin
                total_precomputed_val_reg[ii] <= precomputed_static_val[ii] + precomputed_state_val[ii];
            end
            state_energy_reg <= best_path_energy;
            for(int ii = 0; ii < H_DEPTH; ii++ ) begin 
                state_history_reg[ii] <= best_path_history[S_LEN+ii]; //Trim the state symbols from the history (implicit)
            end
        end
    end



endmodule 