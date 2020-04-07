`default_nettype none

module pi_filter import const_pack::*; (
    input wire logic clk,                       // triggering clock
    input wire logic sel_ext,                   // enable loop filter
    input wire logic signed [Nadc+1:0] in,      // output phase error signal from mmpd- range: [-384, +383] -> 
    input wire logic signed [Npi-1:0] pi_ctl_ext,      // external control value (valid when sel_ext == Hi)
    input wire logic rstb,
    input wire logic signed [21:0] p_val,       // [-2^23 : 2^23 + 1]
    input wire logic signed [21:0] i_val,       // [-2^23 : 2^23 + 1]
    output wire logic [Npi-1:0] out            // PI control output range: [0 : 511]
    //output wire logic clk_cdr                   // Clock on which PI control output changes
);
    localparam integer N_total = (22+Nadc+1+1);
    localparam integer N_frac = (N_total-Npi);        // number of fractional bits in LF state
    // signal declarations
    logic signed [N_total-1:0] curr_y;
    // assignments
    logic signed [N_total+8-1:0] prop_sig;
    logic signed [N_total+8-1:0] int_sig;

    assign prop_sig = (p_val*in) << 8;
    assign int_sig  = i_val*curr_y;
    assign out = curr_y >>> N_frac;
    //assign clk_cdr = clk;
    // main logic

    always @(posedge clk, negedge rstb) begin
        if (!rstb) begin 
            curr_y <= +'sd0;
        end else begin 
            curr_y <= sel_ext ? pi_ctl_ext << N_frac : (int_sig  + prop_sig) >>> 8;
        end
    end

endmodule

`default_nettype wire

