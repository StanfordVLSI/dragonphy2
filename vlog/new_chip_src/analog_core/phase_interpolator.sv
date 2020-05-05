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

	//synopsys dc_script_begin
	//set_dont_touch {clk_in_mid* mclk* ph_out*}
	//synopsys dc_script_end
    
	wire  [Nunit-1:0]  arb_out;
    wire  [(2**Nblender)-1:0]  thm_sel_bld;
    wire  [Nunit-1:0]  en_mixer;
    wire  [Nunit-1:0]  mclk;

	reg [2**Nblender-1:0] thm_sel_bld_sampled;	

    logic [1:0] sel_mux_1st_even [3:0];
    logic [1:0] sel_mux_1st_odd [3:0];
    logic [1:0] sel_mux_2nd_odd;
    logic [1:0] sel_mux_2nd_even;
    logic [1:0] ph_out;

	a_nd ia_nd_clk_in(.in1(clk_in), .in2(en_delay), .out(clk_in_gated)); 
	a_nd ia_nd_ph_out(.in1(ph_out[0]), .in2(ph_out[1]), .out(ph_out_and)); 
	
	inv iinv_buff1 (.in(clk_in_gated), .out(clk_in_mid1));
	inv iinv_buff2 (.in(clk_in_mid1), .out(clk_in_buff));
	
    inv_chain #(
        .Ninv(4)
    ) iinv_chain_dont_touch (
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
        .clk_in(clk_in_buff)
    );

    mux_network imux_network_dont_touch (
        .en_gf(en_gf),
        .ph_in(mclk),
        .sel_mux_1st_even(sel_mux_1st_even),
        .sel_mux_1st_odd(sel_mux_1st_odd),
        .sel_mux_2nd_odd(sel_mux_2nd_odd),
        .sel_mux_2nd_even(sel_mux_2nd_even),
        .ph_out(ph_out)
    );

    phase_blender iphase_blender_dont_touch (
        .thm_sel_bld(thm_sel_bld_sampled),
        .ph_out(bld_out),
        .ph_in(ph_out)
    );

	always @(posedge bld_out or negedge rstb) begin
		if (!rstb) thm_sel_bld_sampled <=0;
		else thm_sel_bld_sampled <= thm_sel_bld;
	end 
	
    arbiter iarbiter (
        .in1(ph_out[1]),
        .out(cal_out),
        .in2(ph_out[0]),
        .clk(ph_out_d),
        .out_dmm(cal_out_dmm)
    );

    dcdl_fine idcdl_fine0_dont_touch (
        .disable_state(disable_state),
        .out(clk_out_sw),
        .en(en_clk_sw),
        .in(bld_out),
        .ctl(ctl_dcdl_sw)
    );

    dcdl_fine idcdl_fine1_dont_touch (
        .disable_state(1'b0),
        .out(clk_out_slice),
        .en(1'b1),
        .in(bld_out),
        .ctl(ctl_dcdl_slice)
    );

    PI_local_encoder iPI_local_encoder (
        .rstb(rstb),
        .ctl_valid(ctl_valid),
        .max_sel_mux(max_sel_mux),
        .thm_sel_bld(thm_sel_bld),
        .Qperi(Qperi),
        .en_mixer(en_mixer),
        .sel_mux_1st_even(sel_mux_1st_even),
        .sel_mux_1st_odd(sel_mux_1st_odd),
        .sel_mux_2nd_even(sel_mux_2nd_even),
        .sel_mux_2nd_odd(sel_mux_2nd_odd),
        .arb_out(arb_out),
        .clk_encoder(clk_encoder),
        .ctl(ctl),
        .en_ext_Qperi(en_ext_Qperi),
        .ext_Qperi(ext_Qperi)
    );

    phase_monitor iPM (
        .sel_sign(sel_pm_sign[1:0]),
        .ph_in(bld_out),
        .ph_ref(clk_in_buff),
        .pm_out(pm_out[19:0]),
        .clk_async(clk_async),
        .en_pm(en_pm)
    );
endmodule

