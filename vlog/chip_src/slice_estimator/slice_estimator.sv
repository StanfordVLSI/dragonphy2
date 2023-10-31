`default_nettype none
module slice_estimator #(
    parameter integer num_of_channels = 16,
    parameter integer est_bit_bitwidth = 8,
    parameter integer adapt_bitwidth = 16
) (
    input wire logic clk,
    input wire logic rst_n,

    input wire logic signed [2:0] symbols [num_of_channels-1:0],
    input wire logic signed [est_bit_bitwidth-1:0] est_symbols [num_of_channels-1:0],

    input wire logic [$clog2(adapt_bitwidth)-1:0] gain,

    input wire logic force_slicers,
    input wire logic [est_bit_bitwidth-1:0] fe_bit_target_level,

    output logic signed [est_bit_bitwidth-1:0] slice_levels [2:0]
);

    logic signed [est_bit_bitwidth + adapt_bitwidth-1:0] int_slice_levels [2:0];
    logic signed [$clog2(2)+est_bit_bitwidth-1:0] symbol_counts [5:0];


    always_comb begin
        for(int ii = 0; ii < 6; ii = ii + 1) begin
            symbol_counts[ii] = 0;
        end

        for(int ii = 0; ii < 2; ii += 1) begin
            if ((symbols[ii] == -3) && (est_symbols[ii] * 2 > slice_levels[0]*3)) begin
                symbol_counts[0] = symbol_counts[0] + (slice_levels[0] - est_symbols[ii]);
            end else if ((symbols[ii] == -1) && (est_symbols[ii] * 2 < (slice_levels[1]+slice_levels[0]))) begin
                symbol_counts[1] = symbol_counts[1] + (est_symbols[ii] - slice_levels[0]);
            end else if ((symbols[ii] == -1) && (est_symbols[ii] * 2 > (slice_levels[1]+slice_levels[0]))) begin
                symbol_counts[2] = symbol_counts[2] + (slice_levels[1] - est_symbols[ii]);
            end else if ((symbols[ii] == 1) && (est_symbols[ii] * 2 < (slice_levels[1]+slice_levels[2]))) begin
                symbol_counts[3] = symbol_counts[3] + ( est_symbols[ii]-slice_levels[1]);
            end else if ((symbols[ii] == 1) && (est_symbols[ii] * 2 > (slice_levels[1]+slice_levels[2]))) begin
                symbol_counts[4] = symbol_counts[4] + (slice_levels[2] - est_symbols[ii]);
            end else if ((symbols[ii] == 3) && (est_symbols[ii] * 2 < slice_levels[2]*3)) begin
                symbol_counts[5] = symbol_counts[5] + (est_symbols[ii] - slice_levels[2]);
            end
        end
    end

    always_comb begin
        slice_levels[0] = force_slicers ? -2*fe_bit_target_level : (int_slice_levels[0] >>> adapt_bitwidth);
        slice_levels[1] = force_slicers ? 0*fe_bit_target_level : (int_slice_levels[1] >>> adapt_bitwidth);
        slice_levels[2] = force_slicers ? 2*fe_bit_target_level : (int_slice_levels[2] >>> adapt_bitwidth);
    end 

    always_ff @(posedge clk or negedge rst_n) begin 
        if(~rst_n) begin
            for(int ii = 0; ii < 3; ii = ii + 1) begin
                int_slice_levels[ii] <= 0;
            end
        end else begin
            if(force_slicers) begin
                int_slice_levels[0] <= -2*fe_bit_target_level <<< adapt_bitwidth;
                int_slice_levels[1] <=  0;
                int_slice_levels[2] <=  2*fe_bit_target_level <<< adapt_bitwidth;
            end else begin
                for(int ii = 0; ii < 3; ii = ii + 1) begin
                    int_slice_levels[ii] <= int_slice_levels[ii] - (((symbol_counts[ii*2+1] - symbol_counts[ii*2]) >>> 1) <<< gain);
                end
            end
        end
    end





endmodule : slice_estimator
`default_nettype wire
