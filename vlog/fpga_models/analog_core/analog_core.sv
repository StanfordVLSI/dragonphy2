`include "svreal.sv"
`include "iotype.sv"

`ifndef FUNC_DATA_WIDTH
    `define FUNC_DATA_WIDTH 18
`endif

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
    (* dont_touch = "true" *) logic [6:0] jitter_rms_int;
    (* dont_touch = "true" *) logic [10:0] noise_rms_int;
    (* dont_touch = "true" *) logic [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_0;
    (* dont_touch = "true" *) logic [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_1;
    (* dont_touch = "true" *) logic [8:0] chan_waddr;
    (* dont_touch = "true" *) logic chan_we;

    // convert noise / jitter to svreal types

    `INT_TO_REAL({1'b0, jitter_rms_int}, 8, jitter_rms_real);
    `INT_TO_REAL({1'b0, noise_rms_int}, 12, noise_rms_real);

    `MUL_CONST_REAL(0.1e-12, jitter_rms_real, jitter_rms);
    `MUL_CONST_REAL(0.1e-3, noise_rms_real, noise_rms);

    // instantiate analog slices

    logic [7:0] chunk;
    logic [1:0] chunk_idx;
    logic incr_sum;
    logic last_cycle;

    // random number seeds generated from random.org
    localparam [31:0] jitter_seed [Nti] = '{32'd8485, 32'd25439, 32'd1655, 32'd2550, 32'd28814, 32'd19790, 32'd22931, 32'd18230, 32'd26850, 32'd11919, 32'd49789, 32'd57646, 32'd8568, 32'd25180, 32'd9577, 32'd38496};
    localparam [31:0] noise_seed [Nti] = '{32'd61349, 32'd8335, 32'd9132, 32'd25683, 32'd13215, 32'd15813, 32'd48824, 32'd37609, 32'd36034, 32'd37264, 32'd50609, 32'd56017, 32'd36602, 32'd46638, 32'd60972, 32'd65135};

    genvar i;
    generate
        for (i=0; i<Nti; i=i+1) begin
            // determine the slice offset
            logic [1:0] slice_offset;
            assign slice_offset = i%Nout;

            // instantiate the slice
            analog_slice #(
                .jitter_seed(jitter_seed[i]),
                .noise_seed(noise_seed[i]),
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
                .noise_rms(noise_rms),
                // control signals to update step response
                .wdata0(chan_wdata_0),
                .wdata1(chan_wdata_1),
                .waddr(chan_waddr),
                .we(chan_we)
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
