`default_nettype none
module tb();

    parameter integer num_of_channels = 40;
    parameter integer num_of_viterbi_fifos = 4;
    parameter integer num_of_chunks = 5;
    parameter integer rse_width = 8;
    parameter integer flag_width = 8;
    parameter integer sym_width = 3;



    logic rstn, en_fifo;

    logic signed [rse_width-1:0] rse_vals [num_of_channels-1:0];
    logic signed [flag_width-1:0] flags [num_of_channels-1:0];
    logic signed [sym_width-1:0] symbols [num_of_channels-1:0];

    logic clk_s, rstn_s, init_n_s, clr_s, push_n_s;
    logic signed [sym_width-1:0] inp_syms_s [num_of_channels-1:0], syms_f [num_of_channels-1:0];
    logic [num_of_viterbi_fifos-1:0] inp_tag_s, tag_f;
    logic clk_f, rstn_f, init_n_f, clr_f, pop_n_f, symsfifo_empty;

    logic rstn_is;
    logic [num_of_viterbi_fifos-1:0] init_n_is, clr_is, push_n_is;
    logic [$clog2(num_of_chunks)-1:0] i_start_frame [num_of_viterbi_fifos-1:0];

    logic signed [rse_width-1:0] i_data [num_of_channels-1:0];
    logic                        i_flags [num_of_channels-1:0];
    
    logic rstn_vf;
    logic [num_of_viterbi_fifos-1:0] init_n_vf, clr_vf, pop_n_vf;
    logic [$clog2(num_of_chunks)-1:0] o_start_frame [num_of_viterbi_fifos-1:0];

    logic signed [rse_width-1:0] o_data [num_of_viterbi_fifos-1:0][num_of_channels-1:0];
    logic                       o_flags [num_of_viterbi_fifos-1:0][num_of_channels-1:0];

    logic [num_of_viterbi_fifos-1:0] fifo_empty_vf;


    initial begin
        clk_s = 0;
        forever #8.75 clk_s = ~clk_s;
    end


    initial begin
        clk_f = 0;
        forever #5 clk_f = ~clk_f;
    end

    inserter #(
        .num_of_channels(40),
        .num_of_viterbi_fifos(4),
        .num_of_chunks(5),
        .rse_width(8),
        .flag_width(8),
        .sym_width(3)
    ) inserter_i (
        .clk(clk_s),
        .rstn(rstn_s),
        .en_fifo(en_fifo),
        
        .rse_vals(rse_vals),
        .flags(flags),
        .symbols(symbols),

        .symbols_main(inp_syms_s),
        .tag(inp_tag_s),
        .push_n_main(push_n_s),

        .flags_v(i_flags),
        .rse_v(i_data),

        .start_loc(i_start_frame),
        .push_n_v(push_n_is),
        .clr_v(clr_is),
        .init_n_v(init_n_is)
    );

    symtag_fifo #( .num_of_channels(num_of_channels), .sym_width(3) ) sym_fifo_i (
        .i_clk(clk_s),
        .i_rstn(rstn_s),
        .i_init_n(init_n_s),
        .i_clr(clr_s),
        .push_n(push_n_s),

        .i_data(inp_syms_s),
        .i_tag(inp_tag_s),


        .o_clk(clk_f),
        .o_rstn(rstn_f),
        .o_init_n(init_n_f),
        .o_clr(clr_f),
        .pop_n(pop_n_f),

        .o_data(syms_f),
        .o_tag(tag_f),
        .fifo_empty(symsfifo_empty)
    );




    genvar gi;
    generate
        for(gi = 0; gi < num_of_viterbi_fifos; gi += 1)  begin
            viterbi_fifo #(
                .error_width(8),
                .num_of_channels(40),
                .num_of_chunks(5)
            ) vfifo_i (
                .i_clk(clk_s),
                .i_rstn(rstn_is),
                .i_init_n(init_n_is[gi]),
                .i_clr(clr_is[gi]),
                .push_n(push_n_is[gi]),

                .i_data(i_data),
                .i_flags(i_flags),
                .i_start_frame(i_start_frame[gi]),

                .o_clk(clk_f),
                .o_rstn(rstn_vf),
                .o_init_n(init_n_vf[gi]),
                .o_clr(clr_vf[gi]),
                .pop_n(pop_n_vf[gi]),

                .o_data(o_data[gi]),
                .o_flags(o_flags[gi]),
                .o_start_frame(o_start_frame[gi]),

                .fifo_empty(fifo_empty_vf[gi])
            );
            initial begin
                @(posedge rstn); // Synchronize with the fast clock domain initialization
                forever begin
                    @(posedge clk_f);
                    pop_n_vf[gi] = fifo_empty_vf[gi];
                end
            end
        end
    endgenerate

    always_comb begin 
        rstn_is = rstn;
        rstn_vf = rstn;
        rstn_s = rstn;
        rstn_f = rstn;
    end

    logic [1:0] clock_lock;


    initial begin 
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        clock_lock = 2'b00;
        rstn = 0;
        while (clock_lock != 2'b11) begin
            // When each fifo sees a clock edge, we raise the global reset
            @(posedge clk_s, posedge clk_f);
            clock_lock = clock_lock | ((clk_s) ? 2'b10 : 2'b00);
            clock_lock = clock_lock | ((clk_f) ? 2'b01 : 2'b00);
        end
        rstn = 1;

    end

    initial begin
        slow_domain_init();
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            rse_vals[ii] = 0;
            flags[ii] = 0;
            symbols[ii] = 0;
        end
        @(posedge rstn);

        repeat(4) @(posedge clk_s);
        en_fifo = 1;
        repeat(10) @(posedge clk_s);
        flags[0] = 1;
        flags[25] = 1;
        repeat(1) @(posedge clk_s);
        flags[0] = 1;
        flags[25] = 0;
        repeat(1) @(posedge clk_s);
        flags[0] = 1;
        repeat(1) @(posedge clk_s);
        flags[0] = 0;
        flags[10] = 1;
        repeat(1) @(posedge clk_s);
        flags[10] = 0;
        repeat(8) @(posedge clk_s);
        for(int ii = 0; ii < num_of_channels; ii += 1)
        flags[ii] = 1;
        repeat(2) @(posedge clk_s);
        for(int ii = 0; ii < num_of_channels; ii += 1)
        flags[ii] = 0;
        repeat(100) @(posedge clk_s);
        $finish;
    end

    initial begin
        fast_domain_init();
        @(posedge rstn);
    end


    task slow_domain_init();
        init_n_s = 1;
        clr_s = 0;
        en_fifo = 0;
    endtask

    task fast_domain_init();
        init_n_f = 1;
        clr_f = 0;
        pop_n_f = 1;

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            init_n_vf[ii] = 1;
            clr_vf[ii] = 0;
            pop_n_vf[ii] = 1;
        end
    endtask


endmodule // tb
`default_nettype wire
