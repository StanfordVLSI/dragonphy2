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
    input [Ndiv-1:0]  init,
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
    output en_sync_out,
    output del_out,
    output sign_out,
    output [Nadc-1:0] adder_out,
    output [19:0] pm_out,
    output arb_out_dmm
); 

    assign clk_adder = 0;
    assign en_sync_out = 0;
    assign del_out = 0;
    assign sign_out = 0;
    assign adder_out = 0;
    assign pm_out = 0;
    assign arb_out_dmm = 0;

endmodule

