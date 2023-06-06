module global_static_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer B_LEN = 2,
    parameter integer S_LEN = 2,
    parameter integer H_DEPTH = 6,
    parameter integer est_chan_depth = 30,
    parameter integer est_channel_width = 8,
    parameter integer N_S = 7,
    parameter integer SH_DEPTH = 18
) (
    input logic clk,
    input logic rst_n,
    input logic run,

    input logic [2*B_WIDTH-1:0] state_energies [N_S-1:0],
    input logic signed [1:0] state_histories [N_S-1:0][B_LEN-1:0],
    input logic signed [est_channel_width-1:0] est_channel [est_chan_depth-1:0],

    input logic signed [B_WIDTH-1:0] rse_vals [B_LEN-1:0],

    output logic signed [1:0] final_symbols [B_LEN-1:0],

    output logic signed [B_WIDTH-1:0] precomputed_static_val [B_LEN-1:0],
    output logic [2*B_WIDTH-1:0] global_static_energy
);
    logic signed [1:0] global_static_history [SH_DEPTH-1:0];
    logic signed [1:0] next_global_static_history [SH_DEPTH-1:0];

    logic signed [B_WIDTH-1:0] static_val [B_LEN-1:0];

    logic signed [1:0] best_state_history [B_LEN-1:0];
    logic [2*B_WIDTH-1:0] best_state_energy;
    import test_pack::*;

    assign final_symbols = global_static_history[B_LEN-1:0];    
    
    conv_unit #(
        .i_width(2),
        .i_depth(SH_DEPTH),
        .f_width(est_channel_width),
        .f_depth(est_chan_depth),
        .o_width(B_WIDTH),
        .o_depth(B_LEN),
        .offset(B_LEN + H_DEPTH + S_LEN),
        .shift(1)
    ) conv_i (
        .in(global_static_history),
        // (B_LEN + S_LEN) represents the shifting implicit in this convolution when you consider the entire history
        // The (B_LEN-1) represents the effect of sliding the filter along multiple values (for unrolling the branches)
        .filter(est_channel),
        .out(static_val)
    );


    always_comb begin
        for(int ii = 0; ii < B_LEN; ii += 1) begin
            precomputed_static_val[ii] = static_val[ii] + rse_vals[ii];
        end
    end


    static_select_unit #(
        .N_S(N_S),
        .H_DEPTH(B_LEN),
        .B_WIDTH(B_WIDTH),
        .S_LEN(S_LEN)
    ) ssu_i (
        .state_energies(state_energies),
        .state_histories(state_histories),

        .best_state_energy(best_state_energy),
        .best_state_history(best_state_history)
    );

    always_comb begin
        for(int ii = SH_DEPTH-1; ii >= B_LEN ; ii -= 1) begin
            next_global_static_history[ii] = global_static_history[ii-1];
        end
        for(int ii = B_LEN-1; ii >= 0; ii -= 1) begin
            next_global_static_history[ii] = best_state_history[ii];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for(int ii = 0; ii < SH_DEPTH; ii += 1) begin
                global_static_history[ii] <= 0;
            end
            global_static_energy  <= 0;
        end else begin
            if(run) begin
                for(int ii = 0; ii < SH_DEPTH; ii += 1) begin
                    global_static_history[ii] <= next_global_static_history[ii];
                end
                global_static_energy  <=  best_state_energy;
                $display("%m");
                $write("\tprecomputed_static_val: ");
                test_pack::array_io#(logic signed [B_WIDTH-1:0], B_LEN)::write_array(precomputed_static_val);
                $write("\trse_vals: ");
                test_pack::array_io#(logic signed [B_WIDTH-1:0], B_LEN)::write_array(rse_vals);
                $write("\tstate_val: ");
                test_pack::array_io#(logic signed [B_WIDTH-1:0], B_LEN)::write_array(static_val);
                $write("\tglobal_static_history: ");
                test_pack::array_io#(logic signed [1:0], SH_DEPTH)::write_array(global_static_history);
            end
        end
    end


endmodule 