module V2T_clock_gen #(
    parameter Ndiv = 2,
    parameter Nctl_dcdl_fine =2
) (
    input clk_in,
    input rstn,
    input en_slice,
    input en_sync_in,

    input [Nctl_dcdl_fine-1:0] ctl_dcdl_early,
    input [Nctl_dcdl_fine-1:0] ctl_dcdl_late,
    input [Ndiv-1:0] init,
    input alws_on,

    output clk_v2t_e,
    output clk_v2t_eb,
    output clk_v2t,
    output clk_v2tb,
    output clk_v2t_l,
    output clk_v2t_lb,

    output reg en_sync_out,
    output clk_adder
);
    reg [Ndiv-1:0] count;
    reg clk_div;
    reg clk_div_sampled;

    logic en_sync;
    logic alws_onb;
    logic clk_rstb, clk_pstb;

    assign alws_onb = ~alws_on;
    assign en_sync = en_sync_in & en_slice;
    assign clk_div = count[Ndiv-1];

    always @(negedge clk_in or negedge rstn) begin
        if (!rstn) begin
            en_sync_out <= 0;
        end else begin
            en_sync_out <= en_sync_in;
        end
    end

    
	always @(negedge clk_in or negedge en_sync or negedge alws_onb) begin
    	if (!en_sync) begin
    	    count <= init;
    	end else if (!alws_onb) begin
    	    count <= 2'b11;
    	end else begin
    	    count <= count+1;
        end
    end

    assign clk_pstb = en_slice;
    assign clk_rstb = ~en_slice|(alws_onb);

    V2T_buffer iV2T_buffer (
        .clk_in(clk_in),
        .clk_div(clk_div),
        .ctl_dcdl_early(ctl_dcdl_early),
        .ctl_dcdl_late(ctl_dcdl_late),
        .CDN(clk_rstb),
        .SDN(clk_pstb),
        .clk_v2t_e(clk_v2t_e),
        .clk_v2t_eb(clk_v2t_eb),
        .clk_v2t(clk_v2t),
        .clk_v2tb(clk_v2tb),
        .clk_v2t_l(clk_v2t_l),
        .clk_v2t_lb(clk_v2t_lb),
        .clk_divb(clk_adder)
    );
endmodule


