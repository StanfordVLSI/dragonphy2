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
    
    typedef enum logic [1:0] {READY, HALT} manager_state_t;
    manager_state_t manager_state;

    logic is_increment;
    logic [$clog2(depth)-1:0] depth_addr;
    logic [$clog2(width)-1:0] width_addr;
    logic signed [bitwidth-1:0] increment_weights [width-1:0];
    logic signed [bitwidth-1:0] set_weights[width-1:0];
    logic signed [bitwidth-1:0] next_weights [width-1:0];


    assign is_increment = inst[1+$clog2(width)+$clog2(depth)-1];
    assign depth_addr   = inst[$clog2(depth)-1:0];
    assign width_addr   = inst[$clog2(width) + $clog2(depth)-1: $clog2(depth)]

    genvar gi;
    generate
        for(gi=0 ; gi < width; gi = gi + 1) begin
            assign increment_weights[gi] =  weights[gi][depth_addr] + $signed(data[2*gi+1:2*gi]);
            assign next_weights[gi][depth_addr] = is_increment ? increment_weights[gi] : set_weights[gi];
        end
    endgenerate 

    always_comb begin
        int ii;
        for(ii=0; ii<width; ii=ii+1) begin
            if(ii == width_addr) begin
                set_weights[ii] = $signed(data[bitwidth-1:0]);
            end else begin
                set_weights[ii] = weights[ii][depth_addr];
            end
        end
    end

    always_ff @(posedge clk or negedge rstb) begin
        if(~rstb) begin
           manager_state <= READY;
        end else begin
            case(manager_state)
                READY: begin
                    weights[depth_addr] <= exec ? next_weights : weights[depth_addr];
                    manager_state <= exec ? HALT : READY;
                end
                HALT: begin
                    manager_state <= exec ? HALT : READY;
                end
        end
    end




endmodule : weight_manager