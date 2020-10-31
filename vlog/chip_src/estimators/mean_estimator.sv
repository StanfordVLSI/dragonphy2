module mean_estimator #(
    parameter integer bitwidth=8,
    parameter integer width=16
) (
    input logic signed [bitwidth-1:0] codes [width-1:0],
    input logic clk,
    input logic rstb,
    output logic signed [bitwidth-1:0] mean
);
    localparam N_val = $clog2(width);
    logic signed [bitwidth + 4 -1:0] curr_mean;
    logic signed [bitwidth-1:0] next_mean;

    always_comb begin
        p
        curr_mean = 0;
        for(ii=0;ii<width, ii=ii+1) begin
            curr_mean = curr_mean + codes[ii];
        end
        next_mean = ((mean << 3) - mean + (curr_mean >> N_val)) >> 3;
    end

    always_ff @(posedge clk or negedge rstb) begin
        if(~rstb) begin
           mean <= 0;
        end else begin
           mean <= next_mean;
        end
    end



endmodule : mean_estimator