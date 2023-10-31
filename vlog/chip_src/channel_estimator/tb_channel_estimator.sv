module tb ();

    parameter chan_depth = 30;

    logic clk, rst_n, current_bit;
    dsp_debug_intf dsp_dbg_intf_i();

    logic [8:0] error [15:0];
    logic [3:0] gain;

    logic en_select_tap;
    logic [4:0] select_tap_pos;

    logic signed [7:0] est_chan [29:0];
    logic signed [9:0] est_bits [15:0];
    logic signed [8:0] est_errors [15:0];
    logic signed [8:0] est_errors_buffer [15:0][1:0];
    logic signed [8:0] flat_est_errors [31:0];
    logic              sliced_bits [15:0];
    logic              sliced_bits_buffer [15:0][1:0];

    logic signed [7:0] adc_codes_in [15:0];

    logic signed [7:0] act_chan_arr [15:0][29:0];
    logic signed [1:0] rand_act_chan_arr [15:0][29:0];

    logic signed [7:0] act_chan [29:0];
    logic signed [9:0] ffe_taps [9:0];

    logic [3:0] chan_shift_arr [15:0];
    logic en_pulse, create_pulse;
    logic inp_bits [15:0];
    logic inp_bitstream [15:0];
    logic inp_bitstream_buffer [15:0][2:0];
    logic flat_inp_bitstream [47:0];

    logic lin_bits, fast_clk, lin_slcd_bits;
    logic signed [9:0] lin_est_bits;
    logic signed [7:0] lin_codes;
    logic signed [8:0] lin_est_error;

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(2, tb);

        //fast_clk = 0;
        //forever begin
        //    #0.5 fast_clk = ~fast_clk;
        //end
    end

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
        //        lin_est_error =-est_errors[ii];
        //        lin_slcd_bits = sliced_bits[ii];
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

    initial begin
        for(int ii = 0; ii < 16; ii = ii + 1) begin
            inp_bitstream[ii] = 0;
        end
        pulse_state = 1;
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
            end else begin
                for(int ii = 0; ii < 16; ii = ii + 1) begin
                    inp_bitstream[ii]    = $random();
                end
            end
            @(negedge clk);
        end
    end

    always_comb begin
        for(int ii = 0; ii < 16; ii = ii + 1) begin
            chan_shift_arr[ii] = 1;
            for(int jj = 0; jj < 30; jj = jj + 1) begin
                act_chan_arr[ii][jj] = act_chan[29 - jj] + rand_act_chan_arr[ii][jj];
            end
        end

        dsp_dbg_intf_i.align_pos = 0;
        for(int ii = 0; ii < 16; ii = ii + 1) begin
            dsp_dbg_intf_i.channel_shift[ii] = 0;
            dsp_dbg_intf_i.thresh[ii] = 0;
            dsp_dbg_intf_i.ffe_shift[ii] = 4;

            for(int jj = 0; jj < 16; jj = jj + 1) begin
                dsp_dbg_intf_i.channel_est[ii][jj] = est_chan[jj];
            end
            for(int jj = 0; jj < 10; jj = jj + 1) begin
                dsp_dbg_intf_i.weights[ii][jj] = ffe_taps[9 - jj];
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


    bits_estimator_datapath  #(
        .ffe_pipeline_depth(2)
    )bit_est_stage_1_i(
        .clk(clk),
        .rstb(rst_n),
        // Inputs
        .act_codes_in(adc_codes),
        // Outputs
        .est_syms_out(stage1_est_bits_out),    
        .symbols_out(stage1_symbols_out),
        .act_codes_out(stage1_act_codes_out),

        // JTAG Registers
        .weights(dsp_dbg_intf_i.weights),
        .ffe_shift(dsp_dbg_intf_i.ffe_shift),
        .slice_levels(slice_levels),
        .align_pos(align_pos)
    );

    res_err_estimator_datapath  #(
        .channel_pipeline_depth(1),
        .error_output_pipeline_depth(1),
        .main_cursor_position(2)
    ) res_err_stage_2_i (
        .clk(clk),
        .rstb(rst_n),
        // Inputs
        .symbols_in(stage1_symbols_out),
        .act_codes_in(stage1_act_codes_out), 

        // Outputs
        .symbols_out(stage2_symbols_out),
        .res_err_out(stage2_res_errors_out),

        // JTAG Registers
        .channel_est(dsp_dbg_intf_i.channel_est),
        .channel_shift(dsp_dbg_intf_i.channel_shift)
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

    channel_estimator #( 
        .est_depth(30),
        .est_bitwidth(8), 
        .adapt_bitwidth(16), 
        .err_bitwidth(9)
    ) chan_est_i (
        .clk(clk),
        .rst_n(rst_n),
        .error(flat_est_errors[29:0]),
        .current_bit(sliced_bits_buffer[0][1]),
        .gain(gain),
        .en_select_tap(en_select_tap),
        .select_tap_pos(select_tap_pos),

        .est_chan(est_chan)
    );

    initial begin
        for(int ii = 0; ii < 16; ii = ii + 1) begin
            for(int jj = 0; jj < 7; jj = jj + 1) begin
                rand_act_chan_arr[ii][jj] = $urandom();
            end
            for(int jj = 7; jj < 30; jj = jj + 1) begin
                rand_act_chan_arr[ii][jj] = 0;
            end
        end

        act_chan = {64, 32, 16, 8, 4, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        ffe_taps = {32, -16, 0, 0, 0, 0, 0, 0, 0, 0};
        gain = 8;
        en_pulse = 0;
        en_select_tap = 0;
        select_tap_pos = 0;

        rst_n = 0;
        repeat(10) tick();

        rst_n = 1;
        repeat(70000) tick();

        $finish;
    end

    task tick();
        @(posedge clk);
    endtask : tick

    task tock();
        @(negedge clk);
    endtask : tock

endmodule : tb
