/********************************************************************
filename: adc_unfolding.sv

Description: 
Removes the PFD offset from ADC magnitude/sign outputs, producing
a signed integer as the output.  A histogram-based calibration
method is included; it is also possible to provide the estimate
of PFD offset externally.

Assumptions:
* The "update" signal pulses high once every 2**Navg cycles.
* The PFD offset is positive, falling within the range
  [0, (2**(Nadc-1))-1], which is [0, 127] when Nadc=8.

********************************************************************/

`default_nettype none

module adc_unfolding #(
    parameter integer Nadc=8,
    parameter integer Nrange=4
) (
    input wire logic clk,
    input wire logic rstb,
    input wire logic update,
    input wire logic [(Nadc-1):0] din,
    input wire logic sign_out,
	
    input wire logic en_pfd_cal,
    input wire logic en_ext_pfd_offset,
    input wire logic [(Nadc-1):0] ext_pfd_offset,
    input wire logic [(Nrange-1):0] Nbin,
    input wire logic [(Nrange-1):0] Navg,
    input wire logic [(Nrange-1):0] DZ,

	input wire logic flip_feedback,
	input wire logic en_ext_ave,
	input wire logic signed [(Nadc-1):0] ext_ave,

    output reg signed [(Nadc-1):0] dout,
    output reg signed [(Nadc-1):0] dout_avg,
    output reg signed [(Nadc+(2**Nrange)-1):0] dout_sum,
    output reg [((2**Nrange)-1):0] hist_center,
    output reg [((2**Nrange)-1):0] hist_side,
    output reg signed [(Nadc-1):0] pfd_offset
);

    ///////////////
    // averaging //
    ///////////////

    calib_sample_avg #(
        .Nadc(Nadc),
        .Nrange(Nrange)
    ) iavg (
        .rstb(rstb),
        .din(dout),
        .clk(clk),
        .update(update),
        .Navg(Navg),
        .avg_out(dout_avg),
        .sum_out(dout_sum)
    );

    ///////////////
    // histogram //
    ///////////////

    logic signed [(Nadc-1):0] hist_avg_in;
    logic [((2**Nrange)-1):0] hist_center_imm;
    logic [((2**Nrange)-1):0] hist_side_imm;
    logic signed [1:0] hist_comp_out;

    calib_hist_measure #(
        .Nadc(Nadc),
        .Nrange(Nrange)
    ) ihist (
        .rstb(rstb),
        .din(dout),
        .din_avg(hist_avg_in),
        .clk(clk),
        .update(update),
        .Nbin(Nbin),
        .DZ(DZ),
        .flip_feedback(flip_feedback),
        .hist_center(hist_center_imm),
        .hist_side(hist_side_imm),
        .hist_comp_out(hist_comp_out)
    );

    //////////////////////////
    // set histogram center //
    //////////////////////////

    assign hist_avg_in = en_ext_ave ? ext_ave : dout_avg;

    ///////////////////////////////////////
    // apply feedback to offset estimate //
    ///////////////////////////////////////

    logic signed [Nadc:0] next_offset_raw;  // extra bit to catch overflow/underflow
    assign next_offset_raw = pfd_offset + hist_comp_out;

    ///////////////////////////
    // clamp offset estimate //
    ///////////////////////////

    localparam signed [(Nadc-1):0] min_pfd_offset = 0;
    localparam signed [(Nadc-1):0] max_pfd_offset = (1<<(Nadc-1))-1;

    logic signed [(Nadc-1):0] next_offset_clamped;

    assign next_offset_clamped = (
        (next_offset_raw > max_pfd_offset) ?
        max_pfd_offset :
        (
            (next_offset_raw < min_pfd_offset) ?
            min_pfd_offset :
            next_offset_raw[(Nadc-1):0]
        )
    );

    ///////////////////////////
    // pfd offset estimation //
    ///////////////////////////

    logic signed [(Nadc-1):0] pfd_offset_pre;
    assign pfd_offset_pre = en_pfd_cal ? next_offset_clamped : ext_pfd_offset;

    always @(posedge clk or negedge rstb) begin
        if (~rstb) begin
            pfd_offset <= 0;
        end else if (update) begin
            pfd_offset <= pfd_offset_pre;
        end else begin
            pfd_offset <= pfd_offset;
        end
    end

    ///////////////////
    // select offset //
    ///////////////////

    logic signed [(Nadc-1):0] selected_pfd_offset;
    assign selected_pfd_offset = en_ext_pfd_offset ? ext_pfd_offset : pfd_offset;

    ///////////////////
    // remove offset //
    ///////////////////

    logic signed [Nadc:0] dout_raw;  // extra bit to catch overflow/underflow

    assign dout_raw = (
        sign_out ?
        (din - selected_pfd_offset) :
        (selected_pfd_offset - din)
    );

    //////////////////
    // clamp output //
    //////////////////

    localparam signed [(Nadc-1):0] min_dout = -(1<<(Nadc-1));
    localparam signed [(Nadc-1):0] max_dout = (1<<(Nadc-1))-1;

    logic signed [(Nadc-1):0] dout_clamped;

    assign dout_clamped = (
        (dout_raw > max_dout) ?
        max_dout :
        (
            (dout_raw < min_dout) ?
            min_dout :
            dout_raw[(Nadc-1):0]
        )
    );

    ///////////////////
    // drive outputs //
    ///////////////////

    always @(posedge clk) begin
        dout <= dout_clamped;
    end

    always @(posedge clk or negedge rstb) begin
        if (~rstb) begin
            hist_center <= 0;
            hist_side <= 0;
        end else if (update) begin
            hist_center <= hist_center_imm;
            hist_side <= hist_side_imm;
        end else begin
            hist_center <= hist_center;
            hist_side <= hist_side;
        end
    end

endmodule

`default_nettype wire
