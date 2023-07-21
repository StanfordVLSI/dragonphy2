module output_fifo #(
    parameter integer num_of_channels = 40,
    parameter integer sym_width = 3,
    parameter integer fifo_depth = 16
) (
    input logic i_clk,
    input logic i_rstn,
    input logic i_init_n,
    input logic i_clr,
    input logic push_n,

    input logic signed [sym_width-1:0] i_data [num_of_channels-1:0],


    input logic o_clk,
    input logic o_rstn,
    input logic o_init_n,
    input logic o_clr,
    input logic pop_n,

    output logic signed [sym_width-1:0] o_data [num_of_channels-1:0],
    output logic fifo_empty
);

    logic [sym_width*num_of_channels-1:0] i_data_flat;
    logic [sym_width*num_of_channels-1:0] o_data_flat;

    always_comb begin
        for(int ii = 0; ii < num_of_channels; ii++) begin
            i_data_flat[sym_width*ii +: sym_width] = $unsigned(i_data[ii]);
        end
        for(int ii = 0; ii < num_of_channels; ii++) begin
            o_data[ii] = o_data_flat[sym_width*ii +: sym_width];
        end
    end

    DW_fifo_2c_df #(
        .width(sym_width*num_of_channels),
        .ram_depth(fifo_depth),
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
        .ae_level_s(5'b00001),
        .af_level_s(5'b01111),
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
        .ae_level_d(5'b00001),
        .af_level_d(5'b01111),
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

endmodule // output_fifo