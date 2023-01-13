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
    input wire logic [1:0] current_bit,

    input wire logic [$clog2(adapt_bitwidth)-1:0] gain,
    input wire logic [2:0]  inst,
    input wire logic        exec_inst,
    input wire logic signed [est_bitwidth:0] load_val,
    input wire logic [4:0] load_addr,

    output logic signed [est_bitwidth-1:0] est_chan [est_depth-1:0]
);

    logic signed [est_bitwidth + adapt_bitwidth-1:0] tap_decimal, next_tap_decimal, adjust_val;
    logic signed [est_bitwidth + adapt_bitwidth-1:0] int_chan_est [est_depth-1:0];
    logic [$clog2(est_depth)-1:0] tap_pos, tap_pos_plus_one, next_tap_pos;

    logic store_tap_decimal, load;

    assign tap_pos_plus_one = tap_pos + 1;

    always_comb begin
        unique case (current_bit)
            2'b10: begin 
                adjust_val = -(error[tap_pos] <<< gain);
            end
            2'b11: begin 
                adjust_val = -3*(error[tap_pos] <<< gain);
            end
            2'b01: begin 
                adjust_val = 3*(error[tap_pos] <<< gain);
            end
            2'b00: begin 
                adjust_val = (error[tap_pos] <<< gain);
            end
        endcase
    end


    typedef enum logic [2:0] {RST, LOAD_AND_CALC, CALC_AND_STORE, EXEC, HALT} chan_est_states_t;
    chan_est_states_t chan_est_states, next_chan_est_states;

    always_comb begin
        for(int ii = 0; ii < est_depth; ii = ii + 1) begin
            est_chan[ii] = (int_chan_est[ii] >>> adapt_bitwidth);
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
                int_chan_est[tap_pos] <= next_tap_decimal;
                // synthesis translate_off
                $fwrite(fid, "%d, %d\n", tap_pos, next_tap_decimal);
                // synthesis translate_on
            end
            if(load) begin
                int_chan_est[load_addr] <= (load_val <<< adapt_bitwidth);
            end
        end
    end

    always_comb begin
        unique case (chan_est_states)
            RST : begin
                next_chan_est_states = exec_inst ? EXEC : LOAD_AND_CALC;
                next_tap_pos = 0;
                next_tap_decimal = tap_decimal;
            end
            LOAD_AND_CALC : begin
                next_chan_est_states  = exec_inst ? EXEC : CALC_AND_STORE;
                next_tap_pos     = tap_pos;
                next_tap_decimal = int_chan_est[tap_pos] + adjust_val;
            end
            CALC_AND_STORE: begin
                next_chan_est_states  = LOAD_AND_CALC;
                next_tap_decimal      = tap_decimal + adjust_val;
                next_tap_pos          = (tap_pos_plus_one > est_depth - 1) ? 0 : tap_pos_plus_one;
            end
            EXEC : begin
                next_chan_est_states = HALT;
                next_tap_decimal = 0;
                next_tap_pos = 0;
            end
            HALT : begin
                next_chan_est_states = exec_inst ? HALT : LOAD_AND_CALC;
                next_tap_decimal = 0;
                next_tap_pos = 0;
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
                load = 0;
            end
            LOAD_AND_CALC : begin
                store_tap_decimal = 0;
                load = 0;
            end
            CALC_AND_STORE : begin
                store_tap_decimal = 1;
                load = 0;
            end
            HALT : begin
                store_tap_decimal = 0;
                load = 0;
            end
            EXEC : begin
                store_tap_decimal = 0;
                unique case(inst) 
                    3'b100: begin
                        load = 1;
                    end
                    3'b011: begin
                        load = 0;
                    end 
                    3'b010: begin
                        load = 0;
                    end
                    default : begin
                        load = 0;
                    end
                endcase
            end
            default : begin 
                store_tap_decimal = 0;
                load = 0;
            end
        endcase
    end


endmodule : channel_estimator
`default_nettype wire
