
module gate_size_test (
// stochastic_adc_PR
input clk_in, 
input clk_div_in, 
input one,
input zero,
input [1:0] zero_2b,
input [2:0] zero_3b,
output v2t_out, 
output v2t_outb,
// phase_interpolator
input chain_in,
output arb_out
// phase_monitor
// arbiter

);

// synopsys dc_script_begin 
// set_dont_touch {*out* *mid* *clk* chain_in_b}
// synopsys dc_script_end 

//[critical gates for stochastic_adc_PR]
//(V2T_clock_gen)-----------------------------------------------------------------------------------------------------
ff_cn_sn_rn_fixed ifff(.D(clk_div_in), .CPN(clk_in), .Q(clk_div_sampled), .CDN(one), .SDN(one));
inv_v2t_0_fixed iinv(.in(clk_div_in), .out(clk_div_in_b));
mux_fixed imux_dont_touch(.in0(clk_div_sampled), .in1(1'b0), .sel(1'b0), .out(clk_div_sampled_d));
n_or_v2t_fixed in_or (.in1(clk_div_in_b), .in2(clk_div_sampled_d), .out(nor_out));
//(single to differential path)-----------------------------------------------------------------------------------------------------
inv_v2t_1_fixed iV2T_buffer_n_inv1 (.in(nor_out), .out(mid_n_1));
inv_v2t_2_fixed iV2T_buffer_n_inv2 (.in(mid_n_1), .out(mid_n_2));
inv_v2t_3_fixed iV2T_buffer_n_inv3 (.in(mid_n_2), .out(v2t_outb));
inv_v2t_4_fixed iV2T_buffer_p_inv1 (.in(nor_out), .out(mid_p_1));
inv_v2t_5_fixed iV2T_buffer_p_inv2 (.in(mid_p_1), .out(v2t_out));
//-----------------------------------------------------------------------------------------------------

//[critical gates for phase_interpolator]
//(PI_delay_chain)-----------------------------------------------------------------------------------------------------
inv iinv_in_test(.in(chain_in), .out(chain_in_b));
inv_PI_1_fixed iinv_PI_1_test(.in(chain_in_b), .out(mid));
inv_PI_2_fixed iinv_PI_2_test(.in(mid), .out(chain_out_1));
mux_fixed imux_1_load_dont_touch (.in0(chain_out_1), .in1(zero), .out(), .sel(zero) );
mux_fixed imux_2_load_dont_touch (.in0(chain_out_1), .in1(zero), .out(), .sel(zero) );
mux_fixed imux_3_load_dont_touch (.in0(chain_out_1), .in1(zero), .out(), .sel(zero) );
inv iinv_load_test (.in(chain_out_1), .out(chain_out_1_b));
//(mux network)-----------------------------------------------------------------------------------------------------
mux_fixed imux_test_dont_touch (.in0(chain_in), .in1(zero), .out(mux_out), .sel(zero) );
tri_buff_fixed itri_buff_test(.in(mux_out), .out(buff_out), .en(one));
mux4_fixed imux4_1_test_dont_touch (.in({zero_3b, buff_out}), .out(mux4_out_1), .sel(zero_2b));
//(mux4_gf)-----------------------------------------------------------------------------------------------------
//mux4_gf imux4_gf_test (.out(mux4_gf_out), .in({zero_3b, chain_in}), .sel(zero_2b), .en_gf(zero) );
//mux4_fixed imux4_load_dont_touch (.in({zero_3b, mux4_gf_out}), .out(), .sel(zero_2b));
//-----------------------------------------------------------------------------------------------------

//[critical gates for arbiter]
n_and_arb_fixed inand_1_test (.in1(chain_in), .in2(one), .out(nand_out));
inv_arb_fixed iinv_arb_test (.in(nand_out), .out(nand_out_b));
mux_fixed imux_5_load_dont_touch (.in0(nand_out_2_b), .in1(zero), .out(), .sel(zero) );

//[critical gates for phase_monitor]

//[critical gates for biasgen]

endmodule

