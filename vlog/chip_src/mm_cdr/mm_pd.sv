`default_nettype none

module mm_pd import const_pack::*; (
    input wire logic signed [Nadc-1:0] codes [Nti-1:0],   // range: [-128, +127]
    input wire logic bits [Nti-1:0],
    input wire logic signed [Nadc-1:0] pd_offset,       // range: [-128, +127]
    output var logic signed [Nadc+1:0] pd_out           // range: [-384, +383]
);
    // data sign
    logic signed [1:0] ak [Nti:-1];                     // range: [-2, +2]
    
    // signals used in estimating phase
    logic signed [Nadc+1:0] pd_net [Nti-1:0];           // range: [-256, +256]
    logic signed [Nadc+1+$clog2(Nti):0] pd_net_sum;     // range: [-4096, +4096]
    logic signed [Nadc+1:0] pd_net_sc;                  // range: [-256, +256]
    // set boundary conditions

    assign ak[Nti] = 0;
    assign ak[-1] = 0;

    // compute data sign and individual terms of the phase estimate

    genvar k;
    generate
        for (k=0; k<Nti; k=k+1) begin: uSGN
            assign ak[k] = bits[k]  ? 1 : -1;
        end

        for (k=0; k<Nti; k=k+1) begin: uPD
            // Convert this to four outputs for each PI
            assign pd_net[k] = codes[k]*(ak[k+1] - ak[k-1]);
        end
    endgenerate

    // compute sum of individual terms

    always @(*) begin
        pd_net_sum = 0;
        for (int i=0;i<Nti;i++) begin
            pd_net_sum += pd_net[i];
        end
    end

    // re-scale sum of terms

    assign pd_net_sc = pd_net_sum >>> $clog2(Nti);

    // assign output
    assign pd_out = pd_net_sc + pd_offset;

endmodule

`default_nettype wire