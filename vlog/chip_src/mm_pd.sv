`timescale 1s/1fs

module mm_pd #(
    parameter integer adc_bits=8,
    parameter integer pi_ctl_bits=8,
    parameter integer pi_ctl_init=0,
    parameter integer filt_shift=8
) (
    input wire logic clk,
    input wire logic rstb,
    input wire logic signed [(adc_bits-1):0] data_i,
    output wire logic [(pi_ctl_bits-1):0] pi_ctl
);
    // slicer
    logic signed [1:0] val;
    assign val = (data_i > 0) ? +1 : -1;

    // memory
    logic signed [(adc_bits-1):0] data_prev;
    logic signed [1:0] val_prev;
    always @(posedge clk) begin
        if (rstb == 1'b0) begin
            val_prev <= 0;
            data_prev <= 0;
        end else begin
            val_prev <= val;
            data_prev <= data_i;
        end
    end

    // main phase detector
    logic signed [adc_bits:0] term1;
    logic signed [adc_bits:0] term2;
    logic signed [(adc_bits+1):0] pd_o;
    assign term1 = data_prev * val;
    assign term2 = data_i * val_prev;
    assign pd_o = term1 - term2;

    // loop filter
    logic signed [(pi_ctl_bits+filt_shift-1):0] pi_ctl_full;
    always @(posedge clk) begin
        if (rstb == 1'b0) begin
            pi_ctl_full <= (pi_ctl_init << filt_shift);
        end else begin
            pi_ctl_full <= pi_ctl_full - pd_o;
        end
    end
    assign pi_ctl = pi_ctl_full[(pi_ctl_bits+filt_shift-1):filt_shift];

    // filtering for debug
    real pd_filter=0;
    real min_margin=0;
    real this_margin;
    integer count=0;
    always @(posedge clk) begin
        if (rstb == 1'b0) begin
            pd_filter = 0.0;
            min_margin = 100.0;
            count = 0;
        end else begin
            count = count+1;
            pd_filter = pd_filter + pd_o;
            this_margin = (data_i > 0) ? (+1.0*data_i) : (-1.0*data_i);
            min_margin = (this_margin < min_margin) ? this_margin : min_margin;
            if (count == 1000) begin
                $display("Filtered PD output: %0f", pd_filter/1000.0);
                $display("Minimum margin: %0f", min_margin);
                $display("PI CTL: %0d", pi_ctl);
                count = 0;
                min_margin = 100.0;
                pd_filter = 0;
            end
        end
    end
endmodule
