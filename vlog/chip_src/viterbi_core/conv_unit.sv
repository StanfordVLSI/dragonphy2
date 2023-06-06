    module conv_unit #(
        parameter integer i_width = 8,
        parameter integer i_depth = 8,
        parameter integer f_width = 8,
        parameter integer f_depth = 8,
        parameter integer o_width = 9,
        parameter integer o_depth = 4,
        parameter integer offset = 0,
        parameter integer shift = 1
    ) (
        input logic signed [i_width-1:0] in [i_depth-1:0],
        input logic signed [f_width-1:0] filter [f_depth-1:0],
        output logic signed [o_width-1:0] out [o_depth-1:0]
    );

    always_comb begin 
        for(int ii = 0; ii < o_depth; ii += 1) begin
            out[o_depth - ii - 1] = 0;
            for(int jj = 0; jj < i_depth; jj += 1) begin
                if (jj + offset >= ii) begin
                    out[o_depth - ii - 1] += (filter[jj-ii + offset] * in[jj]);
                end
            end
        end
    end


    endmodule