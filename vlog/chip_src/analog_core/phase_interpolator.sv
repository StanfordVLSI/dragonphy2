module phase_interpolator #( 
    parameter Nbit = 9,
    parameter Nctl_dcdl = 2,
    parameter Nunit = 32,
    parameter Nblender = 4
)(
    input rstb, // Reset
    input clk_in, // Input clk
    input clk_async, // For Linearity measurement of the PI, 0 for unuse
    input clk_encoder, // Control logic clk input, must have (any clock signal)
    input disable_state, // GND it for TX
    input en_arb, // GND it for TX
    input en_cal, // Calibration for non-monotonic transfer characteristic
    input en_clk_sw, // Enable for ADC interleaving switch, same as the clk_out_slice, can be grounded if no need
    input en_delay, // Always on, enable to delay chain, for power measurement puropose
    input en_ext_Qperi, // External quantization period
    input en_gf, // enable for Glitch free operation of PI
    input ctl_valid, // a valid window singal to avoid glitches
    input [Nbit-1:0]  ctl, // output phase control
    input [Nctl_dcdl-1:0]  ctl_dcdl_sw, // final dealy fine tuneing for clk_sw
    input [Nctl_dcdl-1:0]  ctl_dcdl_slice, // final dealy fine tuneing for clk_slice
    input [Nctl_dcdl-1:0]  ctl_dcdl_clk_encoder, // Prevention for meta-stability of code transition
    input [Nunit-1:0]  inc_del, // calibrate the delay mismatch
    input [Nunit-1:0]  en_unit, // AND gate delay cell, for power saving
    input [$clog2(Nunit)-1:0]  ext_Qperi, // External quantized period, GND it if not used
    input [1:0] sel_pm_sign, // Phase Monitor rising edge to falling edge or vice versa
    input en_pm, // Enable the phase monitor

    output cal_out, // No need for TX, floating 
    output clk_out_slice, // Main clk out
    output clk_out_sw, // Secondary clk out
    output del_out, // Monitor for rising/falling (nmos/pmos) mismatch

    output [$clog2(Nunit)-1:0]  Qperi, // No need for TX, floating
    output [$clog2(Nunit)-1:0]  max_sel_mux, // No need for TX, floating
    output cal_out_dmm, // No need for TX, floating
    output [19:0]  pm_out // No need for TX, floating
);

	//synopsys dc_script_begin
	//set_dont_touch {clk_in_mid* mclk* ph_out*}
	//synopsys dc_script_end
    
	wire  [Nunit-1:0]  arb_out;
    wire  [(2**Nblender)-1:0]  thm_sel_bld;
    wire  [Nunit-1:0]  en_mixer;
    wire  [Nunit-1:0]  mclk;

	reg [2**Nblender-1:0] thm_sel_bld_sampled;	
	reg [2**Nblender-1:0] thm_sel_bld_sampled_d;	

    logic [1:0] sel_mux_1st_even [3:0];
    logic [1:0] sel_mux_1st_odd [3:0];
    logic [1:0] sel_mux_2nd_odd;
    logic [1:0] sel_mux_2nd_even;
    logic [1:0] ph_out;

	a_nd ia_nd_ph_out(.in1(ph_out[0]), .in2(ph_out[1]), .out(and_ph_out)); 
	
	logic clk_in_gated;
	assign clk_in_gated = ~(en_delay & clk_in); 
	inv iinv_buff2 (.in(clk_in_gated), .out(clk_in_buff));
	
    inv_chain #(
        .Ninv(4)
    ) iinv_chain (
        .in(and_ph_out),
        .out(and_ph_out_d)
    );

    PI_delay_chain iPI_delay_chain_dont_touch (
        .arb_out(arb_out),
        .inc_del(inc_del),
        .en_unit(en_unit),
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

	always @(posedge and_ph_out_d or negedge rstb) begin
		if (!rstb) thm_sel_bld_sampled <=0;
		else begin
			thm_sel_bld_sampled <= thm_sel_bld;
			thm_sel_bld_sampled_d <= thm_sel_bld_sampled;
		end
	end 
	
    arbiter iarbiter (
        .in1(ph_out[1]),
        .out(cal_out),
        .in2(ph_out[0]),
        .clk(and_ph_out_d),
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
    
	dcdl_fine idcdl_fine2 (
        .disable_state(1'b0),
        .out(clk_encoder_d),
        .en(1'b1),
        .in(clk_encoder),
        .ctl(ctl_dcdl_clk_encoder)
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
        .clk_encoder(clk_encoder_d),
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

