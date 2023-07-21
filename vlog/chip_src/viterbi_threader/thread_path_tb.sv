`default_nettype none
module tb();

    parameter integer num_of_channels = 40;
    parameter integer sym_width = 3;
    parameter integer flag_width = 5;
    parameter integer est_err_bitwidth = 8;

    logic rstn;

    // Inserter Domain
    logic clk_s;
    logic rstn_is, init_n_is, clr_is, push_n_is;

    logic signed [7:0] i_data [num_of_channels-1:0], o_data [num_of_channels-1:0], data [num_of_channels-1:0];
    logic [2:0] i_start_frame, o_start_frame, start_frame;

    logic i_flags [num_of_channels-1:0], o_flags [num_of_channels-1:0], flags [num_of_channels-1:0];

    // Viterb Domain
    logic clk_v;

    logic rstn_vd, init_n_vd, clr_vd, pop_n_vd;
    logic fifo_empty_vd;

    logic rstn_vs, init_n_vs, clr_vs, push_n_vs;

    // Combiner Domain
    logic clk_f;

    logic rstn_fd, init_n_fd, clr_fd, pop_n_fd;
    logic fifo_empty_f;

    logic signed [2:0] stored_corrections [num_of_channels-1:0];
    logic stored_corrections_empty;

    initial begin
        clk_s = 0;
        forever #8.75 clk_s = ~clk_s;
    end

    initial begin
        clk_v = 0;
        forever #5 clk_v = ~clk_v;
    end

    initial begin
        clk_f = 0;
        forever #5 clk_f = ~clk_f;
    end


    viterbi_fifo #(.error_width(8), .num_of_channels(num_of_channels), .num_of_chunks(5)) vfifo_i (
        .i_clk(clk_s),
        .i_rstn(rstn_is),
        .i_init_n(init_n_is),
        .i_clr(clr_is),
        .push_n(push_n_is),

        .i_data(i_data),
        .i_flags(i_flags),
        .i_start_frame(i_start_frame),

        .o_clk(clk_v),
        .o_rstn(rstn_vd),
        .o_init_n(init_n_vd),
        .o_clr(clr_vd),
        .pop_n(pop_n_vd),

        .o_data(o_data),
        .o_flags(o_flags),
        .o_start_frame(o_start_frame),

        .fifo_empty(fifo_empty_vd)
    );

    logic signed [7:0] trace_vals [1:0];
    logic [$clog2(num_of_channels)-1:0] idx;
    logic run, initialize, frame_end;


    viterbi_input_controller #(
        .num_of_channels(num_of_channels),
        .error_width(8),
        .branch_length(2),
        .num_of_chunks(5)
    ) vic_i (
        .clk(clk_v),
        .rst_n(rstn),

        .residual_estimated_error(o_data),
        .start_frame(o_start_frame),
        .flags(o_flags),
        .fifo_empty(fifo_empty_vd),

        .pop_n(pop_n_vd),
        .init_n(init_n_vd),
        .clr(clr_vd),

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
        .B_WIDTH(8),
        .B_LEN(2),
        .S_LEN(2),
        .SH_DEPTH(18),
        .est_channel_width(8),
        .est_chan_depth(30),
        .H_DEPTH(6)
    ) dummy_viterbi_i (
        .clk(clk_v),
        .rst_n(rstn),

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



    viterbi_output_controller #(
        .num_of_channels(num_of_channels),
        .error_width(8),
        .branch_length(2),
        .num_of_chunks(5)
    ) voc_i (
        .clk(clk_v),
        .rst_n(rstn),

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

    output_fifo #( .num_of_channels(num_of_channels), .sym_width(3) ) vofifo_i (
        .i_clk(clk_v),
        .i_rstn(rstn_vs),
        .i_init_n(init_n_vs),
        .i_clr(clr_vs),
        .push_n(push_n_vs),

        .i_data(corrections),

        .o_clk(clk_f),
        .o_rstn(rstn_fd),
        .o_init_n(init_n_fd),
        .o_clr(clr_fd),
        .pop_n(pop_n_fd),

        .o_data(stored_corrections),
        .fifo_empty(stored_corrections_empty)
    );

    assign rstn_is = rstn;
    assign rstn_vs = rstn;
    assign rstn_vd = rstn;
    assign rstn_fd = rstn;
    logic [2:0] clock_lock;

    initial begin 
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        clock_lock = 3'b000;
        rstn = 0;
        while (clock_lock != 3'b111) begin
            // When each fifo sees a clock edge, we raise the global reset
            @(posedge clk_s, posedge clk_v, posedge clk_f);
            clock_lock = clock_lock | ((clk_s) ? 3'b100 : 3'b000);
            clock_lock = clock_lock | ((clk_v) ? 3'b010 : 3'b000);
            clock_lock = clock_lock | ((clk_f) ? 3'b001 : 3'b000);
        end
        rstn = 1;

        repeat(100) @(posedge clk_s);
        $finish;
    end

    initial begin
        slow_domain_init();
        @(posedge rstn);
        start_frame = 1;
        for(int ii = 0; ii < num_of_channels; ii++) begin
            data[ii] = 0;
            flags[ii] = 0;
        end
        flags[37] = 1;
        write_to_viterbi_fifo(data, flags, start_frame, 1);
    end

    initial begin
        fast_domain_init();
        @(posedge rstn);
    end


    task slow_domain_init();
        init_n_is = 1;
        clr_is = 0;
        push_n_is = 1;
        i_start_frame = 0;
        for (int i = 0; i < num_of_channels; i++) begin
            i_data[i] = 0;
            i_flags[i] = 0;
        end
    endtask

    task fast_domain_init();
        init_n_fd = 1;
        clr_fd = 0;
        pop_n_fd = 1;
    endtask

    task write_to_viterbi_fifo(
        input logic signed [est_err_bitwidth-1:0] rse_vals [num_of_channels-1:0], 
        input logic flags [num_of_channels-1:0],
        input logic [2:0] start_frame,
        input logic seq
    );
        push_n_is = 0;
        i_start_frame = start_frame;
        for (int i = 0; i < num_of_channels; i++) begin
            i_data[i] = rse_vals[i];
            i_flags[i] = flags[i];
        end
        @(posedge clk_s);
        if(seq == 1) begin
            push_n_is = 1;
            @(posedge clk_s);
        end
    endtask

    task read_output_fifo(
        output logic signed [sym_width-1:0] corrections [num_of_channels-1:0]
    );
        pop_n_fd = 0;
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            corrections[ii] = stored_corrections[ii];
        end
        @(posedge clk_f);

        pop_n_fd = 1;
        @(posedge clk_f);
    endtask


endmodule // tb
`default_nettype wire