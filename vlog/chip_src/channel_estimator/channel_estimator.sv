`default_nettype none
module channel_estimator #(
    // synthesis translate_off
    parameter string  file_name = "chan_internal_state.txt",
    // synthesis translate_on
    parameter integer est_depth = 30,
    parameter integer est_bitwidth = 8,
    parameter integer adapt_bitwidth = 16,
    parameter integer err_bitwidth = 9
) (
    input wire logic clk,
    input wire logic rst_n,

    input wire logic signed [err_bitwidth-1:0] error [31:0],
    input wire logic current_bit,

    input wire logic [$clog2(adapt_bitwidth)-1:0] gain,
    input wire logic hold,

    output logic signed [est_bitwidth-1:0] est_chan [est_depth-1:0]
);

    logic signed [est_bitwidth + adapt_bitwidth-1:0] tap_decimal, next_tap_decimal;
    logic signed [est_bitwidth + adapt_bitwidth-1:0] int_chan_est [est_depth-1:0];
    logic [$clog2(est_depth)-1:0] tap_pos, tap_pos_plus_one, next_tap_pos;
    logic store_tap_decimal;
    wire logic signed [err_bitwidth-1:0] curr_err;
    assign curr_err = error[tap_pos];
    assign tap_pos_plus_one = tap_pos + 1;

    typedef enum logic [2:0] {RST, INCREMENT, LOAD, CALC, STORE, HALT} chan_est_states_t;
    chan_est_states_t chan_est_states, next_chan_est_states;

    always_comb begin
        for(int ii = 0; ii < est_depth; ii = ii + 1) begin
            est_chan[ii] = (int_chan_est[ii] >> adapt_bitwidth);
        end
    end
 
     // synthesis translate_off
    integer fid;
    initial begin
        fid = $fopen(file_name, "w");
    end
    // synthesis translate_on

    always_ff @(posedge clk or negedge rst_n) begin 
        if(~rst_n) begin
            tap_pos <= 0;
            tap_decimal <= 0;
            chan_est_states <= RST;
            for(int ii = 0; ii < est_depth; ii = ii + 1) begin
                int_chan_est[ii] <= 0;
            end
        end else begin
            tap_pos <= next_tap_pos;
            tap_decimal <= next_tap_decimal;
            chan_est_states <= next_chan_est_states;
            if(store_tap_decimal) begin
                int_chan_est[next_tap_pos] <= next_tap_decimal;
                // synthesis translate_off
                $fwrite(fid, "%d, %d\n", tap_pos, next_tap_decimal);
                // synthesis translate_on
            end
        end
    end

    always_comb begin
        unique case (chan_est_states)
            RST : begin
                next_chan_est_states = hold ? HALT : LOAD;
                next_tap_pos = 0;
                next_tap_decimal = tap_decimal;
            end
            INCREMENT: begin
                next_chan_est_states = hold ? HALT : LOAD;
                next_tap_pos = (tap_pos_plus_one > est_depth - 1) ? 0 : tap_pos_plus_one;
                next_tap_decimal = tap_decimal;
            end
            LOAD : begin
                next_chan_est_states = CALC;
                next_tap_pos = tap_pos;
                next_tap_decimal = (current_bit) ? int_chan_est[tap_pos] - (curr_err <<< gain) :  int_chan_est[tap_pos] + (curr_err <<< gain) ;
            end
            CALC : begin
                next_chan_est_states = STORE;
                next_tap_pos = tap_pos;
                next_tap_decimal = (current_bit) ? tap_decimal - (curr_err <<< gain) : tap_decimal + (curr_err <<< gain);
            end
            STORE: begin
                next_chan_est_states =  INCREMENT;
                next_tap_decimal     =  tap_decimal;
                next_tap_pos = tap_pos;
            end
            HALT : begin
                next_chan_est_states =  hold ? HALT : INCREMENT;
                next_tap_decimal     =  tap_decimal;
                next_tap_pos = tap_pos;
            end
            default : begin
                next_chan_est_states = RST;
                next_tap_pos = 0;
                next_tap_decimal = 0;
            end
        endcase
    end

    always_comb begin
        unique case (chan_est_states)
            RST : begin
                store_tap_decimal = 0;
            end
            INCREMENT: begin
                store_tap_decimal = 0;
            end
            LOAD : begin
                store_tap_decimal = 0;
            end
            CALC : begin
                store_tap_decimal = 0;
            end
            STORE : begin
                store_tap_decimal = 1;
            end
            HALT : begin
                store_tap_decimal = 0;
            end
            default : begin 
                store_tap_decimal = 0; 
            end
        endcase
    end

endmodule : channel_estimator
`default_nettype wire