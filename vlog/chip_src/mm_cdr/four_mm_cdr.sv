`default_nettype none

module four_mm_cdr import const_pack::*; #(
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

    output logic freq_lvl_cross[Nout-1:0],

    cdr_debug_intf.cdr cdbg_intf_i
);

    logic signed [Nadc+1:0] pd_phase_error [Nout-1:0];

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    // new signals added that allow the phase update to be clamped
    // ref: https://github.com/StanfordVLSI/issues/20
    micro_mm_pd iMM_PD (
        .codes(codes),
        .bits(bits),
        .clk(clk),
        .ext_rstb(ext_rstb),
        .pd_offset(cdbg_intf_i.pd_offset_ext),
        .pd_out(pd_phase_error)
    );
    
    genvar k;
    generate 
        for (k=0;k<Nout;k=k+1) begin: uMM_CTL
            micro_mm_cdr_ctl i_umm_cdrctl (
                .codes(codes),
                .bits(bits),
                .ramp_clock(ramp_clock),
                .pd_in(pd_phase_error[k]),
                .clk(clk),
                .ext_rstb(ext_rstb),
                .pi_ctl(pi_ctl[k]),
                .freq_lvl_cross(freq_lvl_cross[k]),
                .cdbg_intf_i(cdbg_intf_i)
            );
        end
    endgenerate

endmodule

`default_nettype wire
