
module V2T_clock_gen #(
parameter Ndiv = 2,
parameter Nctl_dcdl_fine =2
)(
input clk_in,
input rstn,
input en_slice,
input en_sync_in,
//input en_sw_test,
//input en_clk_v2t_next,
input [Nctl_dcdl_fine-1:0] ctl_dcdl_early,
input [Nctl_dcdl_fine-1:0] ctl_dcdl_late,
input [Ndiv-1:0] init,
input alws_on,

output reg clk_v2t_e,
output reg clk_v2t_eb,
output reg clk_v2t,
output reg clk_v2tb,
output reg clk_v2t_l,
output reg clk_v2t_lb,
//output reg clk_v2t_gated,
//output reg clk_v2tb_gated,

//output reg clk_v2t_next,
output reg en_sync_out,
//output reg clk_div
output reg clk_adder
);

reg [Ndiv-1:0] count;
reg clk_div;
reg clk_div_sampled;

logic en_sync;
logic alws_onb;
logic clk_rstb, clk_pstb;
//logic Q_clk_e, Q_clk, Q_clk_l;
//logic clk_div_sampled_d, clk_div_sampled_dd;

assign alws_onb = ~alws_on;
assign en_sync = en_sync_out & en_slice;
assign clk_div = count[Ndiv-1];


//assign clk_adder = ~clk_div;


//synopsys translate_off
initial begin
count <='0;
end
//synopsys translate_on

always @(negedge clk_in or negedge rstn) begin
	if(!rstn) en_sync_out <= 0;
	else en_sync_out <= en_sync_in;
end

always @(negedge clk_in or negedge en_sync or negedge alws_onb) begin
	if(!en_sync) count <= init;
	else if(!alws_onb) count <= 2'b11;
	else count <= count+1;
end



//always @(negedge clk_in or negedge clk_rstb or negedge clk_pstb) begin
//    if(!clk_rstb) clk_div_sampled <= 0;
//    else if(!clk_pstb) clk_div_sampled <= 1;
//    //else clk_div_sampled <= clk_div;
//    else clk_div_sampled <= clk_div;
//end

assign clk_pstb = en_slice;
assign clk_rstb = ~en_slice|(alws_onb);

/*
dcdl_fine idcdl_fine1_dont_touch (.in(clk_div_sampled), .ctl(ctl_dcdl_early), .out(clk_div_sampled_d), .en(1'b1), .disable_state(1'b0));
dcdl_fine idcdl_fine2_dont_touch (.in(clk_div_sampled_d), .ctl(ctl_dcdl_late), .out(clk_div_sampled_dd), .en(1'b1), .disable_state(1'b0));

ff clk_div_sampled_reg_dont_touch (.D(clk_div), .CPN(clk_in), .Q(clk_div_sampled), .CDN(clk_rstb), .SDN(clk_pstb));

n_or in_or1_dont_touch(.in1(~clk_div), .in2(clk_div_sampled), .out(nor_out1));
n_or in_or2_dont_touch(.in1(~clk_div), .in2(clk_div_sampled_d), .out(nor_out2));
n_or in_or3_dont_touch(.in1(~clk_div), .in2(clk_div_sampled_dd), .out(nor_out3));

V2T_buffer iV2T_buffer1_dont_touch(.in(nor_out1), .out(clk_v2t_e), .outb(clk_v2t_eb));
V2T_buffer iV2T_buffer2_dont_touch(.in(nor_out2), .out(clk_v2t), .outb(clk_v2tb));
V2T_buffer iV2T_buffer3_dont_touch(.in(nor_out3), .out(clk_v2t_l), .outb(clk_v2t_lb));
*/

V2T_buffer iV2T_buffer_dont_touch (.clk_in(clk_in), .clk_div(clk_div), .ctl_dcdl_early(ctl_dcdl_early), .ctl_dcdl_late(ctl_dcdl_late), .CDN(clk_rstb), .SDN(clk_pstb), .clk_v2t_e(clk_v2t_e), .clk_v2t_eb(clk_v2t_eb), .clk_v2t(clk_v2t), .clk_v2tb(clk_v2tb), .clk_v2t_l(clk_v2t_l), .clk_v2t_lb(clk_v2t_lb), .clk_divb(clk_adder));


//assign clk_v2t_e = ~(~(clk_div)|clk_div_sampled);
//assign clk_v2t = ~(~(clk_div)|clk_div_sampled_d);
//assign clk_v2t_l = ~(~(clk_div)|clk_div_sampled_dd);

//assign clk_v2t_eb = ~clk_v2t_e;
//assign clk_v2tb = ~clk_v2t;
//assign clk_v2t_lb = ~clk_v2t_l;

//assign clk_v2t_gated = (clk_v2t&~en_sw_test);
//assign clk_v2tb_gated = ~clk_v2t_gated;
//assign clk_v2t_next = clk_v2t&en_clk_v2t_next; 

endmodule


