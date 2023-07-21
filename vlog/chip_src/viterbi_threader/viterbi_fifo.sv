module viterbi_fifo #(
    parameter integer error_width = 8,
    parameter integer num_of_channels = 40,
    parameter integer num_of_chunks = 5

) (
    input logic i_clk,
    input logic i_rstn,
    input logic i_init_n,
    input logic i_clr,
    input logic push_n,

    input logic signed [error_width-1:0] i_data [num_of_channels-1:0],
    input logic [$clog2(num_of_chunks)-1:0] i_start_frame,
    input logic i_flags [num_of_channels-1:0],

    input logic o_clk,
    input logic o_rstn,
    input logic o_init_n,
    input logic o_clr,
    input logic pop_n,

    output logic signed [error_width-1:0] o_data [num_of_channels-1:0],
    output logic [$clog2(num_of_chunks)-1:0] o_start_frame,
    output logic o_flags [num_of_channels-1:0],
    output logic fifo_empty

);
    integer ii;
    logic [error_width*num_of_channels + $clog2(num_of_chunks) + num_of_channels -1:0] i_data_flat;
    logic [error_width*num_of_channels + $clog2(num_of_chunks) + num_of_channels -1:0] o_data_flat;

    always_comb begin
        i_data_flat[error_width*num_of_channels + $clog2(num_of_chunks)-1: error_width*num_of_channels] = i_start_frame;
        for(int ii = 0; ii < num_of_channels; ii++) begin
            i_data_flat[error_width*num_of_channels + $clog2(num_of_chunks) + ii] = i_flags[ii];
            i_data_flat[error_width*ii +: error_width] = $unsigned(i_data[ii]);
        end
        o_start_frame = o_data_flat[error_width*num_of_channels + $clog2(num_of_chunks)-1: error_width*num_of_channels];
        for(int ii = 0; ii < num_of_channels; ii++) begin
            o_flags[ii] = o_data_flat[error_width*num_of_channels + $clog2(num_of_chunks) + ii];
            o_data[ii] = $signed(o_data_flat[error_width*ii +: error_width]);
        end
    end

    DW_fifo_2c_df #(
        .width(error_width*num_of_channels + $clog2(num_of_chunks) + num_of_channels),
        .ram_depth(8),
        .mem_mode(1),
        .f_sync_type(2),
        .r_sync_type(2),
        .clk_ratio(2),
        .rst_mode(0),
        .err_mode(0),
        .tst_mode(0),
        .verif_en(0),
        .clr_dual_domain(1),
        .arch_type(0)
    ) fifo_i (
        .clk_s(i_clk),
        .rst_s_n(i_rstn),
        .init_s_n(i_init_n),
        .clr_s(i_clr),
        .ae_level_s(4'b0001),
        .af_level_s(4'b0111),
        .push_s_n(push_n),
        .data_s(i_data_flat),

        .clr_sync_s(),
        .clr_in_prog_s(),
        .clr_cmplt_s(),
        .fifo_word_cnt_s(),
        .word_cnt_s(),
        .fifo_empty_s(),
        .empty_s(),
        .almost_empty_s(),
        .half_full_s(),
        .almost_full_s(),
        .full_s(),
        .error_s(),

        .clk_d(o_clk),
        .rst_d_n(o_rstn),
        .init_d_n(o_init_n),
        .clr_d(o_clr),
        .ae_level_d(4'b0001),
        .af_level_d(4'b0111),
        .pop_d_n(pop_n),

        .clr_sync_d(),
        .clr_in_prog_d(),
        .clr_cmplt_d(),
        .data_d(o_data_flat),
        .word_cnt_d(),
        .empty_d(fifo_empty),
        .almost_empty_d(),
        .half_full_d(),
        .almost_full_d(),
        .full_d(),
        .error_d(),

        .test(1'b0)
    );

endmodule // viterbi_fifo