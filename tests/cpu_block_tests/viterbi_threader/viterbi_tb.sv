module tb();

    parameter integer num_of_channels = 40;
    parameter integer num_of_viterbi_fifos = 8;
    parameter integer num_of_chunks = 5;
    parameter integer rse_width = 8;
    parameter integer flag_width = 5;
    parameter integer sym_width = 3;
    parameter integer branch_length = 2;
    parameter integer state_length = 2;
    parameter integer static_history_length = 16;
    parameter integer dynamic_history_length = 6;
    parameter integer est_chan_width = 9;
    parameter integer est_chan_depth = 30;

    logic rst_n, dph_clk, vtb_clk, sys_clk, en_fifo, init_global, clr_global, pop_n, empty, almost_empty;
    logic bad_frame, flag_frame;
    logic signed [rse_width-1:0] rse_vals [num_of_channels-1:0];
    logic signed [flag_width-1:0] flags [num_of_channels-1:0];
    logic signed [sym_width-1:0] symbols [num_of_channels-1:0];

    logic signed [sym_width-1:0] corrected_symbols [num_of_channels-1:0];

    always_comb begin
        flag_frame = 0;
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            flag_frame = flag_frame || flags[ii];
        end
    end

    logic st_error_s, st_error_d;

    assign st_error_d = tv_i.sym_fifo_i.fifo_i.error_d;
    assign st_error_s = tv_i.sym_fifo_i.fifo_i.error_s;

    logic [num_of_viterbi_fifos-1:0] tv_if_error_s, tv_if_error_d;
    logic [num_of_viterbi_fifos-1:0] tv_of_error_s, tv_of_error_d;

    genvar gi;
    generate 
        for( gi = 0; gi < num_of_viterbi_fifos; gi += 1) begin
            always_comb begin
                tv_if_error_s[gi] = tv_i.THREADS[gi].vfifo_i.fifo_i.error_s;
                tv_if_error_d[gi] = tv_i.THREADS[gi].vfifo_i.fifo_i.error_d;
                tv_of_error_s[gi] = tv_i.THREADS[gi].vofifo_i.fifo_i.error_s;
                tv_of_error_d[gi] = tv_i.THREADS[gi].vofifo_i.fifo_i.error_d;
            end
        end
    endgenerate

    thread_viterbi #( 
        .num_of_channels(num_of_channels),
        .num_of_viterbi_fifos(num_of_viterbi_fifos),
        .num_of_chunks(num_of_chunks),
        .rse_width(rse_width),
        .flag_width(flag_width),
        .sym_width(sym_width),
        .branch_length(branch_length),
        .state_length(state_length),
        .static_history_length(static_history_length),
        .dynamic_history_length(dynamic_history_length),
        .est_chan_width(est_chan_width),
        .est_chan_depth(est_chan_depth)
    ) tv_i (
        .rst_n(rst_n),

        .dph_clk(dph_clk),
        .vtb_clk(vtb_clk),
        .sys_clk(sys_clk),

        .en_fifo(en_fifo),
        .init_global(init_global),
        .clr_global(clr_global),

        .rse_vals(rse_vals),
        .flags(flags),
        .symbols(symbols),

        .pop_n(pop_n),
        .corrected_symbols(corrected_symbols),
        .empty(empty),
        .almost_empty(almost_empty)
    );

    initial begin
        dph_clk = 0;
        forever #10 dph_clk = ~dph_clk;
    end

    initial begin
        vtb_clk = 0;
        forever #6 vtb_clk = ~vtb_clk;
    end

    initial begin
        sys_clk = 0;
        forever #6 sys_clk = ~sys_clk;
    end

    initial begin
        rst_n = 0;
        @(posedge sys_clk);
        @(posedge dph_clk);
        rst_n = 1;
    end
    integer index, li, inc;
    // Datapath Clock Domain

    always_ff @(posedge dph_clk, negedge rst_n) begin
        if(!rst_n) begin
            rse_vals = '{default: 0};
        end else begin
            for(int ii = 0; ii < num_of_channels; ii += 1) begin
                rse_vals[ii] = rse_vals[ii] + 1;
            end
        end
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        en_fifo = 0;
        init_global = 1;
        clr_global = 0;

        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            flags[ii] = 0;
            symbols[ii] = 1;
        end

        @(posedge rst_n)
        en_fifo = 1;

        repeat (3) @(posedge dph_clk);

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            flags[8] = 1;
            flags[31] = 1;
            symbols[0] = 3;
            @(posedge dph_clk);
            flags[8] = 0;
            flags[31] = 0;
            symbols[0] = 1;
            repeat(1000) @(posedge dph_clk);
        end

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            flags[16] = 1;
            flags[39] = 1;
            symbols[0] = 3;
            @(posedge dph_clk);
            flags[16] = 0;
            flags[39] = 0;
            symbols[0] = 1;
            repeat(1000) @(posedge dph_clk);
        end

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            flags[24] = 1;
            symbols[0] = 3;
            @(posedge dph_clk);
            flags[24] = 0;
            flags[7] = 1;
            symbols[0] = 1;
            @(posedge dph_clk);
            flags[7] = 0;
            symbols[0] = 1;
            repeat(1000) @(posedge dph_clk);
        end

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            flags[32] = 1;
            symbols[0] = 3;
            @(posedge dph_clk);
            flags[32] = 0;
            flags[15] = 1;
            symbols[0] = 1;
            @(posedge dph_clk);
            flags[15] = 0;
            symbols[0] = 1;
            repeat(1000) @(posedge dph_clk);
        end

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            flags[0] = 1;
            flags[23] = 1;
            symbols[0] = 3;
            @(posedge dph_clk);
            flags[0] = 0;
            flags[23] = 0;
            symbols[0] = 1;
            repeat(1000) @(posedge dph_clk);
        end


        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            @(posedge dph_clk);
            flags[ii] = 1;
            symbols[ii] = 3;
            @(posedge dph_clk);
            flags[ii] = 0;
            symbols[ii] = 1;
            repeat(1) @(posedge dph_clk);
        end
        repeat(100) @(posedge dph_clk);
        for(int ii = 0; ii < 10000; ii += 1) begin
            flags = '{default: 0};
            $write("Flags: {");
            for(int jj = 0; jj < num_of_channels; jj += 1) begin
                if ($urandom_range(0, 50) == 5) begin
                    flags[jj] = 1;
                    $write("E");
                end else begin
                    $write("_");
                end
            end
            $display("}");
            @(posedge dph_clk);
        end
        flags = '{default: 0};
        repeat(1000) @(posedge dph_clk);
        $finish;
    end

    logic chain;

    always_ff @(posedge sys_clk, negedge rst_n) begin
        if(!rst_n) begin
            pop_n <= 1;
            chain <= 0;
        end else begin
            if(!empty && !chain) begin
                pop_n <= 0;
                chain <= 1;
            end else if(!empty && chain) begin
                pop_n <= almost_empty;
                chain <= !almost_empty;
            end else begin
                pop_n <= 1;
            end

            if(!pop_n) begin
                $display("%b %b %b", empty, almost_empty, pop_n);
                $write("Corrected Symbols: {");
                bad_frame = 1;
                for(int ii = 0; ii < num_of_channels-1; ii += 1) begin
                    $write("%d,", corrected_symbols[ii]);
                    bad_frame = bad_frame && (corrected_symbols[ii] == 0);
                end
                $write("%d }", corrected_symbols[num_of_channels-1]);
                $display("");
            end
        end
    end


    task read_final_fifo(
        output logic signed [sym_width-1:0] syms [num_of_channels-1:0]
    );
        pop_n = 0;
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            syms[ii] = corrected_symbols[ii];
        end
        @(posedge sys_clk);

        pop_n = 1;
        @(posedge sys_clk);
    endtask


endmodule