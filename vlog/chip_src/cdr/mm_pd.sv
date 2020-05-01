module mm_pd # (
    parameter integer codeBitwidth=8,
    parameter integer pdBitwidth=8,
    parameter integer shiftBitwidth=4,
    parameter integer numChannels=16,
    parameter integer centerBuffer=1,
    parameter integer numBuffers=3
) (
    input wire logic signed [codeBitwidth-1:0] flat_codes [numBuffers*numChannels-1:0],   // range: [-128, +127]
    input wire logic [shiftBitwidth-1:0] shift_pd,
    output var logic signed [pdBitwidth-1:0] pd_out                                     // range: [-384, +383]
);
    localparam c_pos = centerBuffer*numChannels;

    // data sign
    logic signed [1:0] sign_of_code [numChannels:-1];                     // range: [-2, +2]
    
    // signals used in estimating phase
    logic signed [codeBitwidth:0] pd_net [numChannels-1:0];           // range: [-256, +256]
    logic signed [codeBitwidth+$clog2(numChannels):0] pd_net_sum;     // range: [-4096, +4096]
    logic signed [codeBitwidth:0] pd_net_sc;                  // range: [-256, +256]


    // compute data sign and individual terms of the phase estimate

    genvar gi;
    generate
        for (gi=-1; gi<numChannels+1; gi=gi+1) begin: uSGN
            assign sign_of_code[gi] = (flat_codes[c_pos+gi][codeBitwidth-1]==0)? 1 : -1;
        end

        for (gi=0; gi<numChannels; gi=gi+1) begin: uPD
            assign pd_net[gi] = flat_codes[c_pos+gi]*(sign_of_code[gi+1] - sign_of_code[gi-1]);
        end
    endgenerate

    // compute sum of individual terms

    always_comb begin
        pd_net_sum = 0;
        for (int i=0;i<numChannels;i++) begin
            pd_net_sum += pd_net[i];
        end
        pd_out = pd_net_sum >>> shift_pd;
    end

endmodule : mm_pd