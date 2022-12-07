`default_nettype none

module ffe_estimator #(
    // synthesis translate_off
    parameter string  file_name = "ffe_internal_state.txt",
    // synthesis translate_on
    parameter integer est_depth = 10,
    parameter integer ffe_bitwidth = 10,
    parameter integer adapt_bitwidth = 14,
    parameter integer code_bitwidth = 8,
    parameter integer est_bit_bitwidth = 10
) (
    input wire logic clk,
    input wire logic rst_n,

    input wire logic signed [est_bit_bitwidth-1:0] est_bits  [est_depth-1:0],

    input wire logic signed [code_bitwidth-1:0] current_code,

    input wire logic [$clog2(adapt_bitwidth)-1:0] gain,
    input wire logic signed [est_bit_bitwidth-1:0] bit_level,

    input wire logic exec_inst,
    input wire logic [2:0] inst,

    input wire logic signed [ffe_bitwidth-1:0] ffe_init [est_depth-1:0],
    output logic signed [ffe_bitwidth-1:0] ffe_est [est_depth-1:0]
);

    logic signed [9:0] estimated_bit_0;
    logic signed [9:0] estimated_bit_1;
    logic signed [9:0] estimated_bit_2;
    logic signed [9:0] estimated_bit_3;
    logic signed [9:0] estimated_bit_4;
    logic signed [9:0] estimated_bit_5;
    logic signed [9:0] estimated_bit_6;
    logic signed [9:0] estimated_bit_7;
    logic signed [9:0] estimated_bit_8;
    logic signed [9:0] estimated_bit_9;
    logic signed [9:0] estimated_bit_10;
    logic signed [9:0] estimated_bit_11;
    logic signed [9:0] estimated_bit_12;
    logic signed [9:0] estimated_bit_13;
    logic signed [9:0] estimated_bit_14;
    logic signed [9:0] estimated_bit_15;
    assign estimated_bit_0 = est_bits[0];
    assign estimated_bit_1 = est_bits[1];
    assign estimated_bit_2 = est_bits[2];
    assign estimated_bit_3 = est_bits[3];
    assign estimated_bit_4 = est_bits[4];
    assign estimated_bit_5 = est_bits[5];
    assign estimated_bit_6 = est_bits[6];
    assign estimated_bit_7 = est_bits[7];
    assign estimated_bit_8 = est_bits[8];
    assign estimated_bit_9 = est_bits[9];
    assign estimated_bit_10 = est_bits[10];
    assign estimated_bit_11 = est_bits[11];
    assign estimated_bit_12 = est_bits[12];
    assign estimated_bit_13 = est_bits[13];
    assign estimated_bit_14 = est_bits[14];
    assign estimated_bit_15 = est_bits[15];


    logic signed [ffe_bitwidth + adapt_bitwidth-1:0] tap_decimal, next_tap_decimal;
    logic signed [ffe_bitwidth + adapt_bitwidth-1:0] int_ffe_est [est_depth-1:0];
    logic [$clog2(est_depth)-1:0] tap_pos, tap_pos_plus_one, next_tap_pos;
    logic store_tap_decimal;
    wire logic signed [est_bit_bitwidth-1:0] sliced_bit_val;
    wire logic signed [est_bit_bitwidth-1:0] est_bit_val;
    wire logic signed [ffe_bitwidth + adapt_bitwidth-1:0] err;
    wire logic signed [ffe_bitwidth + adapt_bitwidth-1:0] adjust_val;

    logic load_init, shift_left, shift_right;

    assign sliced_bit_val = (est_bits[tap_pos] > 0 ? bit_level : -bit_level);
    assign est_bit_val    = est_bits[tap_pos];
    assign err = sliced_bit_val - est_bit_val;
    assign adjust_val = ((current_code * err) <<< gain);

    assign tap_pos_plus_one = tap_pos + 1;
    typedef enum logic [2:0] {RST, LOAD_AND_CALC, CALC_AND_STORE, EXEC, HALT} est_states_t;
    est_states_t est_states, next_est_states;

    always_comb begin
        for(int ii = 0; ii < est_depth; ii = ii + 1) begin
            ffe_est[ii] = (int_ffe_est[ii] >>> adapt_bitwidth);
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
            est_states <= RST;
            for(int ii = 0; ii < est_depth; ii = ii + 1) begin
                int_ffe_est[ii] <= 0;
            end
        end else begin
            tap_pos <= next_tap_pos;
            tap_decimal <= next_tap_decimal;
            est_states <= next_est_states;
            if(store_tap_decimal) begin
                int_ffe_est[tap_pos] <= next_tap_decimal;
                // synthesis translate_off
                $fwrite(fid, "%d, %d\n", tap_pos, next_tap_decimal);
                // synthesis translate_on
            end
            if(load_init) begin
                for(int ii = 0; ii < est_depth; ii = ii + 1) begin
                    int_ffe_est[ii] <= (ffe_init[ii] <<< adapt_bitwidth);
                end   
            end
            if(shift_right) begin
                for(int ii = est_depth-1; ii > 0; ii = ii - 1) begin
                    int_ffe_est[ii] <= int_ffe_est[ii-1];
                end   
                int_ffe_est[0] <= 0;
            end
            if(shift_left) begin
                for(int ii = 1; ii < est_depth; ii = ii + 1) begin
                    int_ffe_est[ii-1] <= int_ffe_est[ii];
                end   
                int_ffe_est[est_depth-1] <= 0;
            end
        end
    end

    always_comb begin
        unique case (est_states)
            RST : begin
                next_est_states = exec_inst ? EXEC : LOAD_AND_CALC;
                next_tap_pos = 0;
                next_tap_decimal = tap_decimal;
            end
            LOAD_AND_CALC : begin
                next_est_states  = exec_inst ? EXEC : CALC_AND_STORE;
                next_tap_pos     = tap_pos;
                next_tap_decimal = int_ffe_est[tap_pos] + adjust_val;
            end
            CALC_AND_STORE: begin
                next_est_states  = LOAD_AND_CALC;
                next_tap_decimal = tap_decimal + adjust_val;
                next_tap_pos = (tap_pos_plus_one > est_depth - 1) ? 0 : tap_pos_plus_one;
            end
            EXEC : begin
                next_est_states = HALT;
                next_tap_decimal = 0;
                next_tap_pos = 0;
            end
            HALT : begin
                next_est_states = exec_inst ? HALT : LOAD_AND_CALC;
                next_tap_decimal = 0;
                next_tap_pos = 0;
            end
            default : begin
                next_est_states = RST;
                next_tap_pos = 0;
                next_tap_decimal = 0;
            end
        endcase
    end

    always_comb begin
        unique case (est_states)
            RST : begin
                store_tap_decimal = 0;
                shift_left = 0;
                shift_right = 0;
                load_init = 0;
            end
            LOAD_AND_CALC : begin
                store_tap_decimal = 0;
                shift_left = 0;
                shift_right = 0;
                load_init = 0;
            end
            CALC_AND_STORE : begin
                store_tap_decimal = 1;
                shift_left = 0;
                shift_right = 0;
                load_init = 0;
            end
            HALT : begin
                store_tap_decimal = 0;
                shift_left = 0;
                shift_right = 0;
                load_init = 0;
            end
            EXEC : begin
                store_tap_decimal = 0;
                unique case(inst) 
                    3'b100: begin
                        load_init = 1;
                        shift_left = 0;
                        shift_right = 0;
                    end
                    3'b011: begin
                        load_init = 0;
                        shift_left = 1;
                        shift_right = 0;
                    end 
                    3'b010: begin
                        load_init = 0;
                        shift_left = 0;
                        shift_right = 1;
                    end
                    default : begin
                        load_init = 0;
                        shift_left = 0;
                        shift_right = 0;
                    end
                endcase
            end
            default : begin 
                store_tap_decimal = 0;
                shift_left = 0;
                shift_right = 0;
                load_init = 0;
            end
        endcase
    end

endmodule : ffe_estimator
`default_nettype wire