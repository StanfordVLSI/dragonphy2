/********************************************************************
filename: calib_hist_measure.sv

Description: 
ADC calibration block. To be synthesized.
Assumptions:

Todo:

********************************************************************/

`default_nettype none

module calib_hist_measure import const_pack::*; (
    input wire logic rstb,
    input wire logic clk,
    input wire logic update,    // synced to clk
    input wire logic signed [Nadc-1:0] din,
    input wire logic signed [Nadc-1:0] din_avg,
    
    input wire logic [Nrange-1:0] Nbin,
    input wire logic [Nrange-1:0] DZ,
    output reg  [2**Nrange-1:0] hist_center,
    output reg  [2**Nrange-1:0] hist_side,
    output reg signed [1:0] hist_comp_out
);


// wires, registers
reg [2**Nrange-1:0] cnt_center;
reg [2**Nrange-1:0] cnt_left;
reg [2**Nrange-1:0] cnt_right;

reg signed [2**Nrange-1:0] hist_diff;

wire signed [Nadc-1:0] th_l1;
wire signed [Nadc-1:0] th_l2;
wire signed [Nadc-1:0] th_r1;
wire signed [Nadc-1:0] th_r2;
wire signed [Nrange:0] DZ_l;
wire signed [Nrange:0] DZ_r;
wire [2**Nrange-1:0] cnt_center_pre1, cnt_center_pre;
wire [2**Nrange-1:0] cnt_left_pre1, cnt_left_pre;
wire [2**Nrange-1:0] cnt_right_pre1, cnt_right_pre;
reg signed [1:0] hist_comp_out_pre;

//initial begin 
//cnt_center=0;
//cnt_left=0;
//cnt_right=0;
//hist_center=0;
//hist_side=0;
//hist_diff=0;
//end

assign th_l1 = din_avg - Nbin - 1;
assign th_l2 = din_avg - (Nbin*3+1) - 1;
assign th_r1 = din_avg + Nbin + 1;
assign th_r2 = din_avg + (Nbin*3+1) +1;
assign DZ_l  = -1*2**DZ;
assign DZ_r  = 2**DZ;


assign cnt_center_pre = ((th_l1 < din) && (din < th_r1))  ? cnt_center + 1 : cnt_center;
assign cnt_left_pre   = ((th_l2 < din) && (din < th_l1+1))? cnt_left + 1 : cnt_left;
assign cnt_right_pre  = ((th_r1-1 < din) && (din < th_r2))? cnt_right + 1 : cnt_right;
assign cnt_center_pre1 = update ? '0 : cnt_center_pre;
assign cnt_left_pre1 = update ? '0 : cnt_left_pre;
assign cnt_right_pre1 = update ? '0 : cnt_right_pre;

always_comb begin
    if (!rstb) begin
		hist_center =0;
		hist_side =0;
		hist_diff =0;
    end
    else begin
		hist_center = cnt_center;
		hist_side = (cnt_left+cnt_right) >> 1;
		hist_diff = (hist_center - hist_side);
    end
	if (hist_center == 0 && hist_side ==0) hist_comp_out_pre =1;
	else if (hist_diff > DZ_r) hist_comp_out_pre =-1;
	else if (hist_diff < DZ_l) hist_comp_out_pre =1;
	else  hist_comp_out_pre =0;
end


always @(posedge clk, negedge rstb) 
    if (!rstb) begin
		cnt_center <= '0;
		cnt_left <= '0;
		cnt_right <= '0;
    end
    else begin
		cnt_center <= cnt_center_pre1;
		cnt_left <= cnt_left_pre1;
		cnt_right <= cnt_right_pre1;
	end


always @(posedge clk) 
    hist_comp_out <= hist_comp_out_pre;

endmodule

`default_nettype wire
