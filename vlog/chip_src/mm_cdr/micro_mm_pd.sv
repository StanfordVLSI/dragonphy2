`default_nettype none
// Modified from steven's simple mm_cdr
// This cdr respect the clock groups.
// There are four clock groups, each clock group has four clock phases (I, IB, Q, QB). 
// This Rx uses 16x (4x4) time-interleaved ADC as AFE
// 
module micro_mm_pd import const_pack::*; (
    input wire logic signed [Nadc-1:0] codes [Nti-1:0],   // range: [-128, +127]
    input wire logic bits [Nti-1:0],
    input wire logic clk,
    input wire logic ext_rstb,
    input wire logic signed [Nadc-1:0] pd_offset,       // range: [-128, +127]
    output var logic signed [Nadc+1:0] pd_out [Nout-1:0]           // range: [-384, +383]
);
    // Setup the pipelined codes, bits and ak. 
    // The bits and codes at the beginning and ending are going to use the descision from previous cycle.

    logic signed [Nadc-1:0] codes_pre [Nti-1:0]; // previous batch/16-cycle codes
    logic signed [Nadc-1:0] codes_cur [Nti-1:0]; // current batch/16-cycle codes
    logic signed [Nadc-1:0] codes_pos [Nti-1:0]; // post batch/16-cycle codes
    logic bits_pre [Nti-1:0]; // previous batch/16-cycle bits
    logic bits_cur [Nti-1:0]; // current batch/16-cycle bits
    logic bits_pos [Nti-1:0]; // post batch/16-cycle bits


    genvar i;
    generate 
        for (i=0;i<Nti;i=i+1) begin
            always_ff @(posedge clk or negedge ext_rstb) begin
                if (~ext_rstb) begin
                    // reset codes
                    // Hard coded reset value, needs to be changed
                    codes_pre[i] <= 'b0;
                    codes_cur[i] <= 'b0;
                    codes_pos[i] <= 'b0;
                    bits_pre[i] <= 'b0;
                    bits_cur[i] <= 'b0;
                    bits_pos[i] <= 'b0;
                end
                else begin
                    // pipeline the inputs codes
                    codes_pre[i] <= codes[i];
                    codes_cur[i] <= codes_pre[i];
                    codes_pos[i] <= codes_cur[i];
                    bits_pre[i] <= bits[i];
                    bits_cur[i] <= bits_pre[i];
                    bits_pos[i] <= bits_cur[i];
                end
            end
        end
    endgenerate

    // codes and bits correspondence to the clock group [0, 90, 180, 270]
    // codes[0], codes[4], codes[8], codes[12]; clk_intrep_xxx[0]
    // codes[1], codes[5], codes[9], codes[13]; clk_intrep_xxx[1]
    // codes[2], codes[6], codes[10], codes[14]; clk_intrep_xxx[2]
    // codes[3], codes[7], codes[11], codes[15]; clk_intrep_xxx[3]
    
    // The index order applyies to bits and ak as well
    
    // data sign
    logic signed [1:0] ak [Nti:-1];                     // range: [-2, +2]

    // signals used in estimating phase
    logic signed [Nadc+1:0] pd_net_clk_0 [Nout-1:0];           // range: [-256, +256]
    logic signed [Nadc+1:0] pd_net_clk_1 [Nout-1:0];           // range: [-256, +256]
    logic signed [Nadc+1:0] pd_net_clk_2 [Nout-1:0];           // range: [-256, +256]
    logic signed [Nadc+1:0] pd_net_clk_3 [Nout-1:0];           // range: [-256, +256]
    logic signed [Nadc+1+$clog2(Nti):0] pd_net_sum [Nout-1:0];     // range: [-4096, +4096]
    logic signed [Nadc+1:0] pd_net_sc [Nout-1:0];                  // range: [-256, +256]
    
///////// NOT IDEAL, REMOVED
    
    // set boundary conditions
    // assign ak[Nti] = 0;
    // assign ak[-1] = 0;
    // compute data sign and individual terms of the phase estimate

///////// NOT IDEAL
    assign ak[Nti] = bits_pre[Nti-1] ? 1 : -1;
    assign ak[-1] = bits_pos[0] ? 1 : -1;

    genvar k;
    generate
        for (k=0; k<Nti; k=k+1) begin: uSGN
            assign ak[k] = bits_cur[k]  ? 1 : -1;
        end
        // generate the two boundary bits
    
    endgenerate

    generate 
        for (k=0; k<Nout; k=k+1) begin: uPI
            // Convert this to four outputs for each PI
            assign pd_net_clk_0[k] = codes_cur[4*k+0]*(ak[4*k+1] - ak[4*k-1]);
            assign pd_net_clk_1[k] = codes_cur[4*k+1]*(ak[4*k+2] - ak[4*k-0]); 
            assign pd_net_clk_2[k] = codes_cur[4*k+2]*(ak[4*k+3] - ak[4*k+1]); 
            assign pd_net_clk_3[k] = codes_cur[4*k+3]*(ak[4*k+4] - ak[4*k+2]); 
        end
    endgenerate


    // compute sum of individual terms

    always @(*) begin
        pd_net_sum[0] = 0;
        pd_net_sum[1] = 0;
        pd_net_sum[2] = 0;
        pd_net_sum[3] = 0;
        for (int i=0;i<Nout;i++) begin
            pd_net_sum[0] += pd_net_clk_0[i];
            pd_net_sum[1] += pd_net_clk_1[i];
            pd_net_sum[2] += pd_net_clk_2[i];
            pd_net_sum[3] += pd_net_clk_3[i];
        end
    end

    // re-scale sum of terms

    generate
        for (k=0; k<Nout; k=k+1) begin: uPD_SUM
            assign pd_net_sc[k] = pd_net_sum[k] >>> $clog2(1); // No scaling if set to 1 since log2(1) = 0;
            // assign output
            assign pd_out[k] = pd_net_sc[k] + pd_offset; // modify this to accomodate four independent offset controls from JTAG
        end
    endgenerate
    


endmodule

`default_nettype wire
