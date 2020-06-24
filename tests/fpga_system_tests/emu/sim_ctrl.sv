`timescale 1s/1fs

`ifndef GIT_HASH
    `define GIT_HASH 0
`endif

`define FORCE_JTAG(name, value) force top.tb_i.top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top.tb_i.top_i.idcore.jtag_i.rjtag_intf_i.``name``

module sim_ctrl(
    output reg rstb=1'b0,
    output reg tdi=1'b0,
    output reg tck=1'b0,
    output reg tms=1'b1,
    output reg trst_n=1'b0,
    output reg dump_start=1'b0,
    input wire tdo
);
	import const_pack::*;
    import jtag_reg_pack::*;

    import ffe_gpack::length;
    import ffe_gpack::weight_precision;
    import constant_gpack::channel_width;

    // calculate FFE coefficients
    localparam real dt=1.0/(16.0e9);
    localparam real tau=25.0e-12;
    localparam integer coeff0 = 128.0/(1.0-$exp(-dt/tau));
    localparam integer coeff1 = -128.0*$exp(-dt/tau)/(1.0-$exp(-dt/tau));

    logic [Nadc-1:0] tmp_ext_pfd_offset [Nti-1:0];
    logic [Npi-1:0] tmp_ext_pi_ctl_offset [Nout-1:0];

    integer loop_var, loop_var2;
    longint err_bits, total_bits;

    logic [ffe_gpack::shift_precision-1:0] tmp_ffe_shift [constant_gpack::channel_width-1:0];

    // for loading one FFE weight with specified depth and width
    task load_weight(
        input logic [$clog2(length)-1:0] d_idx,
        logic [$clog2(channel_width)-1:0] w_idx,
        logic [weight_precision-1:0] value
    );
        $display("Loading weight d_idx=%0d, w_idx=%0d with value %0d", d_idx, w_idx, value);
        `FORCE_JTAG(wme_ffe_inst, {1'b0, w_idx, d_idx});
        `FORCE_JTAG(wme_ffe_data, value);
        #(40us);
        `FORCE_JTAG(wme_ffe_exec, 1);
        #(40us);
        `FORCE_JTAG(wme_ffe_exec, 0);
        #(40us);
    endtask

    initial begin
        // wait for emulator reset to complete
        $display("Waiting for emulator reset to complete...");
        #(10us);

        // release external reset signals
        rstb = 1'b1;
        trst_n = 1'b1;
        #(10us);

        // Soft reset sequence
        $display("Soft reset sequence...");
        `FORCE_JTAG(int_rstb, 1);
        #(1us);
        `FORCE_JTAG(en_inbuf, 1);
		#(1us);
        `FORCE_JTAG(en_gf, 1);
        #(1us);
        `FORCE_JTAG(en_v2t, 1);
        #(64us);

        // Set up the PFD offset
        $display("Setting up the PFD offset...");
        for (int idx=0; idx<Nti; idx=idx+1) begin
            tmp_ext_pfd_offset[idx] = 0;
        end
        `FORCE_JTAG(ext_pfd_offset, tmp_ext_pfd_offset);
        #(1us);

        // Select the PRBS checker data source
        $display("Select the PRBS checker data source");
        `FORCE_JTAG(sel_prbs_mux, 2'b01); // 2'b00: ADC, 2'b01: FFE
        #(10us);

        // Release the PRBS checker from reset
        $display("Release the PRBS tester from reset");
        `FORCE_JTAG(prbs_rstb, 1);
        #(50us);

        // Set up the FFE
        for (loop_var=0; loop_var<Nti; loop_var=loop_var+1) begin
            for (loop_var2=0; loop_var2<ffe_gpack::length; loop_var2=loop_var2+1) begin
                if (loop_var2 == 0) begin
                    // The argument order for load() is depth, width, value
                    load_weight(loop_var2, loop_var, coeff0);
                end else if (loop_var2 == 1) begin
                    load_weight(loop_var2, loop_var, coeff1);
                end else begin
                    load_weight(loop_var2, loop_var, 0);
                end
            end
            tmp_ffe_shift[loop_var] = 7;
        end
        `FORCE_JTAG(ffe_shift, tmp_ffe_shift);

        // Configure the CDR offsets
        $display("Setting up the CDR offset...");
        tmp_ext_pi_ctl_offset[0] =   0;
        tmp_ext_pi_ctl_offset[1] = 128;
        tmp_ext_pi_ctl_offset[2] = 256;
        tmp_ext_pi_ctl_offset[3] = 384;
        `FORCE_JTAG(ext_pi_ctl_offset, tmp_ext_pi_ctl_offset);
        #(5us);
        `FORCE_JTAG(en_ext_max_sel_mux, 1);
        #(5us);

        // Configure the retimer
        `FORCE_JTAG(retimer_mux_ctrl_1, 16'hFFFF);
        `FORCE_JTAG(retimer_mux_ctrl_2, 16'hFFFF);
        #(5us);

        // Configure the CDR
        $display("Configuring the CDR...");
        `FORCE_JTAG(Kp, 18);
        `FORCE_JTAG(Ki, 0);
        `FORCE_JTAG(invert, 1);
        `FORCE_JTAG(en_freq_est, 0);
        `FORCE_JTAG(en_ext_pi_ctl, 0);
        `FORCE_JTAG(sel_inp_mux, 1); // "0": use ADC output, "1": use FFE output
        #(5us);

        // Toggle the en_v2t signal to re-initialize the V2T ordering
        $display("Toggling en_v2t...");
        `FORCE_JTAG(en_v2t, 0);
        #(5us);
        `FORCE_JTAG(en_v2t, 1);
        #(5us);

        // Wait for PRBS checker to lock
		$display("Waiting for PRBS checker to lock...");
		for (loop_var=0; loop_var<100; loop_var=loop_var+1) begin
		    $display("Interval %0d/100", loop_var);
		    #(100us);
		end

        // Run the PRBS tester
        $display("Running the PRBS tester");
        `FORCE_JTAG(prbs_checker_mode, 2);
        for (loop_var=0; loop_var<100; loop_var=loop_var+1) begin
		    $display("Interval %0d/100", loop_var);
		    #(100us);
		end
        #(25us);

        // Get results
        `FORCE_JTAG(prbs_checker_mode, 3);
        #(10us);

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

        // Check results

        if (!(total_bits >= 500)) begin
            $error("Not enough bits transmitted");
        end else begin
            $display("Number of bits transmitted is OK");
        end

        if (!(err_bits == 0)) begin
            $error("Bit error detected");
        end else begin
            $display("No bit errors detected");
        end

		// Finish test
		$display("Test complete.");
		$finish;
    end
endmodule
