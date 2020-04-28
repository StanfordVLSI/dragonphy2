module weight_manager #(
    parameter integer width=16,
    parameter integer depth=7,
    parameter integer bitwidth=8
) (
    input wire logic [width*2-1:0] data,
    input wire logic [1+$clog2(width)+$clog2(depth)-1:0] inst,
    input wire logic exec,

    input wire logic clk,
    input wire logic rstb,

    output logic signed [bitwidth-1:0] weights [width-1:0][depth-1:0]
);
    
    logic is_increment;
    logic [$clog2(depth)-1:0] depth_addr;
    logic [$clog2(width)-1:0] width_addr;
    logic signed [bitwidth-1:0] increment_weights [width-1:0];
    logic signed [bitwidth-1:0] next_weights [width-1:0];


    assign is_increment = inst[1+$clog2(width)+$clog2(depth)-1];
    assign depth_addr   = inst[$clog2(depth)-1:0];
    assign width_addr   = inst[$clog2(width) + $clog2(depth)-1: $clog2(depth)]

    genvar gi;

    generate
        for(gi=0 ; gi < width; gi = gi + 1) begin
            assign increment_weights[gi] =  weights[gi][depth_addr] + $signed(data[2*gi+1:2*gi]);
            assign next_weights[gi] = is_increment ? increment_weights[gi] :  

            always_ff @(posedge clk or negedge rstb) begin
                if(~rstb) begin
                    manager_state <= READY;
                end else begin
                    weights <= exec ? next_weights : weights
                end
            end
        end
    endgenerate 


endmodule : weight_manager