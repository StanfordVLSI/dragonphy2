module phase_interpolator #( 
    parameter Nbit = 9,
    parameter Nctl_dcdl = 2,
    parameter Nunit = 32,
    parameter Nblender = 4
)(
    input rstb,
    input clk_in,
    input clk_async,
    input clk_cdr,
    input disable_state,
    input en_arb,
    input en_cal,
    input en_clk_sw,
    input en_delay,
    input en_ext_Qperi,
    input en_gf,
    input [Nbit-1:0]  ctl,
    input [Nctl_dcdl-1:0]  ctl_dcdl_sw,
    input [Nctl_dcdl-1:0]  ctl_dcdl_slice,
    input [Nunit-1:0]  inc_del,
    input [$clog2(Nunit)-1:0]  ext_Qperi,
    input [1:0] sel_pm_sign,
    input en_pm,

    output cal_out,
    output clk_out_slice,
    output clk_out_sw,
    output del_out,

    output [$clog2(Nunit)-1:0]  Qperi,
    output [$clog2(Nunit)-1:0]  max_sel_mux,
    output cal_out_dmm,
    output [19:0]  pm_out
);

    wire  [Nunit-1:0]  arb_out;
    wire  [(2**Nblender)-1:0]  thm_sel_bld;
    wire  [Nunit-1:0]  en_mixer;
    wire  [Nunit-1:0]  mclk;

    logic [3:0] sel_mux0;
    logic [3:0] sel_mux1;

    logic [1:0] sel_mux_1st_even [3:0];
    logic [1:0] sel_mux_1st_odd [3:0];
    logic [1:0] sel_mux_2nd_odd;
    logic [1:0] sel_mux_2nd_even;
    logic [1:0] ph_out;

    assign clk_in_gated = clk_in|~en_delay;
    assign ph_out_and = ph_out[0]&ph_out[1];

    inv_chain #(
        .Ninv(4)
    ) iinv_chain (
        .in(ph_out_and),
        .out(ph_out_d)
    );

    PI_delay_chain iPI_delay_chain_dont_touch (
        .arb_out(arb_out),
        .inc_del(inc_del),
        .en_mixer(en_mixer),
        .mclk_out(mclk),
        .en_arb(en_arb),
        .del_out(del_out),
        .clk_in(clk_in_gated)
    );

    mux_network imux_network (
        .en_gf(en_gf),
        .ph_in(mclk),
        .sel_mux_1st_even(sel_mux_1st_even),
        .sel_mux_1st_odd(sel_mux_1st_odd),
        .sel_mux_2nd_odd(sel_mux_2nd_odd),
        .sel_mux_2nd_even(sel_mux_2nd_even),
        .ph_out(ph_out)
    );

    phase_blender iphase_blender_dont_touch (
        .thm_sel_bld(thm_sel_bld),
        .ph_out(bld_out),
        .ph_in(ph_out)
    );

    arbiter iarbiter (
        .in1(ph_out[1]),
        .out(cal_out),
        .in2(ph_out[0]),
        .clk(ph_out_d),
        .out_dmm(cal_out_dmm)
    );

    dcdl_fine idcdl_fine0 (
        .disable_state(disable_state),
        .out(clk_out_sw),
        .en(en_clk_sw),
        .in(bld_out),
        .ctl(ctl_dcdl_sw)
    );

    dcdl_fine idcdl_fine1 (
        .disable_state(1'b0),
        .out(clk_out_slice),
        .en(1'b1),
        .in(bld_out),
        .ctl(ctl_dcdl_slice)
    );

    PI_local_encoder iPI_local_encoder (
        .rstb(rstb),
        .max_sel_mux(max_sel_mux),
        .thm_sel_bld(thm_sel_bld),
        .Qperi(Qperi),
        .en_mixer(en_mixer),
        .sel_mux_1st_even(sel_mux_1st_even),
        .sel_mux_1st_odd(sel_mux_1st_odd),
        .sel_mux_2nd_even(sel_mux_2nd_even),
        .sel_mux_2nd_odd(sel_mux_2nd_odd),
        .arb_out(arb_out),
        .clk_cdr(clk_cdr),
        .ctl(ctl),
        .en_ext_Qperi(en_ext_Qperi),
        .ext_Qperi(ext_Qperi)
    );

    phase_monitor iPM (
        .sel_sign(sel_pm_sign[1:0]),
        .ph_in(bld_out),
        .ph_ref(clk_in_gated),
        .pm_out(pm_out[19:0]),
        .clk_async(clk_async),
        .en_pm(en_pm)
    );
endmodule

