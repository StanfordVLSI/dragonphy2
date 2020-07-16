`include "svreal.sv"
`include "iotype.sv"

module analog_core import const_pack::*; #(
) (
    input `pwl_t rx_inp,                                 // RX input (+) (from pad)
	input `pwl_t rx_inn,                                 // RX input (-) (from pad)
	input `real_t Vcm,                                   // common mode voltate for termination
	                                                     // (from pad/inout)
	
    input `pwl_t rx_inp_test,                            // RX input (+) for replica ADC (from pad)
    input `pwl_t rx_inn_test,                            // RX input (-) for replica ADC (from pad)
    
	input wire logic ext_clk,                            // (+) 4GHz clock input (from pad)
	input wire logic mdll_clk,                           // (+) 4GHz clock input (from mdll)

	input wire logic ext_clk_test0,                      // (+) 4GHz clock input (from pad)
    input wire logic ext_clk_test1,                      // (-) 4GHz clock input (from pad)
    	
	input wire logic clk_async,                          // asynchronous clock for phase measurement
	                                                     // (from DCORE)
	input wire logic [Npi-1:0] ctl_pi[Nout-1:0],         // PI control code (from DCORE)
	input wire logic ctl_valid,                          // PI control valid flag (from DCORE) 

	inout `voltage_t Vcal,                               // bias voltage for V2T (from pad)
	
	output wire logic clk_adc,                           // clock for retiming adc data assigned from ADC_0
	                                                     // (to DCORE)
    output wire logic [Nadc-1:0] adder_out [Nti-1:0],    // adc output (to DCORE)
    output wire logic [Nti-1:0] sign_out,                // adc output (to DCORE)

    output wire logic [Nadc-1:0] adder_out_rep [1:0],    // adc_rep output (to DCORE)
    output wire logic [1:0] sign_out_rep,                // adc_rep_output (to DOORE)
    
	acore_debug_intf.acore adbg_intf_i
);
    // emulator I/O

    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic emu_rst;

    // noise / jitter controls
    // TODO: allow external user control

    `MAKE_REAL(jitter_rms, 10e-12);
    `MAKE_REAL(noise_rms, 10e-3);

    `ASSIGN_CONST_REAL(0, jitter_rms);
    `ASSIGN_CONST_REAL(0, noise_rms);

    // instantiate analog slices

    logic [7:0] chunk;
    logic [1:0] chunk_idx;
    logic incr_sum;
    logic last_cycle;

    genvar i;
    generate
        for (i=0; i<Nti; i=i+1) begin
            // determine the slice offset
            logic [1:0] slice_offset;
            assign slice_offset = i%Nout;

            // instantiate the slice
            analog_slice #(
                `PASS_REAL(jitter_rms, jitter_rms),
                `PASS_REAL(noise_rms, noise_rms)
            ) analog_slice_i (
                .chunk(chunk),
                .chunk_idx(chunk_idx),
                .pi_ctl(ctl_pi[i/Nout]),
                .slice_offset(slice_offset),
                .sample_ctl(last_cycle),
                .incr_sum(incr_sum),
                .write_output(last_cycle),
                .out_sgn(sign_out[i]),
                .out_mag(adder_out[i]),
                .clk(emu_clk),
                .rst(emu_rst),
                .jitter_rms(jitter_rms),
                .noise_rms(noise_rms)
            );
        end
    endgenerate

    // save history of input bits

    logic [31:0] history;

    always @(posedge emu_clk) begin
        if (emu_rst) begin
            history <= 0;
        end else if (last_cycle) begin
            history <= {rx_inp, history[31:16]};
        end else begin
            history <= history;
        end
    end

    // select chunk of input bits

    logic [4:0] history_shift;

    assign history_shift = 5'd8*(5'd3 - chunk_idx);
    assign chunk = (history >> history_shift) & 8'hFF;

    // main state machine

    logic [3:0] counter;

    always @(posedge emu_clk) begin
        if (emu_rst) begin
            counter <= 0;
        end else if (counter == 5) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    // assign various control signals

    assign chunk_idx = (counter < 4) ? counter[1:0] : 2'd0;
    assign incr_sum = (counter != 1) ? 1'b1 : 1'b0;
    assign last_cycle = (counter == 5) ? 1'b1 : 1'b0;

    // replica slices aren't modeled yet

    assign adder_out_rep[0] = 0;
    assign adder_out_rep[1] = 0;
    assign sign_out_rep = 0;

    // assign clk_adc

    (* dont_touch = "true" *) logic clk_adc_val;
    (* dont_touch = "true" *) logic clk_adc_i;

    assign clk_adc_val = ((2 <= counter) && (counter <= 4)) ? 1'b0 : 1'b1;
    assign clk_adc = clk_adc_i;

    // assign outputs in analog interface (mostly set to zero)

    generate
        for (i=0; i<Nti; i=i+1) begin
            assign adbg_intf_i.pm_out[i] = 0;
        end
        for (i=0; i<Nout; i=i+1) begin
            assign adbg_intf_i.pm_out_pi[i] = 0;
            assign adbg_intf_i.Qperi[i] = '1;
            assign adbg_intf_i.max_sel_mux[i] = '1;
        end
        for (i=0; i<2; i=i+1) begin
            assign adbg_intf_i.pm_out_rep[i] = 0;
        end
    endgenerate

    assign adbg_intf_i.del_out = 0;
    assign adbg_intf_i.del_out_pi = 0;
    assign adbg_intf_i.cal_out_pi = 0;
    assign adbg_intf_i.pi_out_meas = 0;
    assign adbg_intf_i.del_out_rep = 0;
    assign adbg_intf_i.inbuf_out_meas = 0;
    assign adbg_intf_i.pfd_inp_meas = 0;
    assign adbg_intf_i.pfd_inn_meas = 0;
endmodule
