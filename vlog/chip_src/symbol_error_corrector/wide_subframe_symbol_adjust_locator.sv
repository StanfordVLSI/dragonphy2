module wide_subframe_symbol_adjust_locator #(
    parameter integer width = 16,
    parameter integer subframe_width = 8,
    parameter integer ener_bitwidth = 10,
    parameter integer branch_bitwidth = 2,
    parameter integer sym_bitwidth = 2,
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4
)(

    input logic clk,

    input logic [$clog2(2*num_of_trellis_patterns+1)-1:0] flags [3*width-subframe_width-1:0],
    input logic [ener_bitwidth-1:0]                  flag_ener [3*width-subframe_width-1:0],

    output logic signed [(2**sym_bitwidth-1)-1:0] symbol_adjust [width-1:0],

    input  logic signed [branch_bitwidth-1:0]  trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]

);

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] blk_flag_slice           [1:0][width-1:0];
    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] red_flag_slice           [1:0][width-1:0];
    logic [ener_bitwidth-1:0] blk_flag_ener_slice                            [1:0][width-1:0];
    logic [ener_bitwidth-1:0] red_flag_ener_slice                            [1:0][width-1:0];

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] best_blk_subframe_flag   [1:0][width-1:0];
    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] best_red_subframe_flag   [1:0][width-1:0];

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] combined_blk_subframe_flags [2*width-1:0];
    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] combined_red_subframe_flags [2*width-1:0];
    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] selected_flags [2*width-1:0];

    logic signed [(2**sym_bitwidth-1)-1:0] unskewed_symbol_adjust [2*width-1:0];
    logic signed [sym_bitwidth-1:0] unfolded_trellis_patterns [2*num_of_trellis_patterns+1-1:0][trellis_pattern_depth-1:0];


    always_comb begin
        for(int ii = 0; ii < width; ii += 1) begin
            symbol_adjust[ii] = unskewed_symbol_adjust[ii + subframe_width];
        end
    end

    assign red_flag_slice[0]      = flags[2*width-subframe_width-1:width-subframe_width];
    assign red_flag_ener_slice[0] = flag_ener[2*width-subframe_width-1:width-subframe_width];
    //Only need two subframes of red group
    lowest_energy_flag_locater #(
        .width(width), 
        .ener_bitwidth(ener_bitwidth),
        .flag_width($clog2(2*num_of_trellis_patterns+1))
    ) upp_red_lse_flag_loc_i (
        .flags(red_flag_slice[0]),
        .flag_ener(red_flag_ener_slice[0]),
        .best_flag(best_red_subframe_flag[0])
    );

    assign red_flag_slice[1]      = flags[3*width-subframe_width-1:2*width-subframe_width];
    assign red_flag_ener_slice[1] = flag_ener[3*width-subframe_width-1:2*width-subframe_width];
    //Only need two subframes of red group
    lowest_energy_flag_locater #(
        .width(width), 
        .ener_bitwidth(ener_bitwidth),
        .flag_width($clog2(2*num_of_trellis_patterns+1))
    ) low_red_lse_flag_loc_i (
        .flags(red_flag_slice[1]),
        .flag_ener(red_flag_ener_slice[1]),
        .best_flag(best_red_subframe_flag[1])
    );

    assign blk_flag_slice[0]      = flags[width-1:0];
    assign blk_flag_ener_slice[0] = flag_ener[width-1:0];
    lowest_energy_flag_locater #(
        .width(width), 
        .ener_bitwidth(ener_bitwidth),
        .flag_width($clog2(2*num_of_trellis_patterns+1))
    ) low_blk_lse_flag_loc_i (
        .flags(blk_flag_slice[0]),
        .flag_ener(blk_flag_ener_slice[0]),
        .best_flag(best_blk_subframe_flag[0])
    );


    assign blk_flag_slice[1]      = flags[2*width-1:width];
    assign blk_flag_ener_slice[1] = flag_ener[2*width-1:width];
    lowest_energy_flag_locater #(
        .width(width), 
        .ener_bitwidth(ener_bitwidth),
        .flag_width($clog2(2*num_of_trellis_patterns+1))
    ) upp_blk_lse_flag_loc_i (
        .flags(blk_flag_slice[1]),
        .flag_ener(blk_flag_ener_slice[1]),
        .best_flag(best_blk_subframe_flag[1])
    );

    //Combine the subframes into two width size frames
    assign combined_red_subframe_flags[width-1:0]       = best_red_subframe_flag[0];
    assign combined_red_subframe_flags[2*width-1:width] = best_red_subframe_flag[1];

    assign combined_blk_subframe_flags[subframe_width-1:0] = best_blk_subframe_flag[0][width-1:subframe_width];
    assign combined_blk_subframe_flags[width+subframe_width-1:subframe_width] = best_blk_subframe_flag[1];
    assign combined_blk_subframe_flags[2*width-1:width + subframe_width] = '{0,0,0,0,0,0,0,0};


    always_comb begin
        for (int jj = 0; jj < trellis_pattern_depth; jj += 1) begin
            unfolded_trellis_patterns[0][jj] = 0;
        end

        for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for (int jj = 0; jj < trellis_pattern_depth; jj += 1) begin
                unfolded_trellis_patterns[2*ii+1][jj] = trellis_patterns[ii][jj];
                unfolded_trellis_patterns[2*ii+2][jj] = -trellis_patterns[ii][jj];
            end
        end
        for(int ii = 0; ii < 2*width; ii += 1) begin
            unskewed_symbol_adjust[ii] = 0;
            selected_flags[ii] = 0;
        end

        for(int ii = subframe_width - trellis_pattern_depth; ii < width + subframe_width; ii += 1) begin
            selected_flags[ii] = (combined_red_subframe_flags[ii] == combined_blk_subframe_flags[ii]) ? combined_blk_subframe_flags[ii] : 0;

            for(int jj = 0; jj < trellis_pattern_depth; jj += 1) begin
                unskewed_symbol_adjust[ii+jj] = unskewed_symbol_adjust[ii+jj] + unfolded_trellis_patterns[selected_flags[ii]][jj];
            end
        end
    end

endmodule