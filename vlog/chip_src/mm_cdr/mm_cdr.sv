`default_nettype none

module mm_cdr import const_pack::*; #(
    parameter integer prop_width = 5,
    parameter integer intg_width = 5,
    parameter integer ramp_width = 5,
    parameter integer phase_est_shift = 20
) (
    input wire logic signed [Nadc-1:0] codes[Nti-1:0],    // adc outputs
    input wire logic signed [2:0] syms [Nti-1:0],    // adc outputs

    input wire logic clk,
    input wire logic ext_rstb,
    
    output logic [Npi-1:0] pi_ctl [Nout-1:0],


    output logic signed [Nadc+1-1:0] phase_est_sample,
    output logic signed [Nadc+1-1:0] freq_est_sample,

    // Not Connected :) 
    input wire logic ramp_clock,
    output logic freq_lvl_cross,

    cdr_debug_intf.cdr cdbg_intf_i
);

    logic signed [prop_width-1:0] Kp;
    logic signed [intg_width-1:0] Ki;

    assign Ki = cdbg_intf_i.Ki;
    assign Kp = cdbg_intf_i.Kp;


    
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    logic signed [Nadc+1:0] pd_phase_error;
    logic signed [Nadc+1+phase_est_shift:0] phase_est_d, phase_est_q, freq_est_d, freq_est_q, phase_est_out;
    logic signed [Npi-1:0]  scaled_pi_ctl;

    //logic cond1, cond2;
    
    mm_pd iMM_PD (
        .codes(codes),
        .syms(syms),
        .pd_offset(cdbg_intf_i.pd_offset_ext),
        .pd_out(pd_phase_error)
    );

    always @* begin
        phase_est_d    = phase_est_q - (pd_phase_error <<< Kp) + (cdbg_intf_i.en_freq_est ? freq_est_q : 0); 
        freq_est_d     = freq_est_q  - (pd_phase_error <<< Ki); 

        // shift to produce output
        phase_est_sample = phase_est_q >>> phase_est_shift;
        freq_est_sample  = freq_est_q  >>> phase_est_shift;
    end

    always_ff @(posedge clk or negedge ext_rstb) begin 
        if(~ext_rstb) begin
            phase_est_q <= 0;
            freq_est_q  <= 0;

        end else begin
            if (cdbg_intf_i.en_ext_pi_ctl) begin
                phase_est_q         <= cdbg_intf_i.ext_pi_ctl << phase_est_shift;
                freq_est_q          <= 0;
            end else begin
                phase_est_q         <= phase_est_d;
                freq_est_q          <= freq_est_d;
            end            
        end
    end

    assign scaled_pi_ctl = (phase_est_q >> phase_est_shift);

    genvar k;
    generate
        for(k=0;k<Nout;k=k+1) begin
            assign pi_ctl[k] = cdbg_intf_i.en_ext_pi_ctl ? cdbg_intf_i.ext_pi_ctl : scaled_pi_ctl;
        end
    endgenerate


    always_ff @(posedge clk or negedge ext_rstb) begin
        if(~ext_rstb) begin
            freq_lvl_cross <= 0;
        end else begin
            freq_lvl_cross <= 1;
        end
    end



endmodule

`default_nettype wire
