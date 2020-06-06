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
    //////////////////
    // emulator I/O //
    //////////////////

    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] dt_req;

    ///////////////////////////
    // clk_in edge detection //
    ///////////////////////////

    logic clk_in_prev, negedge_clk_in, posedge_clk_in;

    assign negedge_clk_in = (clk_in == 1'b0) && (clk_in_prev == 1'b1);
    assign posedge_clk_in = (clk_in == 1'b1) && (clk_in_prev == 1'b0);

    always @(posedge emu_clk) begin
        if (emu_rst == 1'b1) begin
            clk_in_prev <= 1'b0;
        end else begin
            clk_in_prev <= clk_in;
        end
    end

    //////////////////////////////
    // synchronization function //
    //////////////////////////////

    logic [Ndiv-1:0] count;
    logic clk_div;

    logic en_sync;
    logic en_sync_in_sampled;
    logic alws_onb;

    assign alws_onb = ~alws_on;
    assign en_sync = en_sync_in_sampled & en_slice;
    assign clk_div = count[Ndiv-1];

    // transformed always statement
    // always @(negedge clk_in or negedge rstn) begin

    always @(posedge emu_clk or negedge rstb) begin
        if (!rstb) begin
            en_sync_in_sampled <= 0;
        end else if (negedge_clk_in) begin
            en_sync_in_sampled <= en_sync_in;
        end else begin
            en_sync_in_sampled <= en_sync_in_sampled;
        end
    end

    // transformed always statement
	// always @(posedge clk_in or negedge rstn) begin

	always @(posedge emu_clk or negedge rstb) begin
        if (!rstb) begin
            en_sync_out <= 0;
        end else if (posedge_clk_in) begin
            en_sync_out <= en_sync_in_sampled;
        end else begin
            en_sync_out <= en_sync_out;
        end
    end

    // transformed always statement
	// always @(negedge clk_in or negedge en_sync or negedge alws_onb) begin

    always @(posedge emu_clk or negedge en_sync or negedge alws_onb) begin
    	if (!en_sync) begin
    	    count <= init;
    	end else if (!alws_onb) begin
    	    count <= 2'b11;
    	end else begin
    	    count <= count+1;
        end
    end

    assign clk_adder = ~clk_div;

    // ADC function

    // declare formats
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(PWL_FMT, `PWL_WIDTH, `PWL_EXPONENT);

    logic signed [8:0] adc_out;
    rx_adc_core #(
        `PASS_REAL(in_, PWL_FMT),
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT),
        `PASS_REAL(dt_req_max, DT_FMT)
    ) rx_adc_core_i (
        // main I/O: input, output, and clock
        .in_(VinP),
        .out_mag(adder_out),
        .out_sgn(sign_out),
        .clk_val(clk_adder),
        // timestep control: DT request and response
        .dt_req(dt_req),
        .emu_dt(emu_dt),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // additional input: maximum timestep
        // TODO: clean this up because it is not compatible with the `FLOAT_REAL option
        .dt_req_max({1'b0, {((`DT_WIDTH)-1){1'b1}}})
    );

    // unused outputs
    assign del_out = 0;
    assign pm_out = 0;
    assign arb_out_dmm = 0;
endmodule

