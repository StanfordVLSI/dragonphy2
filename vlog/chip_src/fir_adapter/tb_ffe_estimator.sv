module tb ();

    parameter chan_depth = 30;
    parameter ffe_length = 10;
    parameter bitstream_length = 20000;
    parameter chan_num = 5;
    typedef enum logic [2:0] {LOAD_INIT = 3'b1??, SHIFT_RIGHT = 3'b011, SHIFT_LEFT = 3'b010} inst_t;

    inst_t inst;

    logic clk, rst_n, current_bit;
    dsp_debug_intf dsp_dbg_intf_i();

    logic [8:0] error [15:0];
    logic [4:0] gain;

    logic en_select_tap;
    logic [3:0] select_tap_pos;

    logic signed [7:0] est_chan [29:0];
    logic signed [9:0] est_bits [15:0];
    logic signed [8:0] est_errors [15:0];
    logic signed [8:0] est_errors_buffer [15:0][1:0];
    logic signed [8:0] flat_est_errors [31:0];
    logic              sliced_bits [15:0];
    logic              sliced_est_bits [15:0];

    logic              sliced_bits_buffer [15:0][1:0];

    logic signed [9:0] bit_level_target;
    logic signed [7:0] adc_codes_in [15:0];
    logic signed [7:0] aligned_codes [15:0];

    logic signed [7:0] act_chan_arr [15:0][29:0];
    logic signed [1:0] rand_act_chan_arr [15:0][29:0];

    logic signed [7:0] act_chan [29:0];
    logic signed [9:0] ffe_taps [ffe_length-1:0];
    logic signed [9:0] ffe_weights [ffe_length-1:0];
    logic en_random;
    logic [3:0] chan_shift_arr [15:0];
    logic en_pulse, create_pulse;
    logic inp_bits [15:0];
    logic inp_bitstream [15:0];
    logic [15:0] inp_bitstream_table_32 [bitstream_length-1:0];
    logic [15:0] inp_bitstream_table_16 [bitstream_length-1:0];
    logic [15:0] inp_bitstream_table_8  [bitstream_length-1:0];
    logic [15:0] inp_bitstream_table_4 [bitstream_length-1:0];
    logic [15:0] inp_bitstream_table_2 [bitstream_length-1:0];
    logic [15:0] inp_bitstream_table_1 [bitstream_length-1:0];

    logic inp_bitstream_buffer [15:0][2:0];
    logic flat_inp_bitstream [47:0];
    logic signed [9:0] dummy_ffe_weights [15:0];
    logic signed [9:0] dummy_ffe_taps [15:0];
    logic [3:0] divider;
    logic lin_bits, fast_clk, lin_slcd_bits;
    logic signed [9:0] lin_est_bits;
    logic signed [7:0] lin_codes;
    logic signed [8:0] lin_est_error;
    logic exec_inst;
    initial begin
        //$dumpfile("out_2.vcd");
        //$dumpvars(2, tb);

        //fast_clk = 0;
        //forever begin
        //    #0.5 fast_clk = ~fast_clk;
        //end
    end
    integer gain_vec [4:0];
    integer freq_vec [4:0];
    integer delay_vec [4:0];
    initial begin
        clk = 0;
        forever begin
            //repeat(8) @(posedge fast_clk);
            #0.5 clk = ~clk;        
        end
    end

    initial begin
        lin_bits = 0;
        lin_est_bits = 0;
        lin_est_error = 0;
        lin_slcd_bits = 0;
        lin_codes = 0;
        //forever begin
        //    @(posedge clk);
        //    for(int ii = 0; ii < 16; ii += 1) begin
        //        @(negedge fast_clk);
        //        lin_codes = adc_codes_in[ii];
        //        lin_bits = flat_inp_bitstream[ii];
        //        lin_est_bits = est_bits[ii];
        //        lin_est_error = aligned_codes[ii];
        //        lin_slcd_bits = sliced_est_bits[ii];
        //    end
//
        //end
    end

    buffer #(
        .numChannels (16),
        .bitwidth    (1),
        .depth       (2),
        .delay_width(4),
        .width_width(4)
    ) inp_bits_buff_i (
        .in      (inp_bitstream),
        .in_delay      (),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (inp_bitstream_buffer),
        .buffer_delay  ()
    );

    flatten_buffer_slice #(
        .numChannels(16),
        .bitwidth   (1),
        .buff_depth (2),
        .slice_depth(2),
        .start      (0),
        .delay_width(4),
        .width_width(4)
    ) sb_fb_i (
        .buffer    (inp_bitstream_buffer),
        .buffer_delay (),
        .flat_slice(flat_inp_bitstream),
        .flat_slice_delay()
    );


    logic pulse_state;
    integer r_ii;
    initial begin

        integer fid_bs;
        fid_bs = $fopen("random_bits_32.txt", "r");
        for(int ii = 0; ii < bitstream_length; ii = ii + 1) begin
            $fscanf(fid_bs, "%d\n", inp_bitstream_table_32[ii]);
        end
        $fclose(fid_bs);
        fid_bs = $fopen("random_bits_16.txt", "r");
        for(int ii = 0; ii < bitstream_length; ii = ii + 1) begin
            $fscanf(fid_bs, "%d\n", inp_bitstream_table_16[ii]);
        end
        $fclose(fid_bs);
        fid_bs = $fopen("random_bits_8.txt", "r");
        for(int ii = 0; ii < bitstream_length; ii = ii + 1) begin
            $fscanf(fid_bs, "%d\n", inp_bitstream_table_8[ii]);
        end
        $fclose(fid_bs);
        fid_bs = $fopen("random_bits_4.txt", "r");
        for(int ii = 0; ii < bitstream_length; ii = ii + 1) begin
            $fscanf(fid_bs, "%d\n", inp_bitstream_table_4[ii]);
        end
        $fclose(fid_bs);
        fid_bs = $fopen("random_bits_2.txt", "r");
        for(int ii = 0; ii < bitstream_length; ii = ii + 1) begin
            $fscanf(fid_bs, "%d\n", inp_bitstream_table_2[ii]);
        end
        $fclose(fid_bs);
        fid_bs = $fopen("random_bits_1.txt", "r");
        for(int ii = 0; ii < bitstream_length; ii = ii + 1) begin
            $fscanf(fid_bs, "%d\n", inp_bitstream_table_1[ii]);
        end
        $fclose(fid_bs);

        $display("%d", inp_bitstream_table_8[0]);

        for(int ii = 0; ii < 16; ii = ii + 1) begin
            inp_bitstream[ii] = 0;
        end
        pulse_state = 1;
        r_ii = 0;
        forever begin
            if(en_pulse) begin
                if(pulse_state) begin
                    for(int ii = 0; ii < 16; ii = ii + 1) begin
                        inp_bitstream[ii] = 0;
                    end
                    inp_bitstream[0] = 1;
                    pulse_state = 0;
                end else begin
                    for(int ii = 0; ii < 16; ii = ii + 1) begin
                        inp_bitstream[ii]    = 0;
                    end
                    pulse_state = 1;
                end
            end else if (en_random) begin
                r_ii += 1;
                for(int jj = 0; jj < 16; jj = jj + 1) begin
                    inp_bitstream[jj] = inp_bitstream_table_1[r_ii][15-jj];
                end
                if(r_ii >= bitstream_length - 1) begin
                    r_ii = 0;
                end
            end else begin
                inp_bitstream    = {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1};
            end
            @(negedge clk);
        end
    end

    always_comb begin
        for(int ii = 0; ii < 16; ii = ii + 1) begin
            chan_shift_arr[ii] = 0;
            for(int jj = 0; jj < 30; jj = jj + 1) begin
                act_chan_arr[ii][jj] = act_chan[29 - jj]; //+ rand_act_chan_arr[ii][jj];
            end
        end
    end

    always_comb begin
        dsp_dbg_intf_i.align_pos = 0;
        for(int ii = 0; ii < 16; ii = ii + 1) begin
            dsp_dbg_intf_i.channel_shift[ii] = 0;
            dsp_dbg_intf_i.thresh[ii] = 0;
            dsp_dbg_intf_i.ffe_shift[ii] = 4;

            for(int jj = 0; jj < 16; jj = jj + 1) begin
                dsp_dbg_intf_i.channel_est[ii][jj] = est_chan[jj];
            end
            for(int jj = 0; jj < ffe_length; jj = jj + 1) begin
                dsp_dbg_intf_i.weights[ii][jj] = ffe_weights[jj];
                if (ii == 0) begin
                    dsp_dbg_intf_i.disable_product[jj] = 0;
                end
            end
        end
    end

    channel_filter #(
        .width(16),
        .depth(30),
        .est_channel_bitwidth(8),
        .est_code_bitwidth(8),
        .shift_bitwidth(4)
    ) act_chan_i (
        .bitstream(flat_inp_bitstream[47:3]),
        .bitstream_delay(0),
        .channel(act_chan_arr),
        .shift(chan_shift_arr),

        .est_code(adc_codes_in),
        .est_code_delay()
    );

    simple_datapath_core datapath_i (
        .adc_codes(adc_codes_in),
        .clk(clk),
        .rstb(rst_n),

        //Stage 1
        .stage1_act_codes_out(aligned_codes),
        .stage1_est_bits_out(est_bits),
        .stage1_sliced_bits_out(sliced_est_bits),

        //Stage 2
        .stage2_res_errors_out  (est_errors),
        .stage2_sliced_bits_out (sliced_bits),

        .dsp_dbg_intf_i(dsp_dbg_intf_i)
    );

    buffer #(
        .numChannels (16),
        .bitwidth    (1),
        .depth       (1),
        .delay_width(4),
        .width_width(4)
    ) sb_buff_i (
        .in      (sliced_bits),
        .in_delay      (),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (sliced_bits_buffer),
        .buffer_delay  ()
    );

    signed_buffer #(
        .numChannels (16),
        .bitwidth    (9),
        .depth       (1),
        .delay_width(4),
        .width_width(4)
    ) est_err_buff_i (
        .in      (est_errors),
        .in_delay      (),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (est_errors_buffer),
        .buffer_delay  ()
    );

    signed_flatten_buffer_slice #(
        .numChannels(16),
        .bitwidth   (9),
        .buff_depth (1),
        .slice_depth(1),
        .start      (0),
        .delay_width(4),
        .width_width(4)
    ) est_err_fb_i (
        .buffer    (est_errors_buffer),
        .buffer_delay (),
        .flat_slice(flat_est_errors),
        .flat_slice_delay()
    );

    ffe_estimator #(
        .file_name($sformatf("ffe_taps_chan%0d.txt", chan_num)),
        .est_depth(ffe_length),
        .ffe_bitwidth(10), 
        .adapt_bitwidth(22), 
        .code_bitwidth(8),
        .est_bit_bitwidth(10)
    ) ffe_est_i (
        .clk(clk),
        .rst_n(rst_n),
        .sliced_est_bits(sliced_est_bits[ffe_length-1:0]),
        .est_bits(est_bits[ffe_length-1:0]),
        .current_code(aligned_codes[0]),
        .gain(gain),
        .bit_level(bit_level_target),
        .en_select_tap(en_select_tap),
        .select_tap_pos(select_tap_pos),
        .exec_inst(exec_inst),
        .inst(inst),
        .ffe_init(ffe_taps),
        .ffe_est(ffe_weights)
    );

    task read_chan_vals(
        input integer chan_num,
        input integer rate,
        input string  base
    );
        integer fid_chan;
        fid_chan = $fopen($sformatf("chan%0d_est_vals_%0d%s.txt", chan_num, rate, base), "r");
        for (int ii=0; ii<30; ii=ii+1) begin
            $fscanf(fid_chan, "%d\n", act_chan[ii]);
            $display("%d,", act_chan[ii]);
        end
        $fclose(fid_chan); 
    endtask


    integer fid;
    initial begin
        fid = $fopen("est_bits.txt", "w");
    end


    always_ff @(posedge clk) begin
        for(int ii = 0; ii < 16; ii += 1) begin
            $fwrite(fid,"%d, ", est_bits[ii]);
        end
        $fwrite(fid, "\n");
    end

    integer fd_1;
    initial begin
        ffe_taps = {0, 0, 0, 0, 0, 0, 32, 0, 0, 0};
        gain_vec = {6, 8, 8, 9, 9};
        freq_vec = {16, 8, 4, 2, 1};
        delay_vec = {80000, 40000, 2000, 2000, 2000};
        bit_level_target = 10'd70;

        for(int ii = 0; ii < 16; ii = ii + 1) begin
            for(int jj = 0; jj < 7; jj = jj + 1) begin
                rand_act_chan_arr[ii][jj] = $urandom();
            end
            for(int jj = 7; jj < 30; jj = jj + 1) begin
                rand_act_chan_arr[ii][jj] = 0;
            end
        end

        read_chan_vals(chan_num, freq_vec[0], "G");

        exec_inst = 0;
        inst = LOAD_INIT;
        gain = gain_vec[0];
        en_pulse = 0;
        en_select_tap = 0;
        select_tap_pos = 0;
        en_random = 1;
        rst_n = 0;
        repeat(10) tick();
        rst_n = 1;
        repeat(10) tick();
        exec_inst = 1;
        repeat(10) tick();
        exec_inst = 0;
        for(int ii = 1; ii < 5; ii += 1) begin
            repeat(delay_vec[ii-1]) tick();
            read_chan_vals(chan_num, freq_vec[ii], "G");
            gain = gain_vec[ii];
        end
        repeat(delay_vec[4]) tick();

        $finish;
        inst = SHIFT_LEFT;
        repeat(10) tick();
        exec_inst = 1;
        repeat(10) tick();
        exec_inst = 0;
        repeat(20000) tick();
        inst = SHIFT_RIGHT;
        repeat(10) tick();
        exec_inst = 1;
        repeat(10) tick();
        exec_inst = 0;
        repeat(20000) tick();
        //act_chan = {64, 21, 7, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        //repeat(20000) tick();
        //bit_level_target = 10'd45;
        //repeat(60000) tick();
        //act_chan = {64, 32, 16, 8, 4, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        //repeat(60000) tick();
        $finish;
    end

    task tick();
        @(posedge clk);
    endtask : tick

    task tock();
        @(negedge clk);
    endtask : tock

endmodule : tb
