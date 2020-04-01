
module V2T_buffer_test (input clk_in, input clk_div_in, input CDN, input SDN, output out, output outb);

ff ifff(.D(clk_div_in), .CPN(clk_in), .Q(clk_div_sampled), .CDN(CDN), .SDN(SDN));

n_or in_or (.in1(~clk_div_in), .in2(clk_div_sampled), .out(nor_out));

inv iV2T_buffer_n_inv2 (.in(nor_out), .out(mid_n_1));
inv iV2T_buffer_n_inv1 (.in(mid_n_1), .out(mid_n_2));
inv iV2T_buffer_n_inv0 (.in(mid_n_2), .out(outb));

inv iV2T_buffer_p_inv1 (.in(nor_out), .out(mid_p_1));
inv iV2T_buffer_p_inv0 (.in(mid_p_1), .out(out));

endmodule


