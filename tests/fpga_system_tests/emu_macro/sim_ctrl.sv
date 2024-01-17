`timescale 1s/1fs
`include "svreal.sv"

`ifndef GIT_HASH
    `define GIT_HASH 0
`endif

`define FORCE_JTAG(name, value) force top.tb_i.top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top.tb_i.top_i.idcore.jtag_i.rjtag_intf_i.``name``

`ifndef FUNC_DATA_WIDTH
    `define FUNC_DATA_WIDTH 20
`endif

`ifndef NUM_CHUNKS
    `define NUM_CHUNKS 6
`endif

`ifndef TC
    `define TC 3e-9
`endif

`ifndef NUMEL
    `define NUMEL 1024
`endif

// macro to delay for slightly more than one "tick" of emu_clk
`define EMU_CLK_DLY #((1.1/(`EMU_CLK_FREQ))*1s)

// macro to delay for slightly more than one "tick" of clk_adc
// it is set to be one emu_clk cycle longer than the clk_adc period
`define CLK_ADC_DLY #((((`NUM_CHUNKS)+3.0)/(`EMU_CLK_FREQ))*1s)

module sim_ctrl(
    output reg rstb=1'b0,
    output reg tdi=1'b0,
    output reg tck=1'b0,
    output reg tms=1'b1,
    output reg trst_n=1'b0,
    output reg dump_start=1'b0,
    //output reg inp_sel=1'b0,
    output reg [6:0] jitter_rms_int,
    output reg [10:0] noise_rms_int,
    output reg [31:0] prbs_eqn,
    output reg [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_0,
    output reg [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_1,
    output reg [$clog2(`NUMEL)-1:0] chan_waddr,
    output reg chan_we,
    input wire tdo
);
    // calculate number of emulator cycles per "tick" of clk_adc
    localparam integer cyc_per_tick = (`NUM_CHUNKS)+2;
    localparam real clk_adc_dly = (cyc_per_tick+1.0)/(`EMU_CLK_FREQ);

	import const_pack::*;
    import jtag_reg_pack::*;

    import ffe_gpack::length;
    import ffe_gpack::weight_precision;
    import constant_gpack::channel_width;

    // function parameters
    localparam real dt_samp= `TC/(`NUMEL - 1);
    localparam integer numel=`NUMEL;
    localparam real chan_delay=10.0*dt_samp;

    // calculate FFE coefficients
    localparam real dt=1.0/(16.0e9);
    localparam real tau=5.0e-12;
    localparam integer coeff0 = 48.0/(1.0-$exp(-dt/tau));
    localparam real tt = ($exp(-dt/tau)/(1.0-$exp(-dt/tau)));
    localparam integer coeff1 = -48.0*tt; // This is broken?

    logic [3:0] random_delay;

    logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [Npi-1:0] tmp_ext_pi_ctl_offset [Nout-1:0];
    logic signed [channel_gpack::est_channel_precision-1:0] chan_coeffs [29:0];

    logic [3:0] align_pos;
    logic signed [Nadc-1:0] new_x;
    logic signed [Nadc-1:0] est_b, est_error;

    localparam weight_update = 1;
    logic signed [ffe_gpack::weight_precision-1:0] ffe_coeffs [ffe_gpack::length-1:0];
    logic signed [ffe_gpack::weight_precision-1:0] meas_ffe_coeffs [ffe_gpack::length-1:0];
    logic signed [channel_gpack::est_channel_precision-1:0] meas_chan_coeffs [30-1:0];

    integer loop_var, loop_var2, ii, jj;
    string out_str;
    logic [63:0] err_bits;
    logic [63:0] total_bits;
    logic [ffe_gpack::shift_precision-1:0] ffe_shift;
    logic [ffe_gpack::shift_precision-1:0] tmp_ffe_shift [constant_gpack::channel_width-1:0];
    logic [3:0] tmp_chan_shift [constant_gpack::channel_width-1:0];

    task read_ffe_and_channel_taps(input int ii);
        `FORCE_JTAG(sample_pos, ii);
        `CLK_ADC_DLY;
        `FORCE_JTAG(sample_fir_est, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(sample_fir_est, 0);
        `CLK_ADC_DLY;
        $display("ffe %d: %d", ii, `GET_JTAG(fe_sampled_value));
        $display("chan %d: %d", ii, `GET_JTAG(ce_sampled_value));
        `CLK_ADC_DLY;

    endtask : read_ffe_and_channel_taps

    task toggle_int_rstb();
        `FORCE_JTAG(ctrl_rstb, 3'b000);
        `FORCE_JTAG(exec_ctrl_rstb, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(exec_ctrl_rstb, 0);
        `CLK_ADC_DLY;
    endtask : toggle_int_rstb

    task toggle_sram_rstb();
        `FORCE_JTAG(ctrl_rstb, 3'b001);
        `FORCE_JTAG(exec_ctrl_rstb, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(exec_ctrl_rstb, 0);
        `CLK_ADC_DLY;
    endtask : toggle_sram_rstb

    task toggle_cdr_rstb();
        `FORCE_JTAG(ctrl_rstb, 3'b010);
        `FORCE_JTAG(exec_ctrl_rstb, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(exec_ctrl_rstb, 0);
        `CLK_ADC_DLY;
    endtask : toggle_cdr_rstb

    task toggle_prbs_rstb();
        `FORCE_JTAG(ctrl_rstb, 3'b011);
        `FORCE_JTAG(exec_ctrl_rstb, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(exec_ctrl_rstb, 0);
        `CLK_ADC_DLY;
    endtask : toggle_prbs_rstb

    task toggle_prbs_gen_rstb();
        `FORCE_JTAG(ctrl_rstb, 3'b100);
        `FORCE_JTAG(exec_ctrl_rstb, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(exec_ctrl_rstb, 0);
        `CLK_ADC_DLY;
    endtask : toggle_prbs_gen_rstb

    task toggle_acore_rstb();
        `FORCE_JTAG(ctrl_rstb, 3'b101);
        `FORCE_JTAG(exec_ctrl_rstb, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(exec_ctrl_rstb, 0);
        `CLK_ADC_DLY;
    endtask : toggle_acore_rstb

    function real chan_func(input real t);
        
        if (t <= chan_delay) begin
            chan_func = 0.0;
            //$display("%e", chan_func);
        end else begin
            chan_func = 0.45-0.45*$exp(-(t-chan_delay)/tau);// - 0.135+0.135*$exp(-(t-chan_delay-18*62.5e-12)/tau);
            //$display("%e", chan_func);
        end
    endfunction

    function logic signed [1:0] slice(input logic signed [7:0] est_b);
        slice = est_b > 0 ? 1 : -1;
    endfunction



    int fd_0, fd_1, fd_2, tmp_mm;

    initial begin
        //Initialize Channel
        chan_coeffs   = '{63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, -64, 63, 255, 255, 255, 255, 255, -256, 1023, 1023, 1023, 1023, -1024,  1023};
        //chan_coeffs   = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 25, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 64, 256,  800};
        //chan_coeffs   = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0};
        ffe_coeffs = '{0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0};
        ffe_coeffs[3] = coeff0;
        ffe_coeffs[4] = coeff1;
        random_delay = 0;
        //chan_coeffs = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127, 127};
        //inp_sel = 1;
        `FORCE_JTAG(fe_exec_inst, 1'b0);
        `FORCE_JTAG(ce_exec_inst, 1'b0);

        // initialize control signals
        jitter_rms_int = 0;
        noise_rms_int = 0;
        prbs_eqn = 32'h4000_0004;  // matches equation used by prbs21 in DaVE
        chan_wdata_0 = 0;
        chan_wdata_1 = 0;
        chan_waddr = 0;
        chan_we = 0;
        align_pos = 3;


        // wait for emulator reset to complete
        $display("Waiting for emulator reset to complete...");
        `CLK_ADC_DLY;

        // Download the channel data in steven's step response form

        // update the step response function
        chan_we = 1'b1;
        for (int idx=0; idx<numel; idx=idx+1) begin
             if ((idx % 32) == 0) begin
                $display("Updating function coefficients %0d/64", idx/32);
                $display("NUMEL: %0d", numel);
             end
             `ifndef HARD_FLOAT
                chan_wdata_0 = `FLOAT_TO_FIXED(chan_func(idx*dt_samp), -16);
                chan_wdata_1 = `FLOAT_TO_FIXED(chan_func((idx+1)*dt_samp)-chan_func(idx*dt_samp), -16);
            `else
                chan_wdata_0 = `REAL_TO_REC_FN(chan_func(idx*dt_samp));
                chan_wdata_1 = `REAL_TO_REC_FN(chan_func((idx+1)*dt_samp)-chan_func(idx*dt_samp));
            `endif
            chan_waddr = idx;
            `EMU_CLK_DLY;
        end
        chan_we = 1'b0;



//        fd_0 = $fopen("/home/zamyers/Development/dragonphy2/tests/fpga_system_tests/emu_macro/chan_vals_0.txt", "r");
//        fd_1 = $fopen("/home/zamyers/Development/dragonphy2/tests/fpga_system_tests/emu_macro/chan_vals_1.txt", "r");
//
//
//        chan_we = 1'b1;
//        for (int idx=0; idx<numel; idx=idx+1) begin
//            if ((idx % 32) == 0) begin
//                $display("Updating function coefficients %0d/32", idx/32);
//            end
//            $fscanf(fd_0, "%d,\n", chan_wdata_0);
//            $fscanf(fd_1, "%d,\n", chan_wdata_1);
//
//            chan_waddr = idx;
//            `EMU_CLK_DLY;
//        end
//        chan_we = 1'b0;
//
//        $fclose(fd_0);
//        $fclose(fd_1);

        //fd_2 = $fopen("/home/zamyers/Development/dragonphy2/tests/fpga_system_tests/emu_macro/ffe_vals.txt", "r");
        //$fscanf(fd_2, "%d\n", ffe_shift);
        //$fscanf(fd_2, "%d\n", align_pos);
        for (loop_var2=0; loop_var2<ffe_gpack::length; loop_var2=loop_var2+1) begin
        //    $fscanf(fd_2, "%d\n", ffe_coeffs[loop_var2]);
            $display("%d,", ffe_coeffs[loop_var2]);
        end
        //$fclose(fd_2);
//
        //fd_1 = $fopen("/home/zamyers/Development/dragonphy2/tests/fpga_system_tests/emu_macro/chan_est_vals.txt", "r");
        //for (loop_var2=0; loop_var2<30; loop_var2=loop_var2+1) begin
        //    $fscanf(fd_1, "%d\n", chan_coeffs[loop_var2]);
        //    $display("%d,", chan_coeffs[loop_var2]);
        //    chan_coeffs[loop_var2] = chan_coeffs[loop_var2] << 3;
        //end
        //$fclose(fd_1);     

        for (loop_var=0; loop_var<Nti; loop_var=loop_var+1) begin
            tmp_ffe_shift[loop_var] = 6;
            tmp_chan_shift[loop_var] = 3;
        end


        // release external reset signals
        rstb = 1'b1;
        trst_n = 1'b1;
        `CLK_ADC_DLY;

        // Soft reset sequence
        $display("Soft reset sequence...");
        toggle_int_rstb();
        toggle_acore_rstb();
        toggle_sram_rstb();

        `FORCE_JTAG(en_inbuf, 1);
		`CLK_ADC_DLY;
        `FORCE_JTAG(en_gf, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(en_v2t, 1);
        `CLK_ADC_DLY;

        // Set up the PFD offset
        $display("Setting up the PFD offset...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = 0;
        end
        `FORCE_JTAG(ext_pfd_offset, tmp_ext_pfd_offset);
        `CLK_ADC_DLY;

        // Set the equation for the PRBS checker
        $display("Setting the PRBS equation");
        `FORCE_JTAG(prbs_eqn, prbs_eqn);
        `CLK_ADC_DLY;

        // Select the PRBS checker data source
        $display("Select the PRBS checker data source");
        `FORCE_JTAG(sel_prbs_mux, 2'b01); // 2'b00: ADC, 2'b01: FFE
        `FORCE_JTAG(sel_trig_prbs_mux, 2'b10); // 2'b00: ADC, 2'b01: FFE
        `FORCE_JTAG(sel_prbs_bits, 1); // trig prbs
        
        `CLK_ADC_DLY;

        // Release the PRBS checker from reset
        $display("Release the PRBS tester from reset");
        toggle_prbs_rstb();
        `CLK_ADC_DLY;

        // Set up the FFE
        `FORCE_JTAG(fe_adapt_gain, 11);
        `FORCE_JTAG(fe_bit_target_level, 10'd10);
        // Pushing init_ffe_taps into ffe_estimator / ffe
        `FORCE_JTAG(init_ffe_taps, ffe_coeffs);
        `CLK_ADC_DLY;
        repeat (3) `CLK_ADC_DLY;
        `FORCE_JTAG(fe_inst, 3'b100);
        repeat (3) `CLK_ADC_DLY;
        `FORCE_JTAG(fe_exec_inst, 1'b1);
        repeat (3) `CLK_ADC_DLY;
        //Holding exec high so the FFE doesn't run


        repeat (3) `CLK_ADC_DLY;
        `FORCE_JTAG(ce_inst, 3'b100);
        for(loop_var=0; loop_var<30; loop_var=loop_var+1) begin
            `FORCE_JTAG(ce_addr, loop_var);
            `FORCE_JTAG(ce_val, chan_coeffs[loop_var]);
            repeat (3) `CLK_ADC_DLY;
            `FORCE_JTAG(ce_exec_inst, 1'b1);
            repeat (3) `CLK_ADC_DLY;
            `FORCE_JTAG(ce_exec_inst, 1'b0);
        end
        `FORCE_JTAG(ce_exec_inst, 1'b1);
        
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);
        `FORCE_JTAG(channel_shift, tmp_chan_shift);
        `FORCE_JTAG(align_pos, align_pos);
        $display("align_pos: %p", align_pos);
        $display("ffe_shift: %p", ffe_shift);
        // Configure the CDR offsets
        $display("Setting up the CDR offset...");
        tmp_ext_pi_ctl_offset[0] =   0;
        tmp_ext_pi_ctl_offset[1] = 128;
        tmp_ext_pi_ctl_offset[2] = 256;
        tmp_ext_pi_ctl_offset[3] = 384;
        `FORCE_JTAG(ext_pi_ctl_offset, tmp_ext_pi_ctl_offset);
        `CLK_ADC_DLY;
        `FORCE_JTAG(en_ext_max_sel_mux, 1);
        `FORCE_JTAG(ext_max_sel_mux, '{128, 128, 128, 128});

        `CLK_ADC_DLY;

        // Configure the retimer
        `FORCE_JTAG(retimer_mux_ctrl_1, 16'hFFFF);
        `FORCE_JTAG(retimer_mux_ctrl_2, 16'hFFFF);
        `CLK_ADC_DLY;


        // Enable Slice Estimator
        `FORCE_JTAG(force_slicers, 1);
        `FORCE_JTAG(se_gain, 6);

        // Configure the CDR
        $display("Configuring the CDR...");
        `FORCE_JTAG(Kp, 9);
        `FORCE_JTAG(Ki, 5);
        `FORCE_JTAG(en_freq_est, 0);
        `FORCE_JTAG(en_ext_pi_ctl, 1);
        `FORCE_JTAG(ext_pi_ctl, 0);
        `FORCE_JTAG(invert, 1);
        `FORCE_JTAG(sel_inp_mux, 1); // "0": use ADC output, "1": use FFE output
        `CLK_ADC_DLY;

        // Toggle the en_v2t signal to re-initialize the V2T ordering
        $display("Toggling en_v2t...");
        `FORCE_JTAG(en_v2t, 0);
        `CLK_ADC_DLY;
        `FORCE_JTAG(en_v2t, 1);
        `CLK_ADC_DLY;
        //inp_sel = 1;
        `FORCE_JTAG(fe_exec_inst, 1'b1);
        `FORCE_JTAG(en_ext_pi_ctl, 1);

        // De-assert the CDR reset
        // TODO: do we really need to wait three cycles of clk_adc?
        toggle_cdr_rstb();

        for(int mm = 1; mm < 5; mm += 1) begin
            repeat (13) @(posedge top.tb_i.top_i.idcore.clk_adc);
            tmp_mm = mm;
            `FORCE_JTAG(ext_pi_ctl, tmp_mm);
        end
        for(int mm = 5; mm >= -5; mm -= 1) begin
            repeat (13) @(posedge top.tb_i.top_i.idcore.clk_adc);
            tmp_mm = mm;
            `FORCE_JTAG(ext_pi_ctl, tmp_mm);
        end
        for(int mm = -5; mm < 5; mm += 1) begin
            repeat (13) @(posedge top.tb_i.top_i.idcore.clk_adc);
            tmp_mm = mm;
            `FORCE_JTAG(ext_pi_ctl, tmp_mm);
        end
        `CLK_ADC_DLY;
        `FORCE_JTAG(aet_trigger, 1);
        `CLK_ADC_DLY;
        `FORCE_JTAG(en_ext_pi_ctl, 0);
        `FORCE_JTAG(hist_mode, 1);
        repeat(300) `CLK_ADC_DLY;
        `FORCE_JTAG(hist_mode, 2);
        // Wait for PRBS checker to lock
		$display("Waiting for PRBS checker to lock...");
		for (loop_var=0; loop_var<50; loop_var=loop_var+1) begin
		    $display("Interval %0d/50", loop_var);
            repeat (2) `CLK_ADC_DLY;
		end
        // Inject a single bit pulse
        //repeat (50) `CLK_ADC_DLY;
        //#inp_sel = 1;

        `FORCE_JTAG(ce_gain, 10);
        `FORCE_JTAG(ce_exec_inst, 0);


        repeat (2500) `CLK_ADC_DLY;
        `FORCE_JTAG(fe_bit_target_level, 10'd10);
        `FORCE_JTAG(ce_gain, 0);
        repeat (5000) `CLK_ADC_DLY;
        `FORCE_JTAG(ce_gain, 0);
        repeat (5000) `CLK_ADC_DLY;

        for(int ii = 0; ii < 30; ii += 1) begin
            read_ffe_and_channel_taps(ii);
        end

        `FORCE_JTAG(ce_gain, 0);
        repeat (5000) `CLK_ADC_DLY;

        // Run the PRBS tester
        $display("Running the PRBS tester");
        `FORCE_JTAG(prbs_checker_mode, 2);
        repeat (100) `CLK_ADC_DLY;

        for(int ii = 0; ii < 30; ii += 1) begin
            read_ffe_and_channel_taps(ii);
        end


        //force tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[7] = -tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[7];
        //force tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[7] = ~tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[7];
        //force tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[8] = -tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[8];

        //`CLK_ADC_DLY;
        //release tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[7];
        //release tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[7];

        //release tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[8];
        repeat (10000) `CLK_ADC_DLY;
        /*
        for (loop_var=0; loop_var<511; loop_var=loop_var+3) begin
            `FORCE_JTAG(ext_pi_ctl, loop_var);
            repeat (25) `CLK_ADC_DLY;
        end 
        $finish;*/



        /*
        for (loop_var=0; loop_var<100; loop_var=loop_var+1) begin
            $display("ERROR INJECTED: ");
            random_delay = $random();
            //force tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[0] = -tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[0];
            force tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[4] = ~tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[4];
            //force tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[6] = ~tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[6];

            //force tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[8] = -tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[8];
            `CLK_ADC_DLY;
            //release tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[0];
            release tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[4];
            //release tb_i.top_i.idcore.datapath_i.stage1_sliced_bits_out[6];

            //release tb_i.top_i.idcore.datapath_i.stage1_est_bits_out[8];
            random_delay = $random();
            repeat (random_delay+1) `CLK_ADC_DLY;
        end      

        for (loop_var=0; loop_var<100; loop_var=loop_var+1) begin
		    $display("Interval %0d/100", loop_var);
            repeat (8) `CLK_ADC_DLY;
		end
        `CLK_ADC_DLY;*/

        // Get results
        `FORCE_JTAG(prbs_checker_mode, 3);
        `CLK_ADC_DLY;

        err_bits = 0;
        err_bits |= `GET_JTAG(prbs_err_bits_upper);
        err_bits <<= 32;
        err_bits |= `GET_JTAG(prbs_err_bits_lower);

        total_bits = 0;
        total_bits |= `GET_JTAG(prbs_total_bits_upper);
        total_bits <<= 32;
        total_bits |= `GET_JTAG(prbs_total_bits_lower);

        // Print results
        $display("err_bits: %0d", err_bits);
        $display("total_bits: %0d", total_bits);
        $display("BER: %0e", (1.0*err_bits)/(1.0*total_bits));

        // Check results

        if (total_bits >= 500) begin
            $display("Number of bits transmitted is OK");
        end else begin
            $error("Not enough bits transmitted");
        end

        if (err_bits == 0) begin
            $display("No bit errors detected");
        end else begin
            $error("Bit error detected");
        end

		// Finish test
		$display("Test complete.");
		$finish;
    end
endmodule
