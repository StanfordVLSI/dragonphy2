/********************************************************************
filename: calib_hist_measure.sv

Description: 
Implements a mini-histogram that is used to determine whether the
estimate of the PFD offset should be moved up or down.

********************************************************************/

`default_nettype none

module calib_hist_measure #(
    parameter integer Nadc=8,
    parameter integer Nrange=4
) (
    input wire logic rstb,
    input wire logic clk,
    input wire logic update,
    input wire logic signed [(Nadc-1):0] din,
    input wire logic signed [(Nadc-1):0] din_avg,
    input wire logic [(Nrange-1):0] Nbin,
    input wire logic [(Nrange-1):0] DZ,

    output reg [((2**Nrange)-1):0] hist_center,
    output reg [((2**Nrange)-1):0] hist_side,
    output reg signed [1:0] hist_comp_out
);

////////////////
// thresholds //
////////////////

logic signed [(Nadc-1):0] th_l2;
logic signed [(Nadc-1):0] th_l1;
logic signed [(Nadc-1):0] th_r1;
logic signed [(Nadc-1):0] th_r2;

assign th_l2 = din_avg - ((Nbin*3)+1) - 1;
assign th_l1 = din_avg - Nbin - 1;
assign th_r1 = din_avg + Nbin + 1;
assign th_r2 = din_avg + ((Nbin*3)+1) + 1;

////////////////
// comparison //
////////////////

logic is_left;
logic is_center;
logic is_right;

assign is_left = (th_l2 < din) && (din <= th_l1);
assign is_center = (th_l1 < din) && (din < th_r1);
assign is_right = (th_r1 <= din) && (din < th_r2);

//////////////
// counting //
//////////////

logic [((2**Nrange)-1):0] cnt_left;
logic [((2**Nrange)-1):0] cnt_center;
logic [((2**Nrange)-1):0] cnt_right;

logic [((2**Nrange)-1):0] cnt_left_pre;
logic [((2**Nrange)-1):0] cnt_center_pre;
logic [((2**Nrange)-1):0] cnt_right_pre;

assign cnt_left_pre   = update ? is_left   : (cnt_left   + is_left);
assign cnt_center_pre = update ? is_center : (cnt_center + is_center);
assign cnt_right_pre  = update ? is_right  : (cnt_right  + is_right);

always @(posedge clk or negedge rstb) begin
    if (!rstb) begin
        cnt_left <= '0;
        cnt_center <= '0;
        cnt_right <= '0;
    end else begin
        cnt_left <= cnt_left_pre;
        cnt_center <= cnt_center_pre;
        cnt_right <= cnt_right_pre;
    end
end

/////////////////////
// side vs. center //
/////////////////////

logic signed [((2**Nrange)-1):0] hist_diff;

always @(*) begin
    if (!rstb) begin
		hist_center = 0;
		hist_side = 0;
		hist_diff = 0;
    end else begin
		hist_center = cnt_center;
		hist_side = (cnt_left + cnt_right) >> 1;
		hist_diff = (hist_center - hist_side);
    end
end

///////////////
// dead zone //
///////////////

logic signed [Nrange:0] DZ_l;
logic signed [Nrange:0] DZ_r;

assign DZ_l = -(1<<DZ);
assign DZ_r = +(1<<DZ);

//////////////
// comp_out //
//////////////

logic signed [1:0] hist_comp_out_pre;

always @(*) begin
	if ((hist_center==0) && (hist_side==0)) begin
	    hist_comp_out_pre = +1;  // TODO: why isn't this "0"?
	end else if (hist_diff > DZ_r) begin
	    hist_comp_out_pre = -1;
	end else if (hist_diff < DZ_l) begin
	    hist_comp_out_pre = +1;
	end else begin
	    hist_comp_out_pre = 0;
	end
end

always @(posedge clk) begin
    hist_comp_out <= hist_comp_out_pre;
end

endmodule

`default_nettype wire
