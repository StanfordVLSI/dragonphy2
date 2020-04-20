`default_nettype none

module mm_cdr import const_pack::*; #(
    parameter integer prop_width = 6,
    parameter integer intg_width = 6,
    parameter integer phase_est_shift = 6
) (
    input wire logic signed [Nadc-1:0] din[Nti-1:0],    // adc outputs

    input wire logic [Npi-1:0] pi_ctl_ext,

    input wire logic clk,
    input wire logic ext_rstb,
    
    output wire logic  [Npi-1:0]pi_ctl[Nout-1:0],

    cdr_debug_intf.cdr cdbg_intf_i
);

    typedef enum  logic [1:0] {SAMPLE, WAIT, READY} sampler_state_t;
    sampler_state_t sampler_state;

    logic signed [prop_width-1:0] Kp = cdbg_intf_i.Kp;
    logic signed [intg_width-1:0] Ki = cdbg_intf_i.Ki;

    logic signed [Nadc+1:0] phase_error;
    logic signed [Nadc+1+phase_est_shift:0] phase_est_d, phase_est_q, freq_est_d, freq_est_q;
    logic signed [Nadc+1+phase_est_shift:0] freq_est_update;

    logic signed [Npi-1:0]  scaled_pi_ctl;
    logic signed [Nadc+1:0] phase_est_out;


    mm_pd iMM_PD (
        .din(din),
        .pd_offset(cdbg_intf_i.pd_offset_ext),
        .pd_out(phase_error)
    );

    always @* begin
        freq_est_update  = freq_est_q + (phase_error << Ki);
        freq_est_d       = cdbg_intf_i.en_freq_est ? freq_est_update : 0;
        phase_est_d      = phase_est_q + (phase_error << Kp) + freq_est_q;
        phase_est_out    = phase_est_q >> phase_est_shift;
    end

    always_ff @(posedge clk or negedge ext_rstb) begin 
        if(~ext_rstb) begin
            phase_est_q <= 0;
            freq_est_q  <= 0;
        end else begin
            phase_est_q <= phase_est_d;
            freq_est_q  <= freq_est_d;
        end
    end

    assign scaled_pi_ctl = phase_est_out >> (Nadc + 2 - Npi);

    genvar k;
    generate
        for(k=0;k<Nout;k=k+1) begin
            assign pi_ctl[k] = cdbg_intf_i.en_ext_pi_ctl ? pi_ctl_ext : scaled_pi_ctl;
        end
    endgenerate


    //State Machine to sample the current state of the 2nd order loop once
    always_ff @(posedge clk or negedge ext_rstb) begin
        if(~ext_rstb) begin
            cdbg_intf_i.phase_est <= 0;
            cdbg_intf_i.freq_est  <= 0;
            sampler_state <= WAIT;
        end else begin
            case(sampler_state)
                SAMPLE : begin
                    cdbg_intf_i.phase_est <= phase_est_out;
                    cdbg_intf_i.freq_est  <= freq_est_update;
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



endmodule

`default_nettype wire
