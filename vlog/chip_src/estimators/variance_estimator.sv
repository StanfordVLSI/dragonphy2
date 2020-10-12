module variance_estimator #(
    parameter integer bitwidth=8,
    parameter integer width=16

)(
    input logic signed [bitwidth-1:0] codes [width-1:0],
    input logic signed [bitwidth-1:0] mean,
    input logic clk,
    input logic rstb,
    output logic [bitwidth*2-1:0] variance
);
    localparam N_val = $clog2(width);
    logic [bitwidth*2 + N_val -1:0] curr_var;
    logic [bitwidth*2-1:0] next_var;

    integer ii;

    always_comb begin
        curr_var = 0;
        for(ii=0;ii<width;ii=ii+1) begin
            curr_var = curr_var + (codes[ii] - mean)**2;
        end
        next_var = ((var << 3) - var + (curr_var << N_val)) >> 3;
    end

    always_ff @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            variance <= 0;
        end else begin
            variance <= next_var;
        end
    end
endmodule : variance_estimator