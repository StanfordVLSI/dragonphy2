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
    assign clk_adc = 1'b0;

    genvar i;
    generate
        for (i=0; i<Nti; i=i+1) begin
            assign adder_out[i] = 0;
        end
    endgenerate

    assign sign_out = 0;
    assign adder_out_rep[0] = 0;
    assign adder_out_rep[1] = 0;
    assign sign_out_rep = 0;
endmodule