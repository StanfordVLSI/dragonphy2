`include "svreal.sv"

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
    // signals use for external I/O
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] dt_req;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] emu_dt;
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) logic emu_rst;

    // format for emu_dt / dt_req
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // set maximum value for timestep
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    `ASSIGN_CONST_REAL(((2.0**((`DT_WIDTH)-1))-1.0)*2.0**(`DT_EXPONENT), dt_req_max);

    // instantiate MSDSL model, passing through format information
    clk_delay_core #(
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT),
        `PASS_REAL(dt_req_max, dt_req_max)
    ) clk_delay_core_i (
        // main I/O: delay code, clock in/out values
        .code(ctl),
        .clk_i_val(clk_in),
        .clk_o_val(clk_out_slice),
        // timestep control: DT request and response
        .dt_req(dt_req),
        .emu_dt(emu_dt),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // additional input: maximum timestep
        .dt_req_max(dt_req_max)
    );

    // outputs that are not modeled
    assign cal_out = 0;
    assign clk_out_sw = 0;
    assign del_out = 0;
    assign Qperi = 0;
    assign max_sel_mux = 0;
    assign cal_out_dmm = 0;
    assign pm_out = 0;
endmodule

