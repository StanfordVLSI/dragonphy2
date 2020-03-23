`timescale 1s/1fs

module mm_pd_bak (
    input wire logic clk,
    input wire logic rstb,
    input wire logic signed [7:0] data_i,
    output wire logic signed [9:0] pd_o
);
    // slicer
    logic signed [1:0] val;
    assign val = (data_i > 0) ? +1 : -1;

    // memory
    logic signed [7:0] data_prev;
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
    logic signed [8:0] term1;
    logic signed [8:0] term2;
    assign term1 = data_prev * val;
    assign term2 = data_i * val_prev;
    assign pd_o = term1 - term2;

    // filtering for debug
    localparam real alpha=0.0005;
    real pd_filter=0;
    real margin_filter=0;
    integer count=0;
    always @(posedge clk) begin
        if (rstb == 1'b0) begin
            pd_filter = 0.0;
            margin_filter = 0.0;
            count = 0;
        end else begin
            count = count+1;
            pd_filter = ((1.0-alpha)*pd_filter) + (alpha*pd_o);
            margin_filter = ((1.0-alpha)*margin_filter) + (alpha*(val*data_i));
            if (count == 1000) begin
                $display("Filtered PD output: %0f", pd_filter);
                $display("Filtered margin: %0f", margin_filter);
                count = 0;
            end
        end
    end
endmodule
