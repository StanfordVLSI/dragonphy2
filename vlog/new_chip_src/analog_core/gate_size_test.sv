
module gate_size_test (input clk_in, input clk_div_in, input sel, input CDN, input SDN, output out, output outb);

// synopsys dc_script_begin 
// set_dont_touch {*out* *mid* *clk*}
// synopsys dc_script_end 

ff_cn_sn_rn_fixed ifff(.D(clk_div_in), .CPN(clk_in), .Q(clk_div_sampled), .CDN(CDN), .SDN(SDN));

inv_0_fixed iinv(.in(clk_div_in), .out(clk_div_in_b));
mux_fixed imux(.in0(clk_div_sampled), .in1(1'b0), .sel(sel), .out(clk_div_sampled_d));

n_or_fixed in_or (.in1(clk_div_in_b), .in2(clk_div_sampled_d), .out(nor_out));

inv_1_fixed iV2T_buffer_n_inv1 (.in(nor_out), .out(mid_n_1));
inv_2_fixed iV2T_buffer_n_inv2 (.in(mid_n_1), .out(mid_n_2));
inv_3_fixed iV2T_buffer_n_inv3 (.in(mid_n_2), .out(outb));

inv_4_fixed iV2T_buffer_p_inv1 (.in(nor_out), .out(mid_p_1));
inv_5_fixed iV2T_buffer_p_inv2 (.in(mid_p_1), .out(out));

endmodule


