`include "iotype.sv"

module analog_core #(
    parameter integer Nti=16,
    parameter integer Npi=9,
    parameter integer Nadc=8,
    parameter integer Nout=4
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
    output wire logic [1:0] sign_out_rep                 // adc_rep_output (to DOORE)
    
	//acore_debug_intf.acore adbg_intf_i                 // TODO: uncomment
);
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic emu_rst;

    // instantiate analog slices

    logic [7:0] chunk;
    logic [1:0] chunk_idx;
    logic incr_sum;
    logic last_cycle;

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin
            // determine the slice offset
            logic [1:0] slice_offset;
            assign slice_offset = i%Nout;

            analog_slice analog_slice_i (
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
                .rst(emu_rst)
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

endmodule
