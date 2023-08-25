`default_nettype none
module thread_viterbi #(
    parameter integer num_of_channels = 40,
    parameter integer num_of_viterbi_fifos = 4,
    parameter integer num_of_chunks = 5,
    parameter integer rse_width = 8,
    parameter integer flag_width = 8,
    parameter integer sym_width = 3,
    parameter integer branch_length = 2,
    parameter integer state_length = 2,
    parameter integer static_history_length = 16,
    parameter integer dynamic_history_length = 6,
    parameter integer est_chan_width = 8,
    parameter integer est_chan_depth = 30,
    parameter integer output_fifo_depth = 16,
    parameter integer viterbi_input_fifo_depth = 64,
    parameter integer viterbi_output_fifo_depth = 64,
    parameter integer symbol_fifo_depth = 256
)(
    input wire logic rst_n,

    input wire logic dph_clk,
    input wire logic vtb_clk,
    input wire logic sys_clk,

    input wire logic en_fifo,
    input wire logic init_global,
    input wire logic clr_global,

    input wire logic signed [rse_width-1:0] rse_vals [num_of_channels-1:0],
    input wire logic signed [flag_width-1:0] flags [num_of_channels-1:0],
    input wire logic signed [sym_width-1:0] symbols [num_of_channels-1:0],

    input wire logic pop_n,
    output logic signed [sym_width-1:0] corrected_symbols [num_of_channels-1:0],
    output logic empty,
    output logic almost_empty
);

    logic [num_of_viterbi_fifos-1:0] tags;
    logic signed [sym_width-1:0] stored_symbols [num_of_channels-1:0];
    logic push_n_storage;

    integer input_tag_count [num_of_viterbi_fifos-1:0];
    integer output_tag_count [num_of_viterbi_fifos-1:0];

    integer count_difference [num_of_viterbi_fifos-1:0];
    genvar gi;
    generate
        for(gi = 0; gi < num_of_viterbi_fifos; gi += 1)
            assign count_difference[gi] = input_tag_count[gi] - output_tag_count[gi];
    endgenerate

    logic [num_of_viterbi_fifos-1:0] combiner_tags;
    logic signed [sym_width-1:0] combiner_symbols [num_of_channels-1:0];
    logic pop_n_storage;

    logic [$clog2(num_of_chunks)-1:0] viterbi_start_frame [num_of_viterbi_fifos-1:0];
    logic viterbi_flags [num_of_channels-1:0];
    logic signed [rse_width-1:0] viterbi_rse_vals [num_of_channels-1:0];
    logic [num_of_chunks-1:0] coarse_flags;
    logic [num_of_viterbi_fifos-1:0] push_n_viterbi;
    logic [num_of_viterbi_fifos-1:0] clear_viterbi;
    logic [num_of_viterbi_fifos-1:0] init_n_viterbi;

    logic symfifo_empty;



    inserter #(
        .num_of_channels(num_of_channels),
        .num_of_viterbi_fifos(num_of_viterbi_fifos),
        .num_of_chunks(num_of_chunks),
        .rse_width(rse_width),
        .flag_width(flag_width),
        .sym_width(sym_width)
    ) inserter_i (
        .clk(dph_clk),
        .rstn(rst_n),
        .en_fifo(en_fifo),
        
        .rse_vals(rse_vals),
        .flags(flags),
        .symbols(symbols),

        .symbols_main(stored_symbols),
        .tag(tags),
        .push_n_main(push_n_storage),

        .flags_v(viterbi_flags),
        .cflags_v(coarse_flags),
        .rse_v(viterbi_rse_vals),
        .start_loc(viterbi_start_frame),
        .push_n_v(push_n_viterbi),

        .clr_v(clear_viterbi),
        .init_n_v(init_n_viterbi)
    );

    symtag_fifo #( .num_of_channels(num_of_channels), .sym_width(sym_width), .fifo_depth(symbol_fifo_depth), .num_of_viterbis(num_of_viterbi_fifos)) sym_fifo_i (
        .i_clk(dph_clk),
        .i_rstn(rst_n),
        .i_init_n(init_global),
        .i_clr(clr_global),

        .push_n(push_n_storage),
        .i_data(stored_symbols),
        .i_tag(tags),


        .o_clk(vtb_clk),
        .o_rstn(rst_n),
        .o_init_n(init_global),
        .o_clr(clr_global),
        .pop_n(pop_n_storage),

        .o_data(combiner_symbols),
        .o_tag(combiner_tags),
        .fifo_empty(symfifo_empty)
    );

    logic signed [sym_width-1:0] stored_corrections [num_of_viterbi_fifos-1:0] [num_of_channels-1:0];
    logic [num_of_viterbi_fifos-1:0] pop_n_corrections;
    logic [num_of_viterbi_fifos-1:0] stored_corrections_empty;


    generate
        for(gi = 0; gi < num_of_viterbi_fifos; gi += 1)  begin : THREADS

            logic signed [rse_width-1:0] o_data [num_of_channels-1:0];
            logic o_flags [num_of_channels-1:0];
            logic [$clog2(num_of_chunks)-1:0] o_start_frame;
            logic [num_of_chunks-1:0] o_coarse_flags;
            logic init_n, clr, pop_n, viterbi_fifo_empty, push_n_vs;

            viterbi_fifo #(
                .error_width(rse_width),
                .num_of_channels(num_of_channels),
                .num_of_chunks(num_of_chunks),
                .fifo_depth(viterbi_input_fifo_depth)
            ) vfifo_i (
                .i_clk(dph_clk),
                .i_rstn(rst_n),
                .i_init_n(init_n_viterbi[gi]),
                .i_clr(clear_viterbi[gi]),

                .push_n(push_n_viterbi[gi]),
                .i_data(viterbi_rse_vals),
                .i_flags(viterbi_flags),
                .i_start_frame(viterbi_start_frame[gi]),
                .i_coarse_flags(coarse_flags),

                .o_clk(vtb_clk),
                .o_rstn(rst_n),
                .o_init_n(init_n),
                .o_clr(clr),
                .pop_n(pop_n),

                .o_data(o_data),
                .o_flags(o_flags),
                .o_start_frame(o_start_frame),
                .o_coarse_flags(o_coarse_flags),

                .fifo_empty(viterbi_fifo_empty)
            );

            logic signed [7:0] trace_vals [1:0];
            logic [$clog2(num_of_channels)-1:0] idx;
            logic run, initialize, frame_end;


            viterbi_input_controller #(
                .num_of_channels(num_of_channels),
                .error_width(rse_width),
                .branch_length(branch_length),
                .num_of_chunks(num_of_chunks)
            ) vic_i (
                .clk(vtb_clk),
                .rst_n(rst_n),

                .residual_estimated_error(o_data),
                .start_frame(o_start_frame),
                .flags(o_flags),
                .coarse_flags(o_coarse_flags),
                .fifo_empty(viterbi_fifo_empty),

                .pop_n(pop_n),
                .init_n(init_n),
                .clr(clr),

                .trace_vals(trace_vals),
                .run(run),
                .initialize(initialize),
                .frame_end(frame_end),
                .idx(idx)
            );

            logic signed [2:0] dv_corrections [1:0];
            logic signed [2:0] corrections [num_of_channels-1:0];

            logic [$clog2(num_of_channels)-1:0] delayed_frame_position;
            logic delayed_run, delayed_initialize, delayed_frame_end;

            dummy_viterbi_core #(
                .num_of_channels(num_of_channels),
                .B_WIDTH(rse_width),
                .B_LEN(branch_length),
                .S_LEN(state_length),
                .SH_DEPTH(static_history_length),
                .est_channel_width(est_chan_width),
                .est_chan_depth(est_chan_depth),
                .H_DEPTH(dynamic_history_length)
            ) dummy_viterbi_i (
                .clk(vtb_clk),
                .rst_n(rst_n),

                .rse_vals(trace_vals),
                .run(run),
                .initialize(initialize),
                .frame_end(frame_end),
                .frame_position(idx),

                .final_symbols(dv_corrections),
                .delayed_run(delayed_run),
                .delayed_initialize(delayed_initialize),
                .delayed_frame_end(delayed_frame_end),
                .delayed_frame_position(delayed_frame_position)
            );

            logic clr_vs, init_n_vs;

            viterbi_output_controller #(
                .num_of_channels(num_of_channels),
                .error_width(rse_width),
                .branch_length(branch_length),
                .num_of_chunks(num_of_chunks)
            ) voc_i (
                .clk(vtb_clk),
                .rst_n(rst_n),

                .corrections(dv_corrections),
                .run(delayed_run),
                .initialize(delayed_initialize),

                .frame_end(delayed_frame_end),
                .frame_position(delayed_frame_position),

                .corrections_frame(corrections),
                .push_n(push_n_vs),
                .init_n(init_n_vs),
                .clr(clr_vs)
            );

            output_fifo #( .num_of_channels(num_of_channels), .sym_width(sym_width), .fifo_depth(viterbi_output_fifo_depth)) vofifo_i (
                .i_clk(vtb_clk),
                .i_rstn(rst_n),
                .i_init_n(init_n_vs),
                .i_clr(clr_vs),
                .push_n(push_n_vs),

                .i_data(corrections),

                .o_clk(vtb_clk),
                .o_rstn(rst_n),
                .o_init_n(init_global),
                .o_clr(clr_global),

                .pop_n(pop_n_corrections[gi]),
                .o_data(stored_corrections[gi]),
                .fifo_empty(stored_corrections_empty[gi])
            );
        end
    endgenerate

    logic signed [sym_width-1:0] corr_syms [num_of_channels-1:0];
    logic corr_syms_push_n;

    combiner #(
        .num_of_channels(num_of_channels),
        .num_of_viterbis(num_of_viterbi_fifos),
        .sym_width(sym_width),
        .csym_width(sym_width)
    ) combiner_i (
        .clk(vtb_clk),
        .rst_n(rst_n),

        .corr_syms(corr_syms),
        .corr_syms_push_n(corr_syms_push_n),

        .syms(combiner_symbols),
        .tag(combiner_tags),
        .syms_drdy(symfifo_empty),
        .syms_pop_n(pop_n_storage),

        .corrections(stored_corrections),
        .corr_drdy(stored_corrections_empty),
        .corr_pop_n(pop_n_corrections)
    );

    output_fifo #( .num_of_channels(num_of_channels), .sym_width(sym_width), .fifo_depth(output_fifo_depth) ) vout_fifo_i (
        .i_clk(vtb_clk),
        .i_rstn(rst_n),
        .i_init_n(init_global),
        .i_clr(clr_global),
        .push_n(corr_syms_push_n),

        .i_data(corr_syms),

        .o_clk(sys_clk),
        .o_rstn(rst_n),
        .o_init_n(init_global),
        .o_clr(clr_global),
        .pop_n(pop_n),

        .o_data(corrected_symbols),
        .fifo_empty(empty),
        .fifo_almost_empty(almost_empty)
    );

    always_ff @(posedge dph_clk or negedge rst_n) begin
        if(!rst_n) begin
            input_tag_count <= '{default:0};
        end else begin
            for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
                if(!push_n_viterbi[ii]) begin
                    input_tag_count[ii] <= input_tag_count[ii] + 1;
                end
            end
        end
    end

    always_ff @(posedge sys_clk or negedge rst_n) begin
        if(!rst_n) begin
            output_tag_count <= '{default:0};
        end else begin
            for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
                if(!pop_n_corrections[ii]) begin
                    output_tag_count[ii] <= output_tag_count[ii] + 1;
                end
            end
        end
    end

    endmodule
`default_nettype wire