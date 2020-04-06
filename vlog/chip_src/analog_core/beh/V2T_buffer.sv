
module V2T_buffer #(
parameter Nctl_dcdl_fine = 2,
parameter buffer_delay = 40e-12
) (
input clk_in, 
input clk_div, 
input [Nctl_dcdl_fine-1:0] ctl_dcdl_early, 
input [Nctl_dcdl_fine-1:0] ctl_dcdl_late, 
input CDN, 
input SDN, 
output reg clk_v2t_e, 
output clk_v2t_eb, 
output reg clk_v2t, 
output clk_v2tb, 
output reg clk_v2t_l, 
output clk_v2t_lb, 
output clk_divb
);

assign clk_divb = ~clk_div;

assign nor_out1 = ~(clk_divb|clk_div_sampled); 
assign nor_out2 = ~(clk_divb|clk_div_sampled_d); 
assign nor_out3 = ~(clk_divb|clk_div_sampled_dd); 

assign clk_v2t_eb ~clk_v2t_e;
assign clk_v2tb ~clk_v2t;
assign clk_v2t_lb ~clk_v2t_l;

reg clk_div_sampled;

always @(posedge clk_in or negedge CDN or negedge SDN) begin
	if(!CDN) clk_div_sampled <=0;
	elseif(!SDN) clk_div_sampled <=1;
	else clk_div_sampled <= #(buffer_delay*1s) clk_div;
end 

dcdl_fine idcdl_fine1 (.in(clk_div_sampled), .ctl(ctl_dcdl_early), .out(clk_div_sampled_d), .en(1'b1), .disable_state(1'b0));
dcdl_fine idcdl_fine2 (.in(clk_div_sampled_d), .ctl(ctl_dcdl_late), .out(clk_div_sampled_dd), .en(1'b1), .disable_state(1'b0));

always @(nor_out1) clk_v2t_e <= #(buffer_delay*1s) not_out1;
always @(nor_out2) clk_v2t <= #(buffer_delay*1s) not_out2;
always @(nor_out3) clk_v2t_l <= #(buffer_delay*1s) not_out3;

endmodule


