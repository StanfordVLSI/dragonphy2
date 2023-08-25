module tb();


    parameter integer num_of_channels = 8;
    parameter integer num_of_viterbis = 4;
    parameter integer sym_width = 3;
    parameter integer num_of_inputs [num_of_viterbis-1:0] = '{ 3, 3, 2, 2 };
    logic slow_domain_ready, fast_domain_ready, final_domain_ready;

    //Symbol Stream FIFO Input Controls
    logic clk_s, rstn_s, init_n_s,  clr_s, push_n_s;
    logic signed [sym_width-1:0] init_syms_s [num_of_channels-1:0];
    logic signed [sym_width-1:0] symbols [num_of_channels-1:0];
    logic [num_of_viterbis-1:0] init_tag_s;

    //Viterbi FIFO Broadcast and Symbol Stream FIFO Output Controls
    logic clk_f, rstn_f, init_n_f,  clr_f, push_n_f;

    logic signed [sym_width-1:0] correction_symbols [num_of_viterbis-1:0][num_of_channels-1:0];
    logic signed [sym_width-1:0] viterbi_out_corrections [num_of_viterbis-1:0][num_of_channels-1:0];
    logic [num_of_viterbis-1:0] push_n_v;

    logic signed [sym_width-1:0] syms_f [num_of_channels-1:0];
    logic [num_of_viterbis-1:0] tag_f;

    //Viterbi FIFO Specific Output Controls
    logic signed [sym_width-1:0] corrections [num_of_viterbis-1:0][num_of_channels-1:0];
    logic [num_of_viterbis-1:0] corr_drdy;
    logic [num_of_viterbis-1:0] corr_pop_n;

    //Final Stream FIFO Output Controls
    logic clk_d, rstn_d, init_n_d,  clr_d, pop_n_d;
    logic signed [sym_width-1:0] final_syms [num_of_channels-1:0];
    logic final_syms_empty;

    logic corr_syms_push_n;
    logic signed [sym_width-1:0] corr_syms [num_of_channels-1:0];

    initial begin
        clk_s = 0;
        forever #8.75 clk_s = ~clk_s;
    end

    initial begin
        clk_f = 0;
        forever #5 clk_f = ~clk_f;
    end

    initial begin
        clk_d = 0;
        forever #7 clk_d = ~clk_d;
    end

    symtag_fifo #( .num_of_channels(num_of_channels), .sym_width(3) ) sym_fifo_i (
        .i_clk(clk_s),
        .i_rstn(rstn_s),
        .i_init_n(init_n_s),
        .i_clr(clr_s),
        .push_n(push_n_s),

        .i_data(init_syms_s),
        .i_tag(init_tag_s),


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
        for(gi = 0; gi < num_of_viterbis; gi += 1)  begin
            output_fifo #( .num_of_channels(num_of_channels), .sym_width(3) ) vout_fifo_i (
                .i_clk(clk_f),
                .i_rstn(rstn_f),
                .i_init_n(init_n_f),
                .i_clr(clr_f),
                .push_n(push_n_v[gi]),

                .i_data(viterbi_out_corrections[gi]),


                .o_clk(clk_f),
                .o_rstn(rstn_f),
                .o_init_n(init_n_f),
                .o_clr(clr_f),
                .pop_n(corr_pop_n[gi]),

                .o_data(corrections[gi]),
                .fifo_empty(corr_drdy[gi])
            );
            // Input loop for each viterbi output fifo (Fast Clock Domain)
            initial begin
                @(posedge fast_domain_ready); // Synchronize with the fast clock domain initialization
                for(int ii = 0; ii < num_of_inputs[gi]; ii += 1) begin
                    repeat(5) @(posedge clk_f);
                    viterbi_fifo_input_controller#(gi)::write_to_viterbi_fifo(correction_symbols[gi]);
                end
            end
        end
    endgenerate
    
    combiner #(
        .num_of_channels(num_of_channels),
        .num_of_viterbis(4),
        .sym_width(3),
        .csym_width(3)
    ) combiner_i (
        .clk(clk_f),
        .rst_n(rstn_f),

        .corr_syms(corr_syms),
        .corr_syms_push_n(corr_syms_push_n),

        .syms(syms_f),
        .tag(tag_f),
        .syms_drdy(symsfifo_empty),
        .syms_pop_n(pop_n_f),

        .corrections(corrections),
        .corr_drdy(corr_drdy),
        .corr_pop_n(corr_pop_n)
    );

    output_fifo #( .num_of_channels(num_of_channels), .sym_width(3) ) vout_fifo_i (
        .i_clk(clk_f),
        .i_rstn(rstn_f),
        .i_init_n(init_n_f),
        .i_clr(clr_f),
        .push_n(corr_syms_push_n),

        .i_data(corr_syms),


        .o_clk(clk_d),
        .o_rstn(rstn_d),
        .o_init_n(init_n_d),
        .o_clr(clr_d),
        .pop_n(pop_n_d),

        .o_data(final_syms),
        .fifo_empty(final_syms_empty)
    );

    // Save to VCD
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end

    // Input control for symstream FIFO. 
    initial begin
        slow_domain_ready = 0;
        slow_domain_init();
        symbols = {-3,-1,1,3,-3,-1,1,3};
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0000,0);

        write_to_init_fifo(symbols, 4'b1100,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b1010,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0101,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b0000,0);
        write_to_init_fifo(symbols, 4'b1111,1);

        repeat(100) @(posedge clk_s);
        $finish;
    end

    // Initialization for fast domian FIFOs
    initial begin
        fast_domain_ready = 0;
        correction_symbols[3] = {-1,1,0,0,0,0,0,0};
        correction_symbols[2] = {0,0,1,-1,0,0,0,0};
        correction_symbols[1] = {0,0,0,0,-1,1,0,0};
        correction_symbols[0] = {0,0,0,0,0,0,-1,1};
        fast_domain_init();

    end

    // Output Control for Final FIFO
    initial begin
        final_domain_ready = 0;
        final_domain_init();
    end

    task slow_domain_init();
        rstn_s = 0;
        init_n_s = 0;
        clr_s = 0;
        push_n_s = 1;
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            init_syms_s[ii] = 0;
        end
        init_tag_s = 0;
        @(posedge clk_s);

        rstn_s = 1;
        init_n_s = 1;
        clr_s = 0;
        push_n_s = 1;
        @(posedge clk_s);

        slow_domain_ready = 1;
    endtask

    task fast_domain_init();
        rstn_f = 0;
        init_n_f = 0;
        clr_f = 0;
        for(int ii = 0; ii < num_of_viterbis; ii += 1) begin
            push_n_v[ii] = 1;
            for(int jj = 0; jj < num_of_channels; jj += 1) begin
                viterbi_out_corrections[ii][jj] = 0;
            end
        end
        @(posedge clk_f);

        rstn_f = 1;
        init_n_f = 1;
        clr_f = 0;
        @(posedge clk_f);

        fast_domain_ready = 1;
    endtask

    task final_domain_init();
        rstn_d = 0;
        init_n_d = 0;
        clr_d = 0;
        pop_n_d = 1;
        @(posedge clk_d);

        rstn_d = 1;
        init_n_d = 1;
        clr_d = 0;
        @(posedge clk_d);
        final_domain_ready = 1;
    endtask

    task write_to_init_fifo(
        input logic signed [sym_width-1:0] syms [num_of_channels-1:0], 
        input logic [num_of_channels-1:0] tag,
        input logic seq
    );

        push_n_s = 0;
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            init_syms_s[ii] = syms[ii];
        end
        init_tag_s = tag;
        @(posedge clk_s);
        if(seq == 1) begin
            push_n_s = 1;
            @(posedge clk_s);
        end
    endtask


    class viterbi_fifo_input_controller#(integer fifo_num = 0);
        static task write_to_viterbi_fifo(
            input logic signed [sym_width-1:0] syms [num_of_channels-1:0]
        );
            $display("Starting write to Viterbi FIFO %0d", fifo_num);
            push_n_v[fifo_num] = 0;
            for(int ii = 0; ii < num_of_channels; ii += 1) begin
                viterbi_out_corrections[fifo_num][ii] = syms[ii];
            end
            @(posedge clk_f);
            $display("Finished write to Viterbi FIFO %0d", fifo_num);
            push_n_v[fifo_num] = 1;
            @(posedge clk_f);
        endtask
    endclass : viterbi_fifo_input_controller



    task read_final_fifo(
        output logic signed [sym_width-1:0] syms [num_of_channels-1:0]
    );
        pop_n_d = 0;
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            syms[ii] = final_syms[ii];
        end
        @(posedge clk_d);

        pop_n_d = 1;
        @(posedge clk_d);
    endtask


endmodule // tb