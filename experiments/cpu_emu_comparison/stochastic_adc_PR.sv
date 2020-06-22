// simple model used for performance comparison with emulation

`timescale 1s/1fs

`include "mLingua_pwl.vh"
`include "iotype.sv"

module stochastic_adc_PR #(
    parameter Nctl_v2t = 5,
    parameter Nctl_TDC = 5,
    parameter Ndiv = 2,
    parameter Nctl_dcdl_fine = 2,
    parameter Nadc = 8
)(
    input clk_in,
    input `pwl_t VinN,
    input `pwl_t VinP,
    input `voltage_t Vcal,
    input rstb,
    input en_slice,
    input en_sync_in,
    input [Nctl_v2t-1:0]  ctl_v2t_n,
    input [Nctl_v2t-1:0]  ctl_v2t_p,
    input [Ndiv-1:0] init,
    input [Nctl_dcdl_fine-1:0] ctl_dcdl_late,
    input [Nctl_dcdl_fine-1:0] ctl_dcdl_early,
    input alws_on,
    input clk_async,
    input sel_clk_TDC,
    input [Nctl_TDC-1:0] ctl_dcdl,
    input en_pm,
    input [1:0] sel_pm_sign,
    input [1:0] sel_pm_in,
    input en_TDC_phase_reverse,

    output clk_adder,
    output reg en_sync_out,
    output del_out,
    output reg sign_out,
    output reg [Nadc-1:0] adder_out,
    output [19:0] pm_out,
    output arb_out_dmm
);
    ////////////////////////////
    // mLingua initialization //
    ////////////////////////////

    PWLMethod pm=new;
    `get_timeunit

    //////////////////////////////
    // synchronization function //
    //////////////////////////////

    reg [Ndiv-1:0] count;
    reg clk_div;
    reg clk_div_sampled;

    logic en_sync;
    logic en_sync_in_sampled;
    logic alws_onb;
    logic clk_rstb, clk_pstb;

    assign alws_onb = ~alws_on;
    assign en_sync = en_sync_in_sampled & en_slice;
    assign clk_div = count[Ndiv-1];

    always @(negedge clk_in or negedge rstb) begin
        if (!rstb) begin
            en_sync_in_sampled <= 0;
        end else begin
            en_sync_in_sampled <= en_sync_in;
        end
    end
    
	always @(posedge clk_in or negedge rstb) begin
        if (!rstb) begin
            en_sync_out <= 0;
        end else begin
            en_sync_out <= en_sync_in_sampled;
        end
    end

	always @(negedge clk_in or negedge en_sync or negedge alws_onb) begin
    	if (!en_sync) begin
    	    count <= init;
    	end else if (!alws_onb) begin
    	    count <= 2'b11;
    	end else begin
    	    count <= count+1;
        end
    end

    assign clk_adder = ~clk_div;

    //////////////////
    // ADC function //
    //////////////////

    // sampled input voltage
    real samp_p, samp_n, samp;

    // output sign and magnitude
    logic out_sgn;
    integer out_mag;

    always @(posedge clk_adder) begin
        // sample input voltage
        samp_p = pm.eval(VinP, `get_time);
        samp_n = pm.eval(VinN, `get_time);

        // determine output sign and take
        // absolute value of input voltage
        if (samp_p >= samp_n) begin
            out_sgn = 1;
            samp = samp_p - samp_n;
        end else begin
            out_sgn = 0;
            samp = samp_n - samp_p;
        end

        // determine output magnitude
        out_mag = ((1.0*samp) / (0.3)) * ((2.0**(Nadc-1.0))-1.0);

        // clamp output magnitude
        if (out_mag < 0) begin
            out_mag = 0;
        end else if (out_mag > ((2**(Nadc-1))-1)) begin
            out_mag = ((2**(Nadc-1))-1);
        end

        // write to the output
        sign_out <= out_sgn;
        adder_out <= out_mag;
    end

    ////////////////////
    // unused outputs //
    ////////////////////

    assign del_out = 0;
    assign pm_out = 0;
    assign arb_out_dmm = 0;
endmodule

