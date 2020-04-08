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
input Vcal, 
input rstb,
//input clk_v2t_prev, 
input en_slice, 
//input en_sw_test, 
input en_sync_in, 
//input en_clk_v2t_next, 
input [Nctl_v2t-1:0]  ctl_v2t_n,
input [Nctl_v2t-1:0]  ctl_v2t_p,
input [Ndiv-1:0]  init,
input [Nctl_dcdl_fine-1:0]  ctl_dcdl_late,
input [Nctl_dcdl_fine-1:0]  ctl_dcdl_early,
input alws_on,
input clk_async,
input sel_clk_TDC,
input [Nctl_TDC-1:0] ctl_dcdl,
input en_pm,
input [1:0] sel_pm_sign,
input [1:0] sel_pm_in,
//input clk_TDC_phase_reverse,
input en_TDC_phase_reverse,

output clk_adder, 
//output clk_v2t_next, 
output en_sync_out,
output del_out,
output sign_out,
output [Nadc-1:0] adder_out,
output [19:0] pm_out,
output arb_out_dmm
); 


wire  [(2**Nctl_TDC)-2:0]  thm_ctl_dcdl;
wire  [(2**Nctl_v2t)-2:0]  thm_ctl_v2t_n;
wire  [(2**Nctl_v2t)-2:0]  thm_ctl_v2t_p;
wire  [(2**Nadc)-2:0] ff_out;
reg en_TDC_phase_reverse_sampled;
reg clk_TDC_phase_reverse;

bin2thm_5b  ib2tn ( .bin(ctl_v2t_n), .thm(thm_ctl_v2t_n) );
bin2thm_5b  ib2tp ( .bin(ctl_v2t_p), .thm(thm_ctl_v2t_p) );
bin2thm_5b  ib2t_tdc (  .bin(ctl_dcdl), .thm(thm_ctl_dcdl));


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
//.en_sw_test(en_sw_test), 
//.en_clk_v2t_next(en_clk_v2t_next), 
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
//.clk_v2t_gated(clk_v2t_gated), 
//.clk_v2tb_gated(clk_v2tb_gated), 
//.clk_v2t_next(clk_v2t_next), 
.en_sync_out(en_sync_out), 
.clk_adder(clk_adder)
);
PFD iPFD (  .Tout(pfd_out), .sign(sign), .rstb(rstb), .TinN(v2t_out_n), .TinP(v2t_out_p), .arb_out_dmm(arb_out_dmm));

assign clk_TDC = sel_clk_TDC ? clk_async:clk_adder;
dcdl_coarse  idcdl_coarse_dont_touch ( .thm(thm_ctl_dcdl), .out(clk_TDC_d), .in(clk_TDC) );
TDC_delay_chain_PR  idchain ( .Tin(pfd_out), .del_out(del_out), .ff_out(ff_out), .clk(clk_TDC_d), .en_phase_reverse(en_TDC_phase_reverse), .clk_phase_reverse(clk_TDC_phase_reverse));


always @(posedge clk_adder or negedge rstb) begin
if(!rstb) begin
en_TDC_phase_reverse_sampled <= 0;
clk_TDC_phase_reverse <=0;
end
else begin
en_TDC_phase_reverse_sampled <= en_TDC_phase_reverse;
clk_TDC_phase_reverse <= en_TDC_phase_reverse_sampled;
end
end


wallace_adder  iadder (  .d_out(adder_out), .d_in(ff_out), .sign_out(sign_out), .sign_in(sign), .clk(clk_adder));

mux ipm_mux1_dont_touch ( .in0(clk_v2t), .in1(v2t_out_p), .sel(sel_pm_in[1]), .out(ph_ref) );
mux ipm_mux0_dont_touch ( .in0(clk_in), .in1(v2t_out_n), .sel(sel_pm_in[0]), .out(ph_in) );
phase_monitor  iPM ( .sel_sign(sel_pm_sign), .ph_in(ph_in), .ph_ref(ph_ref), .pm_out(pm_out), .clk_async(clk_async), .en_pm(en_pm));

 endmodule

