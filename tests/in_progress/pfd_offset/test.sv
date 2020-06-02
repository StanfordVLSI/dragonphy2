`include "mLingua_pwl.vh"
`include "iotype.sv"

`ifndef PFD_RESET_DELAY_PS
	`define PFD_RESET_DELAY_PS 100
`endif

`define STRINGIFY(x) `"x`"

`default_nettype none

module test;

	import const_pack::*;
	import test_pack::*;
	import checker_pack::*;
	import jtag_reg_pack::*;

	localparam real v_diff_min = -0.4;
	localparam real v_diff_max = +0.4;
	localparam real v_diff_step = 0.0025;
	localparam integer n_stim = ((v_diff_max - v_diff_min)/v_diff_step) + 1;

	localparam `real_t v_cm = 0.40;

	// mLingua initialization
	PWLMethod pm=new;

	// Analog inputs
	`pwl_t ch_outp;
	`pwl_t ch_outn;
	//`real_t v_cm;
    `voltage_t v_cal;

	// clock inputs 
	logic clk_async;
	logic clk_jm_p;
	logic clk_jm_n;
	logic ext_clkp;
	logic ext_clkn;
    logic signed [Nadc-1:0] adcout_conv_signed [Nti-1:0];
	// clock outputs
	logic clk_out_p;
	logic clk_out_n;
	logic clk_trig_p;
	logic clk_trig_n;
	logic clk_retime;
	logic clk_slow;
    logic rstb;
	// dump control
	logic dump_start;
	logic clk_cdr;
	// JTAG
	jtag_intf jtag_intf_i();


	// instantiate top module
	butterphy_top top_i (
		// analog inputs
		.ext_rx_inp(ch_outp),
		.ext_rx_inn(ch_outn),
		.ext_Vcm(v_cm),
		.ext_Vcal(v_cal),

		// clock inputs 
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

		// clock outputs
		.clk_out_p(clk_out_p),
		.clk_out_n(clk_out_n),
		.clk_trig_p(clk_trig_p),
		.clk_trig_n(clk_trig_n),
		// dump control
		.ext_dump_start(dump_start),
        .ext_rstb(rstb),
		// JTAG
		.jtag_intf_i(jtag_intf_i)
	);


	clock #(
		.freq(full_rate/2), // Depends on divider!
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	); 

	jtag_drv jtag_drv_i (jtag_intf_i);

	// Save signals for post-processing

	logic record;

	rx_input_recorder #(
		.filename({"rx_input_", `STRINGIFY(`PFD_RESET_DELAY_PS), "_ps.txt"})
	) rx_input_recorder_i (
		.in_p(ch_outp),
		.in_n(ch_outn),
		.clk(record),
		.en(1'b1)
	);
	
    ti_adc_recorder #(
		.filename({"ti_adc_", `STRINGIFY(`PFD_RESET_DELAY_PS), "_ps.txt"})
    ) ti_adc_recorder_i (
		.in(top_i.idcore.adcout_unfolded[15:0]),
		.clk(record),
		.en(1'b1)
	);

    // set the delay parameters
    // there are 12 gates in the PFD reset path -- hence the division by 12
    localparam real td_nom = (1.0e-12*`PFD_RESET_DELAY_PS)/12.0;

    `define PFD_INST(inst_num) \
    	top_i.iacore.iADC[inst_num].iADC.IPFD

    genvar i_gen;
    generate
    	// set delay parameters
		for (i_gen=0; i_gen<Nti; i_gen=i_gen+1) begin
			// TinN to AND gate input
			defparam `PFD_INST(i_gen).I19.td_nom = td_nom;
			defparam `PFD_INST(i_gen).I18.td_nom = td_nom;
			// TinP to AND gate input
			defparam `PFD_INST(i_gen).I17.td_nom = td_nom;
			defparam `PFD_INST(i_gen).I16.td_nom = td_nom;
			// AND gate
			defparam `PFD_INST(i_gen).I1.td_nom  = td_nom;
			// Inverter path to PFD reset
			defparam `PFD_INST(i_gen).I13.td_nom = td_nom;
			defparam `PFD_INST(i_gen).I12.td_nom = td_nom;
			defparam `PFD_INST(i_gen).I11.td_nom = td_nom;
			defparam `PFD_INST(i_gen).I10.td_nom = td_nom;
			defparam `PFD_INST(i_gen).I9.td_nom  = td_nom;
			defparam `PFD_INST(i_gen).I8.td_nom  = td_nom;
			defparam `PFD_INST(i_gen).I7.td_nom  = td_nom;
			defparam `PFD_INST(i_gen).I6.td_nom  = td_nom;
			defparam `PFD_INST(i_gen).I3.td_nom  = td_nom;
		end
    endgenerate

	// Main stimulus program

	real stim_values [n_stim];

	task write_stim_value(input real stim_value);
		ch_outp = pm.write(v_cm+stim_value/2.0, 0, 0);
		ch_outn = pm.write(v_cm-stim_value/2.0, 0, 0);
	endtask

	task print_diff_volt();
		$display("Differential input: %0.3f V", ch_outp.a-ch_outn.a);
	endtask

	task pulse_record();
		record = 1'b1;
		#0;
		record = 1'b0;
		#0;
	endtask

	initial begin
		// signal initialization
		record = 1'b0;
		rstb = 1'b0;

		// stim values initialization
		for (int i=0; i<n_stim; i=i+1) begin
			stim_values[i] = v_diff_min + (i*v_diff_step);
		end

		#(20ns);
		rstb = 1'b1;
		#(10ns);

		// Initialize JTAG
		jtag_drv_i.init();

		// Enable the input buffer
		//jtag_drv_i.write_tc_reg(Ndiv_clk_avg, 'd5);
		jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
		jtag_drv_i.write_tc_reg(en_v2t, 'b1);
		jtag_drv_i.write_tc_reg(int_rstb, 'b1);

		@(posedge top_i.idcore.clk_adc);
		jtag_drv_i.write_tc_reg(en_ext_pfd_offset, 'b0);
		jtag_drv_i.write_tc_reg(en_pfd_cal, 'b1);


		// shuffle values and play back (for calibration)
		$display("Calibrating...");
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end

		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
		end
		// shuffle values and play back (for measurement)
		$display("Measuring...");
		stim_values.shuffle();
		foreach (stim_values[i]) begin
			write_stim_value(stim_values[i]);
			print_diff_volt();
			#(15ns);
			pulse_record();
		end

		$finish;
	end

endmodule

`default_nettype wire
