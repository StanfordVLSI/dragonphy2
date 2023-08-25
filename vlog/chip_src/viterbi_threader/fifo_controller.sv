module fifo_controller #(
    parameter integer num_of_chunks = 5,
    parameter integer num_of_viterbi_fifos = 4
) (
    input logic clk,
    input logic rst_n,
    
    input logic en_fifo,

    input logic is_there_edge,
    input logic [$clog2(num_of_chunks)-1:0] loc_1,
    input logic [$clog2(num_of_chunks)-1:0] loc_2,
    input logic [$clog2(num_of_chunks)-1:0] num_of_writes,

    output logic [num_of_viterbi_fifos-1:0] push_n,
    output logic [num_of_viterbi_fifos-1:0] clr,
    output logic [num_of_viterbi_fifos-1:0] init_n,
    output logic [$clog2(num_of_chunks)-1:0] start_loc [num_of_viterbi_fifos-1:0]
);

    logic [1:0] inc_val;
    logic [num_of_viterbi_fifos-1:0] push;
    logic [$clog2(num_of_viterbi_fifos)-1:0] w_ptr [1:0];
    logic [$clog2(num_of_viterbi_fifos)-1:0] next_w_ptr [1:0];

    logic prev_edge;
    logic enabled;

    assign inc_val = num_of_writes + prev_edge - is_there_edge;
    genvar gi;
    generate
        for(gi = 0; gi < num_of_viterbi_fifos; gi+=1) begin
            assign init_n[gi] = (enabled && en_fifo);
        end
    endgenerate
    assign push_n = ~push;

    always_comb begin
        clr = 0;

        for(int ii = 0; ii < num_of_viterbi_fifos; ii += 1) begin
            start_loc[ii] = 0;
        end

        case (num_of_writes + prev_edge) 
            0: begin
                push = 0;
            end
            1 : begin
                push = 1 << w_ptr[0];
                start_loc[w_ptr[0]] = prev_edge ? 0 : loc_1;
            end
            2 : begin
                push = (1 << w_ptr[0]) | (1 << w_ptr[1]);
                start_loc[w_ptr[0]] = prev_edge ? 0 : loc_1;
                start_loc[w_ptr[1]] = prev_edge ? loc_1 : loc_2;
            end
        endcase


        for(int ii = 0; ii < 2; ii += 1) begin
            next_w_ptr[ii] = w_ptr[ii] + inc_val;
            if(w_ptr[ii] >= num_of_viterbi_fifos) begin
                next_w_ptr[ii] = w_ptr[ii] - num_of_viterbi_fifos;
            end
        end    
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            prev_edge <= 0;
            enabled <= 0;
            for(int ii = 0; ii < 2; ii += 1) begin
                w_ptr[ii] <= ii;
            end
        end
        else begin
            if(en_fifo && !enabled) begin
                enabled <= 1;
            end else if(!en_fifo && enabled) begin
                enabled <= 0;
            end else if(enabled) begin
                prev_edge <= is_there_edge;
                for(int ii = 0; ii < 2; ii += 1) begin
                    w_ptr[ii] <= next_w_ptr[ii];
                end
            end
        end
    end


endmodule // fifo_controller