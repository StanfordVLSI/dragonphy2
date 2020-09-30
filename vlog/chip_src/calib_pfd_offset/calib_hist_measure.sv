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

    output wire logic [((2**Nrange)-1):0] hist_center,
    output wire logic [((2**Nrange)-1):0] hist_side,
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
            cnt_left <= 0;
            cnt_center <= 0;
            cnt_right <= 0;
        end else begin
            cnt_left <= cnt_left_pre;
            cnt_center <= cnt_center_pre;
            cnt_right <= cnt_right_pre;
        end
    end

    /////////////////////////
    // average side counts //
    /////////////////////////

    logic [(2**Nrange):0] side_sum;  // note the extra bit

    assign side_sum = cnt_left + cnt_right;
    assign hist_side = side_sum >> 1;

    /////////////////////
    // side vs. center //
    /////////////////////

    logic signed [(2**Nrange):0] hist_diff; // note the extra bit

    assign hist_center = cnt_center;
    assign hist_diff = hist_center - hist_side;

    ///////////////
    // dead zone //
    ///////////////

    logic signed [(2**Nrange):0] DZ_l;
    logic signed [(2**Nrange):0] DZ_r;

    assign DZ_l = -(1<<DZ);
    assign DZ_r = +(1<<DZ);

    //////////////
    // comp_out //
    //////////////

    always @(*) begin
        if ((hist_center==0) && (hist_side==0)) begin
            // in this case, no points fell in the center or side bins,
            // so the PFD offset likely needs to be increased
            hist_comp_out = +1;
        end else if (hist_diff > DZ_r) begin
            // in this case, more points fell in the center bin, so
            // the PFD offset likely needs to be decreased
            hist_comp_out = -1;
        end else if (hist_diff < DZ_l) begin
            // in this case, more points fell in the side bins, so
            // the PFD offset likely needs to be increased
            hist_comp_out = +1;
        end else begin
            // otherwise there is not much difference between the
            // center and side bins, so the PFD offset estimate
            // is held constant
            hist_comp_out = 0;
        end
    end

endmodule

`default_nettype wire
