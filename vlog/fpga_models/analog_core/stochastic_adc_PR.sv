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
    (* dont_touch = "true" *) `MAKE_REAL(noise_rms, 250e-3);

    ///////////////////////////
    // clk_in edge detection //
    ///////////////////////////

    (* dont_touch = "true" *) logic posedge_clk_in;
    (* dont_touch = "true" *) logic negedge_clk_in;

    my_edgedet det_i (
        .val(clk_in),
        .clk(emu_clk),
        .rst(emu_rst),
        .edge_p(posedge_clk_in),
        .edge_n(negedge_clk_in)
    );

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
    logic en_sync_in_sampled_state;
    assign en_sync_in_sampled = (!rstb) ? 0 : (negedge_clk_in ? en_sync_in : en_sync_in_sampled_state); 
    always @(posedge emu_clk) begin
        en_sync_in_sampled_state <= en_sync_in_sampled;
    end

    // transformed always statement
	// always @(posedge clk_in or negedge rstn) begin

    logic en_sync_out_state;
    assign en_sync_out = (!rstb) ? 0 : (posedge_clk_in ? en_sync_in_sampled : en_sync_out_state);
	always @(posedge emu_clk) begin
        en_sync_out_state <= en_sync_out;
    end

    // transformed always statement
	// always @(negedge clk_in or negedge en_sync or negedge alws_onb) begin

    logic [Ndiv-1:0] count_state;
    assign count = (!en_sync) ? init : ((!alws_onb) ? 2'b11 : (negedge_clk_in ? (count_state+1) : count_state));
    always @(posedge emu_clk) begin
        count_state <= count;
    end

    assign clk_adder = ~clk_div;

    // ADC function

    // attach format parameters to input
    `ATTACH_PWL_PARAMS(VinP);

    logic signed [8:0] adc_out;
    rx_adc_core #(
        `PASS_REAL(in_, VinP),
        `PASS_REAL(noise_rms, noise_rms)
    ) rx_adc_core_i (
        // main I/O: input, output, and clock
        .in_(VinP),
        .out_mag(adder_out),
        .out_sgn(sign_out),
        .clk_val(clk_adder),

        // noise control
        .noise_rms(noise_rms),

        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst)
    );

    // unused outputs
    assign del_out = 0;
    assign pm_out = 0;
    assign arb_out_dmm = 0;
endmodule

