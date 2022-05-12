`include "svreal.sv"
`include "iotype.sv"

`ifndef FUNC_DATA_WIDTH
    `define FUNC_DATA_WIDTH 18
`endif

`ifndef CHUNK_WIDTH
    `define CHUNK_WIDTH 8
`endif

`ifndef NUM_CHUNKS
    `define NUM_CHUNKS 4
`endif

module analog_core import const_pack::*; #(
    parameter integer chunk_width=`CHUNK_WIDTH,
    parameter integer num_chunks=`NUM_CHUNKS
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
    // parameters used to determine when the clock rise & fall times should occur
    // the parameters are selected so that the clock has a 50% duty cycle
    localparam integer clock_fall = 2;
    localparam integer clock_rise = clock_fall + ((2+num_chunks)/2) - 1;

    // emulator I/O

    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic [6:0] jitter_rms_int;
    (* dont_touch = "true" *) logic [10:0] noise_rms_int;
    (* dont_touch = "true" *) logic [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_0;
    (* dont_touch = "true" *) logic [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_1;
    (* dont_touch = "true" *) logic [10:0] chan_waddr;
    (* dont_touch = "true" *) logic chan_we;

    // convert noise / jitter to svreal types

    `INT_TO_REAL({1'b0, jitter_rms_int}, 8, jitter_rms_real);
    `INT_TO_REAL({1'b0, noise_rms_int}, 12, noise_rms_real);

    `MUL_CONST_REAL(0.1e-12, jitter_rms_real, jitter_rms);
    `MUL_CONST_REAL(0.1e-3, noise_rms_real, noise_rms);

    // instantiate analog slices

    logic [(chunk_width-1):0] chunk;
    logic [($clog2(num_chunks)-1):0] chunk_idx;
    logic incr_sum;
    logic last_cycle;

    // random number seeds
    // assigned as wires instead of params since
    // there may have been an issue with the parameter array
    // print(f"32'h{random.randint(0, (1<<32)-1):08x}")

    logic [31:0] jitter_seed [Nti];
    assign jitter_seed[ 0] = 32'h95dfecdc;
    assign jitter_seed[ 1] = 32'h0985b36b;
    assign jitter_seed[ 2] = 32'h5514e4a9;
    assign jitter_seed[ 3] = 32'had34ef7c;
    assign jitter_seed[ 4] = 32'h9268bd6b;
    assign jitter_seed[ 5] = 32'h8e683253;
    assign jitter_seed[ 6] = 32'h53c0e5a7;
    assign jitter_seed[ 7] = 32'hdcfc13b5;
    assign jitter_seed[ 8] = 32'h437ae78b;
    assign jitter_seed[ 9] = 32'h484c279e;
    assign jitter_seed[10] = 32'h4670617a;
    assign jitter_seed[11] = 32'h41df025b;
    assign jitter_seed[12] = 32'h5e0b6994;
    assign jitter_seed[13] = 32'hfd479055;
    assign jitter_seed[14] = 32'h766b51c3;
    assign jitter_seed[15] = 32'haab466dc;

    logic [31:0] noise_seed [Nti];
    assign noise_seed[ 0] = 32'h047c067b;
    assign noise_seed[ 1] = 32'hf6b2c5e6;
    assign noise_seed[ 2] = 32'h9e189bc2;
    assign noise_seed[ 3] = 32'hdc986d0c;
    assign noise_seed[ 4] = 32'hf3347558;
    assign noise_seed[ 5] = 32'h4f67e54a;
    assign noise_seed[ 6] = 32'h37a0fc82;
    assign noise_seed[ 7] = 32'he73aca54;
    assign noise_seed[ 8] = 32'h62410d72;
    assign noise_seed[ 9] = 32'h7cb9b73b;
    assign noise_seed[10] = 32'hb5e52ef8;
    assign noise_seed[11] = 32'h0b3bb57b;
    assign noise_seed[12] = 32'hc2cf2beb;
    assign noise_seed[13] = 32'h88a22bee;
    assign noise_seed[14] = 32'h8e8c2794;
    assign noise_seed[15] = 32'haa1dd342;

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
                .jitter_seed(jitter_seed[i]),
                .jitter_rms(jitter_rms),
                .noise_seed(noise_seed[i]),
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

    logic [((num_chunks*chunk_width)-1):0] history;

    always @(posedge emu_clk) begin
        if (emu_rst) begin
            history <= 0;
        end else if (last_cycle) begin
            history <= {rx_inp, history[((num_chunks*chunk_width)-1):((num_chunks*chunk_width)-16)]};
        end else begin
            history <= history;
        end
    end

    // select chunk of input bits

    logic [($clog2(num_chunks*chunk_width)-1):0] history_shift;

    assign history_shift = ((num_chunks*chunk_width)-chunk_width) - chunk_width*chunk_idx;
    assign chunk = (history >> history_shift) & {chunk_width{1'b1}};

    // main state machine

    logic [($clog2(num_chunks+2)-1):0] counter;

    always @(posedge emu_clk) begin
        if (emu_rst) begin
            counter <= 0;
        end else if (counter == (num_chunks+1)) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    // assign various control signals

    assign chunk_idx = (counter < num_chunks) ? counter[($clog2(num_chunks)-1):0] : '0;
    assign incr_sum = (counter != 1) ? 1'b1 : 1'b0;
    assign last_cycle = (counter == (num_chunks+1)) ? 1'b1 : 1'b0;

    // replica slices aren't modeled yet

    assign adder_out_rep[0] = 0;
    assign adder_out_rep[1] = 0;
    assign sign_out_rep = 0;

    // assign clk_adc

    (* dont_touch = "true" *) logic clk_adc_val;
    (* dont_touch = "true" *) logic clk_adc_i;

    assign clk_adc_val = ((clock_fall <= counter) && (counter <= clock_rise)) ? 1'b0 : 1'b1;
    assign clk_adc = clk_adc_i;

    // assign outputs in analog interface (mostly set to zero)

    generate
        for (i=0; i<Nout; i=i+1) begin
            assign adbg_intf_i.pm_out_pi[i] = 0;
            assign adbg_intf_i.Qperi[i] = '1;
            assign adbg_intf_i.max_sel_mux[i] = '1;
        end
    endgenerate

    assign adbg_intf_i.del_out = 0;
    assign adbg_intf_i.del_out_pi = 0;
    assign adbg_intf_i.cal_out_pi = 0;
    assign adbg_intf_i.pi_out_meas = 0;
    assign adbg_intf_i.del_out_rep = 0;
    assign adbg_intf_i.inbuf_out_meas = 0;
endmodule
