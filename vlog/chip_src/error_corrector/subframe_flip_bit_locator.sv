module subframe_flip_bit_locator #(
    parameter integer width = 16,
    parameter integer subframe_width = 8,
    parameter integer ener_bitwidth = 10,
    parameter integer num_of_flip_patterns = 4,
    parameter integer flip_pattern_depth   = 3,
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
    parameter integer delay_width = 4,
    parameter integer width_width = 4
)(
    input logic [$clog2(num_of_flip_patterns+1)-1:0] flags [2*width-1:0],
    input logic [delay_width+width_width-1:0] flags_delay,
    input logic [ener_bitwidth-1:0] flag_ener [2*width-1:0],
    input logic [delay_width+width_width-1:0] flag_ener_delay,

    output logic flip_bits [width-1:0],
    output logic [delay_width+width_width-1:0] flip_bits_delay
);

    localparam integer half_subframe_width = subframe_width/2;


    logic [$clog2(num_of_flip_patterns+1)-1:0] blk_flag_slice           [2:0][subframe_width-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] red_flag_slice           [2:0][subframe_width-1:0];
    logic [ener_bitwidth-1:0] blk_flag_ener_slice                       [2:0][subframe_width-1:0];
    logic [ener_bitwidth-1:0] red_flag_ener_slice                       [2:0][subframe_width-1:0];

    logic [$clog2(num_of_flip_patterns+1)-1:0] best_blk_subframe_flag   [2:0][subframe_width-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] best_red_subframe_flag   [2:0][subframe_width-1:0];

    logic [$clog2(num_of_flip_patterns+1)-1:0] combined_blk_subframe_flags [width + subframe_width/2-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] combined_red_subframe_flags [width + subframe_width/2-1:0];
    logic [$clog2(num_of_flip_patterns+1)-1:0] selected_flags [width+subframe_width/2-1:0];
    logic unskewed_flip_bits [width+subframe_width/2-1+flip_pattern_depth-1:0];

    logic partial_flip_bits[num_of_flip_patterns:0][flip_pattern_depth-1:0];

    assign flip_bits_delay = flags_delay + 4; 

    always_comb begin
        for(int ii = 0; ii < width; ii += 1) begin
            flip_bits[ii] = unskewed_flip_bits[ii+subframe_width/2];
        end
    end

    genvar gi;

    generate
        for(gi = 0; gi < 3; gi += 1) begin
            assign red_flag_slice[gi]      = flags[width + subframe_width*(gi) - 1:width + subframe_width*(gi-1)];
            assign red_flag_ener_slice[gi] = flag_ener[width + subframe_width*(gi) - 1:width + subframe_width*(gi-1)];
            //Only need two subframes of red group
            lowest_energy_flag_locater #(
                .width(subframe_width), 
                .ener_bitwidth(ener_bitwidth),
                .flag_width($clog2(num_of_flip_patterns+1))
            ) red_lse_flag_loc_i (
                .flags(red_flag_slice[gi]),
                .flag_ener(red_flag_ener_slice[gi]),
                .best_flag(best_red_subframe_flag[gi])
            );

            assign blk_flag_slice[gi]      = flags[width + subframe_width*(gi-1) + subframe_width/2-1:width + subframe_width*(gi-2) + subframe_width/2];
            assign blk_flag_ener_slice[gi] = flag_ener[width + subframe_width*(gi-1) + subframe_width/2-1:width + subframe_width*(gi-2) + subframe_width/2];
            lowest_energy_flag_locater #(
                .width(subframe_width), 
                .ener_bitwidth(ener_bitwidth),
                .flag_width($clog2(num_of_flip_patterns+1))
            ) blk_lse_flag_loc_i (
                .flags(blk_flag_slice[gi]),
                .flag_ener(blk_flag_ener_slice[gi]),
                .best_flag(best_blk_subframe_flag[gi])
            );
        end
    endgenerate


    //Combine the subframes into two width size frames
    assign combined_red_subframe_flags[subframe_width*1-1                 :subframe_width*0]                  = best_red_subframe_flag[0];
    assign combined_red_subframe_flags[subframe_width*2-1                 :subframe_width*1]                  = best_red_subframe_flag[1];
    assign combined_red_subframe_flags[subframe_width*2+subframe_width/2-1:subframe_width*2]                  = best_red_subframe_flag[2][subframe_width/2-1:0];

    assign combined_blk_subframe_flags[subframe_width*0+subframe_width/2-1:                                0] = best_blk_subframe_flag[0][subframe_width-1:subframe_width/2];
    assign combined_blk_subframe_flags[subframe_width*1+subframe_width/2-1:                 subframe_width/2] = best_blk_subframe_flag[1];
    assign combined_blk_subframe_flags[subframe_width*2+subframe_width/2-1:subframe_width*1+subframe_width/2] = best_blk_subframe_flag[2];

    /*initial begin
        $monitor("%m.red_flags[0]: %p", flags[width + subframe_width*(0) - 1:width + subframe_width*(0-1)]);
        $monitor("%m.red_eners[0]: %p", flag_ener[width + subframe_width*(0) - 1:width + subframe_width*(0-1)]);
        $monitor("%m.blk_flags[0]: %p", flags[width + subframe_width*(-1) + subframe_width/2-1:width + subframe_width*(-2) + subframe_width/2]);
        $monitor("%m.blk_eners[0]: %p", flag_ener[width + subframe_width*(-1) + subframe_width/2-1:width + subframe_width*(-2) + subframe_width/2]);

        $monitor("%m.best_blk_subframe_flag[0]: %p", best_blk_subframe_flag[0]);
        $monitor("%m.best_red_subframe_flag[0]: %p", best_red_subframe_flag[0]);
        $monitor("%m.red_flags[1]: %p", flags[width + subframe_width*(1) - 1:width + subframe_width*(1-1)]);
        $monitor("%m.red_eners[1]: %p", flag_ener[width + subframe_width*(1) - 1:width + subframe_width*(1-1)]);
        $monitor("%m.blk_flags[1]: %p", flags[width + subframe_width*(1-1) + subframe_width/2-1:width + subframe_width*(1-2) + subframe_width/2]);
        $monitor("%m.blk_eners[1]: %p", flag_ener[width + subframe_width*(1-1) + subframe_width/2-1:width + subframe_width*(1-2) + subframe_width/2]);

        $monitor("%m.best_blk_subframe_flag[1]: %p", best_blk_subframe_flag[1]);
        $monitor("%m.best_red_subframe_flag[1]: %p", best_red_subframe_flag[1]);
        $monitor("%m.red_flags[2]: %p", flags[width + subframe_width*(2) - 1:width + subframe_width*(2-1)]);
        $monitor("%m.red_eners[2]: %p", flag_ener[width + subframe_width*(2) - 1:width + subframe_width*(2-1)]);
        $monitor("%m.blk_flags[2]: %p", flags[width + subframe_width*(2-1) + subframe_width/2-1:width + subframe_width*(2-2) + subframe_width/2]);
        $monitor("%m.blk_eners[2]: %p", flag_ener[width + subframe_width*(2-1) + subframe_width/2-1:width + subframe_width*(2-2) + subframe_width/2]);
        $monitor("%m.best_blk_subframe_flag[2]: %p", best_blk_subframe_flag[2]);
        $monitor("%m.best_red_subframe_flag[2]: %p", best_red_subframe_flag[2]);
        $monitor("%m.combined_blk_subframe_flags: %p", combined_blk_subframe_flags);
        $monitor("%m.combined_red_subframe_flags: %p", combined_red_subframe_flags);
        $monitor("%m.selected_flags: %p", selected_flags);
        $monitor("%m.unskewed_flip_bits: %p", unskewed_flip_bits);

    end */

    always_comb begin
        for(int jj = 0; jj < flip_pattern_depth; jj += 1) begin
            partial_flip_bits[0][jj] = 0;
        end
        for(int ii = 0; ii < num_of_flip_patterns; ii += 1) begin
            for(int jj = 0; jj < flip_pattern_depth; jj += 1) begin
                partial_flip_bits[ii+1][jj] = (flip_patterns[ii][jj] > 0) ? 1'b1 : 1'b0;
            end
        end

        for(int ii = 0; ii < width + subframe_width/2 + flip_pattern_depth -1; ii += 1) begin
            unskewed_flip_bits[ii] = 0;
        end

        for(int ii = 0; ii < width + subframe_width/2; ii += 1) begin
            selected_flags[ii] = (combined_red_subframe_flags[ii] == combined_blk_subframe_flags[ii]) ? combined_blk_subframe_flags[ii] : 0;
            for(int jj = 0; jj < flip_pattern_depth; jj += 1) begin
                unskewed_flip_bits[ii+jj] = unskewed_flip_bits[ii+jj] || partial_flip_bits[selected_flags[ii]][jj];
            end
        end
    end




endmodule