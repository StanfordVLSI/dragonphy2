`include "iotype.sv"
//`include "/aha/sjkim85/github_repo/dragonphy2/inc/asic/iotype.sv"

module stochastic_adc_PR #(
    parameter Nctl_v2t = 5,
    parameter Nctl_TDC = 5,
    parameter Ndiv = 2,
    parameter Nctl_dcdl_fine = 2,
    parameter Nadc = 8
)(
    input clk_in,
    input clk_retimer,
    input `pwl_t VinN,
    input `pwl_t VinP,
    input `voltage_t Vcal,
    input rstb,
    input en_slice,
    input en_sync_in,
    input [Nctl_v2t-1:0]  ctl_v2t_n,
    input [Nctl_v2t-1:0]  ctl_v2t_p,
    input [Ndiv-1:0]  init,
    input [Nctl_dcdl_fine-1:0]  ctl_dcdl_late,
    input [Nctl_dcdl_fine-1:0]  ctl_dcdl_early,
    input alws_on,
    //input clk_async,
    //input sel_clk_TDC,
    input [Nctl_TDC-1:0] ctl_dcdl,
    //input en_pm,
    //input [1:0] sel_pm_sign,
    //input [1:0] sel_pm_in,
    input en_TDC_phase_reverse,
    input retimer_mux_ctrl_1,
    input retimer_mux_ctrl_2,
	input [1:0] sel_PFD_in,
	input sign_PFD_clk_in,
		
    output clk_adder,
    output en_sync_out,
    output del_out,
    output sign_out,
    output [Nadc-1:0] adder_out,
    //output [19:0] pm_out,
    output arb_out_dmm
); 

    wire [(2**Nctl_TDC)-2:0] thm_ctl_dcdl;
    wire [(2**Nctl_v2t)-2:0] thm_ctl_v2t_n;
    wire [(2**Nctl_v2t)-2:0] thm_ctl_v2t_p;
    wire [(2**Nadc)-2:0] ff_out;
    wire [(Nadc-1):0] adder_out_pre;
    wire sign_out_pre;
    reg en_TDC_phase_reverse_sampled;
    reg clk_TDC_phase_reverse;

    bin2thm #(.Nbit(5)) ib2tn (
        .bin(ctl_v2t_n),
        .thm(thm_ctl_v2t_n)
    );

    bin2thm #(.Nbit(5)) ib2tp (
        .bin(ctl_v2t_p),
        .thm(thm_ctl_v2t_p)
    );

    bin2thm #(.Nbit(5)) ib2t_tdc (
        .bin(ctl_dcdl),
        .thm(thm_ctl_dcdl)
    );

    V2T iV2Tp_dont_touch (
        .clk_v2t_e(clk_v2t_e),
        .clk_v2t_eb(clk_v2t_eb),
        .clk_v2t(clk_v2t),
        .clk_v2tb(clk_v2tb),
        .clk_v2t_l(clk_v2t_l),
        .clk_v2t_lb(clk_v2t_lb),
        .clk_v2t_gated(clk_v2t),
        .clk_v2tb_gated(clk_v2tb),
        .Vin(VinP),
        .Vcal(Vcal),
        .ctl({1'b1, thm_ctl_v2t_p[30:0]}),
        .v2t_out(v2t_out_p)
    );

    V2T iV2Tn_dont_touch (
        .clk_v2t_e(clk_v2t_e),
        .clk_v2t_eb(clk_v2t_eb),
        .clk_v2t(clk_v2t),
        .clk_v2tb(clk_v2tb),
        .clk_v2t_l(clk_v2t_l),
        .clk_v2t_lb(clk_v2t_lb),
        .clk_v2t_gated(clk_v2t),
        .clk_v2tb_gated(clk_v2tb),
        .Vin(VinN),
        .Vcal(Vcal),
        .ctl({1'b1, thm_ctl_v2t_n[30:0]}),
        .v2t_out(v2t_out_n)
    );

    V2T_clock_gen iV2T_clock_gen (
        .clk_in(clk_in),
        .rstn(rstb),
        .en_slice(en_slice),
        .en_sync_in(en_sync_in),
        .ctl_dcdl_late(ctl_dcdl_late),
        .ctl_dcdl_early(ctl_dcdl_early),
        .init(init[1:0]),
        .alws_on(alws_on),

        .clk_v2t_e(clk_v2t_e),
        .clk_v2t_eb(clk_v2t_eb),
        .clk_v2t(clk_v2t),
        .clk_v2tb(clk_v2tb),
        .clk_v2t_l(clk_v2t_l),
        .clk_v2t_lb(clk_v2t_lb),
        .en_sync_out(en_sync_out),
        .clk_adder(clk_adder)
    );

    PFD iPFD (
        .Tout(pfd_out),
        .sign(sign),
        .rstb(rstb),
        .TinN(PFD_TinN),
        .TinP(PFD_TinP),
        .arb_out_dmm(arb_out_dmm)
    );

    //assign clk_TDC = sel_clk_TDC ? clk_async : clk_adder;

    dcdl_coarse idcdl_coarse (
        .thm(thm_ctl_dcdl),
        .out(clk_TDC),
        .in(clk_adder)
    );

    TDC_delay_chain_PR idchain (
        .Tin(pfd_out),
        .del_out(del_out),
        .ff_out(ff_out),
        .clk(clk_TDC),
        .en_phase_reverse(en_TDC_phase_reverse),
        .clk_phase_reverse(clk_TDC_phase_reverse)
    );

    always @(posedge clk_adder or negedge rstb) begin
        if(!rstb) begin
            en_TDC_phase_reverse_sampled <= 0;
            clk_TDC_phase_reverse <=0;
        end else begin
            en_TDC_phase_reverse_sampled <= en_TDC_phase_reverse;
            clk_TDC_phase_reverse <= en_TDC_phase_reverse_sampled;
        end
    end

    wallace_adder iadder (
        .d_out(adder_out_pre),
        .d_in(ff_out),
        .sign_out(sign_out_pre),
        .sign_in(sign),
        .clk(clk_adder)
    );

    adc_retimer #(
        .Nadc(Nadc)
    ) iretimer (
        .clk_retimer(clk_retimer),
        .in_data(adder_out_pre),
        .in_sign(sign_out_pre),
        .out_data(adder_out),
        .out_sign(sign_out),
        .mux_ctrl_1(retimer_mux_ctrl_1),
        .mux_ctrl_2(retimer_mux_ctrl_2)
    );

x_or ix_or_PFD_clk_in (.in1(clk_adder), .in2(sign_PFD_clk_in), .out(PFD_clk_in));
mux_fixed imux_PFD_TinP_dont_touch (.in0(v2t_out_p), .in1(PFD_clk_in), .sel(sel_PFD_in[0]), .out(PFD_TinP)); 
mux_fixed imux_PFD_TinN_dont_touch (.in0(v2t_out_n), .in1(PFD_clk_in), .sel(sel_PFD_in[1]), .out(PFD_TinN)); 

/* 
   mux_fixed ipm_mux1_dont_touch (
        .in0(clk_v2t),
        .in1(v2t_out_p),
        .sel(sel_pm_in[1]),
        .out(ph_ref)
    );

    mux_fixed ipm_mux0_dont_touch (
        .in0(clk_in),
        .in1(v2t_out_n),
        .sel(sel_pm_in[0]),
        .out(ph_in)
    );

    phase_monitor iPM (
        .sel_sign(sel_pm_sign),
        .ph_in(ph_in),
        .ph_ref(ph_ref),
        .pm_out(pm_out),
        .clk_async(clk_async),
        .en_pm(en_pm)
    );
*/
endmodule
