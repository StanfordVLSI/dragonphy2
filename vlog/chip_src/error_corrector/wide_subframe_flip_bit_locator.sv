module wide_subframe_flip_bit_locator #(
    parameter integer width = 16,
    parameter integer subframe_width = 8,
    parameter integer ener_bitwidth = 10,
    parameter integer num_of_flip_patterns = 4,
    parameter integer flip_pattern_depth   = 3,
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
    parameter integer delay_width = 4,
    parameter integer width_width = 4
)(

    input logic clk,

    input logic [$clog2(num_of_flip_patterns+1)-1:0] flags [3*width-subframe_width-1:0],
    input logic [delay_width+width_width-1:0] flags_delay,
    input logic [ener_bitwidth-1:0] flag_ener [3*width-subframe_width-1:0],

    input logic [delay_width+width_width-1:0] flag_ener_delay,

    output logic flip_bits [width-1:0],

    output logic [delay_width+width_width-1:0] flip_bits_delay
);

    logic [$clog2(num_of_flip_patterns+1)-1:0] blk_flag_slice           [1:0][width-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] red_flag_slice           [1:0][width-1:0];
    logic [ener_bitwidth-1:0] blk_flag_ener_slice                       [1:0][width-1:0];
    logic [ener_bitwidth-1:0] red_flag_ener_slice                       [1:0][width-1:0];

    logic [$clog2(num_of_flip_patterns+1)-1:0] best_blk_subframe_flag   [1:0][width-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] best_red_subframe_flag   [1:0][width-1:0];

    logic [$clog2(num_of_flip_patterns+1)-1:0] combined_blk_subframe_flags [2*width-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] combined_red_subframe_flags [2*width-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] selected_flags [2*width-1:0];

    logic unskewed_flip_bits [2*width-1:0];

    logic partial_flip_bits[num_of_flip_patterns:0][flip_pattern_depth-1:0];
    // synthesis translate_off
    assign flip_bits_delay = flags_delay + 8; 
    // synthesis translate_on

    always_comb begin
        for(int ii = 0; ii < width; ii += 1) begin
            flip_bits[ii] = unskewed_flip_bits[ii + subframe_width];
        end
    end

    assign red_flag_slice[0]      = flags[2*width-subframe_width-1:width-subframe_width];
    assign red_flag_ener_slice[0] = flag_ener[2*width-subframe_width-1:width-subframe_width];
    //Only need two subframes of red group
    lowest_energy_flag_locater #(
        .width(width), 
        .ener_bitwidth(ener_bitwidth),
        .flag_width($clog2(num_of_flip_patterns+1))
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
        .flag_width($clog2(num_of_flip_patterns+1))
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
        .flag_width($clog2(num_of_flip_patterns+1))
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
        .flag_width($clog2(num_of_flip_patterns+1))
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

    // synthesis translate_off
    always_ff @(posedge clk) begin 
        $display("%m.flags: %p",flags);
        $display("%m.flag_ener: %p",flag_ener);
        $display("%m.best_red_subframe_flag[0]: %p",best_red_subframe_flag[0]);
        $display("%m.best_red_subframe_flag[1]: %p",best_red_subframe_flag[1]);
        $display("%m.combined_red_subframe_flags: %p",combined_red_subframe_flags);
        $display("%m.best_blk_subframe_flag[0]: %p",best_blk_subframe_flag[0]);
        $display("%m.best_blk_subframe_flag[1]: %p",best_blk_subframe_flag[1]);
        $display("%m.combined_blk_subframe_flags: %p",combined_blk_subframe_flags);
        $display("%m.unskewed_flip_bits: %p",unskewed_flip_bits);
        $display("%m.flip_bits: %p",flip_bits);
        $display("%m.selected_flags: %p",selected_flags);
    end 
    // synthesis translate_on

    always_comb begin
        for(int jj = 0; jj < flip_pattern_depth; jj += 1) begin
            partial_flip_bits[0][jj] = 0;
        end
        for(int ii = 0; ii < num_of_flip_patterns; ii += 1) begin
            for(int jj = 0; jj < flip_pattern_depth; jj += 1) begin
                partial_flip_bits[ii+1][jj] = (flip_patterns[ii][jj] > 0) ? 1'b1 : 1'b0;
            end
        end

        for(int ii = 0; ii < 2*width; ii += 1) begin
            unskewed_flip_bits[ii] = 0;
                selected_flags[ii] = 0;
        end

        for(int ii = subframe_width - flip_pattern_depth; ii < width + subframe_width; ii += 1) begin
            selected_flags[ii] = (combined_red_subframe_flags[ii] == combined_blk_subframe_flags[ii]) ? combined_blk_subframe_flags[ii] : 0;

            for(int jj = 0; jj < flip_pattern_depth; jj += 1) begin
                unskewed_flip_bits[ii+jj] = unskewed_flip_bits[ii+jj] || partial_flip_bits[selected_flags[ii]][jj];
            end
        end
    end

endmodule