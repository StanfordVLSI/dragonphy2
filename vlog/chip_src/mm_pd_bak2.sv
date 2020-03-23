`timescale 1s/1fs

module mm_pd (
    input wire logic clk,
    input wire logic rstb,
    input wire logic signed [7:0] data_i,
    output var logic signed [1:0] pd_o
);
    // "comparators"
    logic signed [1:0] err;
    always @(data_i) begin
        if ((-64 <= data_i) && (data_i <= +64)) begin
            err = +1;
        end else begin
            err = -1;
        end
    end

    // slicer
    logic signed [1:0] d;
    assign d = (data_i > 0) ? +1 : -1;

    // memory
    logic signed [7:0] d_prev;
    logic signed [1:0] err_prev;
    always @(posedge clk) begin
        if (rstb == 1'b0) begin
            d_prev <= 0;
            err_prev <= 0;
        end else begin
            d_prev <= d;
            err_prev <= err;
        end
    end

    // output table
    always @* begin
        if          ((d == +1) && (d_prev == -1) && (err == +1) && (err_prev == -1)) begin
            pd_o = -1;
        end else if ((d == -1) && (d_prev == +1) && (err == +1) && (err_prev == -1)) begin
            pd_o = -1;
        end else if ((d == +1) && (d_prev == -1) && (err == -1) && (err_prev == +1)) begin
            pd_o = +1;
        end else if ((d == -1) && (d_prev == +1) && (err == -1) && (err_prev == +1)) begin
            pd_o = +1;
        end else begin
            pd_o = 0;
        end
    end

    // filtering for debug
    localparam real alpha=0.0005;
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
            pd_filter = ((1.0-alpha)*pd_filter) + (alpha*pd_o);
            this_margin = (data_i > 0) ? (+1.0*data_i) : (-1.0*data_i);
            min_margin = (this_margin < min_margin) ? this_margin : min_margin;
            if (count == 1000) begin
                $display("Filtered PD output: %0f", pd_filter);
                $display("Minimum margin: %0f", min_margin);
                count = 0;
                min_margin = 100.0;
            end
        end
    end
endmodule
