module phase_interpolator #( 
    parameter Nbit = 9,
    parameter Nctl_dcdl = 2,
    parameter Nunit = 32,
    parameter Nblender = 4
)(
    input rstb,
    input clk_in,
    input clk_async,
    input clk_encoder,
    input disable_state,
    input en_arb,
    input en_cal,
    input en_clk_sw,
    input en_delay,
    input en_ext_Qperi,
    input en_gf,
    input ctl_valid,
    input [Nbit-1:0]  ctl,
    input [Nctl_dcdl-1:0] ctl_dcdl_sw,
    input [Nctl_dcdl-1:0] ctl_dcdl_slice,
    input [Nctl_dcdl-1:0] ctl_dcdl_clk_encoder,
    input [Nunit-1:0]  inc_del,
    input [$clog2(Nunit)-1:0] ext_Qperi,
    input [1:0] sel_pm_sign,
    input en_pm,

    output cal_out,
    output clk_out_slice,
    output clk_out_sw,
    output del_out,

    output [$clog2(Nunit)-1:0] Qperi,
    output [$clog2(Nunit)-1:0] max_sel_mux,
    output cal_out_dmm,
    output [19:0]  pm_out
);

    assign cal_out = 0;
    assign clk_out_slice = 0;
    assign clk_out_sw = 0;
    assign del_out = 0;

    assign Qperi = 0;
    assign max_sel_mux = 0;
    assign cal_out_dmm = 0;
    assign pm_out = 0;

endmodule

