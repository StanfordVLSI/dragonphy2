module tb();

    logic clk_s, clk_d, rstn_s, rstn_d, init_n_s, init_n_d, clr_s, clr_d, push_n, pop_n;
    logic fifo_empty;

    logic signed [7:0] i_data [39:0], o_data [39:0];
    logic [2:0] i_start_frame, o_start_frame;

    logic i_flags [39:0], o_flags [39:0];

    initial begin
        clk_s = 0;
        forever #8.75 clk_s = ~clk_s;
    end

    initial begin
        clk_d = 0;
        forever #5 clk_d = ~clk_d;
    end


    viterbi_fifo #(.error_width(8), .num_of_channels(40), .num_of_chunks(5)) vfifo_i (
        .i_clk(clk_s),
        .i_rstn(rstn_s),
        .i_init_n(init_n_s),
        .i_clr(clr_s),
        .push_n(push_n),

        .i_data(i_data),
        .i_flags(i_flags),
        .i_start_frame(i_start_frame),

        .o_clk(clk_d),
        .o_rstn(rstn_d),
        .o_init_n(init_n_d),
        .o_clr(clr_d),
        .pop_n(pop_n),

        .o_data(o_data),
        .o_flags(o_flags),
        .o_start_frame(o_start_frame),

        .fifo_empty(fifo_empty)
    );

    viterbi_controller #(
        .num_of_channels(40),
        .error_width(8),
        .branch_length(2),
        .num_of_chunks(5)
    ) viterbi_controller_i (
        .clk(clk_d),
        .rst_n(rstn_d),

        .residual_estimated_error(o_data),
        .start_frame(o_start_frame),
        .flags(o_flags),
        .fifo_empty(fifo_empty),

        .pop_n(pop_n),
        .init_n(init_n_d),
        .clr(clr_d),

        .trace_vals(),
        .run(),
        .initialize()
    );


    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        rstn_s = 0;
        rstn_d = 0;
        init_n_s = 0;
        clr_s = 0;
        push_n = 1;

        i_start_frame = 2;
        for (int i = 0; i < 40; i++) begin
            i_data[i] = i;
            i_flags[i] = 0;
        end
        i_flags[19] = 1;
        i_flags[35] = 1;
        $display("i_data = %p", i_data);
        @(posedge clk_s);
        rstn_s = 1;
        rstn_d = 1;
        init_n_s = 1;
        @(posedge clk_s);
        push_n = 0;
        @(posedge clk_s);
        i_start_frame = 3;
        for (int i = 0; i < 40; i++) begin
            i_data[i] = i + 40;
            i_flags[i] = 0;
        end
        push_n = 0;
        @(posedge clk_s);
        i_start_frame = 4;
        for (int i = 0; i < 40; i++) begin
            i_data[i] = i + 80;
        end
        push_n = 0;
        @(posedge clk_s);
        i_start_frame = 4;
        for (int i = 0; i < 40; i++) begin
            i_data[i] = i + 120;
        end
        push_n = 0;
        @(posedge clk_s);
        push_n = 1;
        repeat (100) @(posedge clk_s);
        $finish;
    end

endmodule // tb