`default_nettype none

module mm_avg_IIR import const_pack::*; (
    input wire logic clk,                       // triggering clock
    input wire logic rstb,
    
    input wire logic signed [Nadc+1:0] in,      // range: [-384, +383]
    input wire logic [2:0] Nlog_sample,
    output wire logic isValid,
    output wire logic signed [Nadc+1:0] out            // PI control output
    //output wire logic clk_cdr                   // Clock on which PI control output changes
);
    // signal declarations

    logic signed [Nadc+1+$clog2(Ncdr_avg):0] out_reg1; // range (worst case): [-384*2^7 : 383*2^7] => [-49152 : 49024] - which is 98176 < 131071 (2^17)

    logic signed [Nadc+1:0] out_reg2; // range: [-384, +383]
    logic [$clog2(Ncdr_avg)-1:0] count;
    logic [$clog2(Ncdr_avg)-1:0] next_count;
    logic rollover;
    logic [1:0] valid;
    // assignments
    assign isValid = (valid == 2);
    assign out = out_reg2[Nadc+1:0];
    assign next_count = count +'d1;
    assign rollover = (count >= 2**Nlog_sample-1) || (next_count == 0);
    //If next_count is zero or if the count is greater or equal 2**(Number of Samples in Average) dump the integrator

    always @(posedge clk, negedge rstb) begin
        if (!rstb) begin 
            count    <= 'd0;
            out_reg1 <= 'd0;
            out_reg2 <= 'd0;
            valid    <= 'd0;
        end else begin 
            count    <= rollover ? 0 : next_count;
            out_reg1 <= rollover ? in : out_reg1 + in;
            out_reg2 <= rollover ? (out_reg1 >>> (Nlog_sample)) : out_reg2;
            valid    <= (rollover && !isValid) ? valid + 1 : valid;
        end
    end

endmodule

`default_nettype wire

