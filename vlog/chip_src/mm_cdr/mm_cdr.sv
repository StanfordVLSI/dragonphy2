`default_nettype none

module mm_cdr import const_pack::*; #(
    parameter integer prop_width = 5,
    parameter integer intg_width = 5,
    parameter integer ramp_width = 5,
    parameter integer phase_est_shift = 20
) (
    input wire logic signed [Nadc-1:0] codes[Nti-1:0],    // adc outputs
    input wire logic bits [Nti-1:0],    // adc outputs
    input wire logic ramp_clock,

    input wire logic clk,
    input wire logic ext_rstb,
    
    output logic [Npi-1:0]pi_ctl[Nout-1:0],
    output logic freq_lvl_cross,

    cdr_debug_intf.cdr cdbg_intf_i
);

    typedef enum  logic [1:0] {SAMPLE, WAIT, READY} sampler_state_t;
    sampler_state_t sampler_state;

    logic signed [prop_width-1:0] Kp;
    logic signed [intg_width-1:0] Ki;
    logic signed [ramp_width-1:0] Kr; 

    assign Ki = cdbg_intf_i.Ki;
    assign Kp = cdbg_intf_i.Kp;
    assign Kr = cdbg_intf_i.Kr;

    logic ramp_clock_ff;
    logic ramp_clock_sync;
    logic signed [Nadc+1:0] phase_error_d, phase_error_q, pd_phase_error, phase_error_inv;
    logic signed [Nadc+1+phase_est_shift:0] phase_est_d, phase_est_q, phase_est_update;

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    // new signals added that allow the phase update to be clamped
    // ref: https://github.com/StanfordVLSI/issues/20

    logic signed [Nadc+1+phase_est_shift:0] clamp_min;
    logic signed [Nadc+1+phase_est_shift:0] clamp_max;
    logic signed [Nadc+1+phase_est_shift:0] phase_update_clamped;

    always_ff @(posedge clk or negedge ext_rstb) begin
        if(~ext_rstb) begin
            clamp_min <= 0;
            clamp_max <= 0;
        end else begin
            clamp_min  <= -1 * cdbg_intf_i.cdr_clamp_amt;
            clamp_max  <= cdbg_intf_i.cdr_clamp_amt;
        end
    end

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    logic signed [Nadc+1+phase_est_shift:0] ramp_est_pls_d, ramp_est_pls_q, ramp_est_pls_update;
    logic signed [Nadc+1+phase_est_shift:0] ramp_est_neg_d, ramp_est_neg_q, ramp_est_neg_update;

    logic signed [Nadc+2+phase_est_shift:0] freq_diff;
    logic signed [Nadc+1+phase_est_shift:0] freq_est_d, freq_est_q, prev_freq_update_q;
    logic signed [Nadc+1+phase_est_shift:0] freq_est_update;

    logic signed [Npi-1:0]  scaled_pi_ctl;
    logic signed [Nadc+1:0] phase_est_out;

    //logic cond1, cond2;
    
    mm_pd iMM_PD (
        .codes(codes),
        .bits(bits),
        .pd_offset(cdbg_intf_i.pd_offset_ext),
        .pd_out(pd_phase_error)
    );


    always @* begin
        phase_error_d         = cdbg_intf_i.invert ? -1*pd_phase_error : pd_phase_error;

        ramp_est_pls_update  = ramp_est_pls_q + (ramp_clock ? (phase_error_q << Kr) : 0 );
        ramp_est_neg_update  = ramp_est_neg_q + (ramp_clock ? 0 : (phase_error_q << Kr));

        ramp_est_pls_d       = cdbg_intf_i.en_ramp_est ? ramp_est_pls_update : 0;
        ramp_est_neg_d       = cdbg_intf_i.en_ramp_est ? ramp_est_neg_update : 0;

        freq_est_update  = (phase_error_q << Ki) + (ramp_clock_sync ? ramp_est_pls_q : -1*ramp_est_neg_q);
        freq_est_d       = freq_est_q          + (cdbg_intf_i.en_freq_est ? freq_est_update : 0);
        freq_diff        = freq_est_update - prev_freq_update_q;

        // calculate the phase update
        phase_est_update = ((phase_error_q << Kp) + freq_est_q);

        // clamp the phase update, if requested
        if (cdbg_intf_i.cdr_en_clamp) begin
            if (phase_est_update < clamp_min) begin
                phase_update_clamped = clamp_min;
            end else if (phase_est_update > clamp_max) begin
                phase_update_clamped = clamp_max;
            end else begin
                phase_update_clamped = phase_est_update;
            end
        end else begin
            phase_update_clamped = phase_est_update;
        end

        // apply the phase update
        phase_est_d = phase_est_q + phase_update_clamped;

        // shift to produce output
        phase_est_out = phase_est_q >> phase_est_shift;
    end

    always_ff @(posedge clk or negedge ext_rstb) begin 
        if(~ext_rstb) begin
            phase_error_q <= 0;
            phase_est_q <= 0;
            freq_est_q  <= 0;
            prev_freq_update_q <= 0;
            ramp_est_pls_q <= 0;
            ramp_est_neg_q <= 0;
            ramp_clock_ff <= 0;
            ramp_clock_sync <= 0;
        end else begin
            phase_error_q           <= phase_error_d;
            phase_est_q             <= phase_est_d;
            freq_est_q              <= freq_est_d;
            prev_freq_update_q      <= freq_est_update;
            ramp_est_pls_q          <= ramp_est_pls_d;
            ramp_est_neg_q          <= ramp_est_neg_d;
            ramp_clock_ff           <= ramp_clock;
            ramp_clock_sync         <= ramp_clock_ff;
        end
    end

    assign scaled_pi_ctl = phase_est_out;// >> (Nadc + 2 - Npi);

    genvar k;
    generate
        for(k=0;k<Nout;k=k+1) begin
            assign pi_ctl[k] = cdbg_intf_i.en_ext_pi_ctl ? cdbg_intf_i.ext_pi_ctl : scaled_pi_ctl;
        end
    endgenerate


    //State Machine to sample the current state of the 2nd order loop once
    always_ff @(posedge clk or negedge ext_rstb) begin
        if(~ext_rstb) begin
            cdbg_intf_i.phase_est <= 0;
            cdbg_intf_i.freq_est  <= 0;
            cdbg_intf_i.ramp_est  <= 0;
            sampler_state <= WAIT;
        end else begin
            case(sampler_state)
                SAMPLE : begin
                    cdbg_intf_i.phase_est <= phase_est_out;
                    cdbg_intf_i.freq_est  <= freq_est_update;
                    cdbg_intf_i.ramp_est  <= ramp_clock ? ramp_est_pls_update : ramp_est_neg_update;
                    sampler_state <= WAIT;
                end
                WAIT : begin
                    sampler_state <= cdbg_intf_i.sample_state ? WAIT : READY;
                end
                READY : begin
                    sampler_state <= cdbg_intf_i.sample_state ? SAMPLE : READY;
                end
            endcase
        end
    end

    always_ff @(posedge clk or negedge ext_rstb) begin
        if(~ext_rstb) begin
            freq_lvl_cross <= 0;
        end else begin
            freq_lvl_cross <= (freq_diff > 0) ? 1'b1 : 1'b0;
        end
    end



endmodule

`default_nettype wire
