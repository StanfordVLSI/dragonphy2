`default_nettype none

module mm_cdr import const_pack::*; (
    input wire logic clk_data,                          // parallel data clock
    input wire logic signed [Nadc-1:0] din[Nti-1:0],    // adc outputs
    input wire logic sel_ext,
    input wire logic [Npi-1:0] pi_ctl_ext,
    input wire logic ext_rstb,
    input wire logic clk_cdr,
    input wire logic [2:0] Nlog_sample,
    output wire logic  [Npi-1:0]pi_ctl[Nout-1:0],

    cdr_debug_intf.cdr cdbg_intf_i
);

    logic signed [Nadc-1:0] pd_offset;
    logic signed [Npi-1:0] pi_filt_out;
    logic signed [Nadc+1:0] pd_out_bstage0, pd_out_astage0, pd_out_bstage1, pd_out_astage1; // pd output

    logic valid;
    // Phase detector

    mm_pd iMM_PD (
        .din(din),
        .pd_offset(cdbg_intf_i.pd_offset_ext),
        .pd_out(pd_out_bstage0)
    );


    always @(posedge clk_data) begin
        pd_out_astage0 <= valid ? pd_out_bstage0 : 0;
    end

    mm_avg_IIR iMM_AVG_IIR (
        .clk(clk_data),
        .rstb(ext_rstb),

        .in(pd_out_astage0),
        .Nlog_sample(Nlog_sample),
        .out(pd_out_bstage1),
        //Until the integrator rolls over twice, the output will not be valid due to how the clk_cdr times... 
        .isValid(valid)
    );

    always @(posedge clk_cdr, negedge ext_rstb) begin
        if (!ext_rstb) begin
            pd_out_astage1 <= 0;
        end else begin
            pd_out_astage1 <= valid ? pd_out_bstage1 : 0;
        end
    end

    // Filter

    pi_filter iFILTER (
        .clk(clk_cdr),
        .rstb(ext_rstb && valid),
        .sel_ext(sel_ext),
        .pi_ctl_ext(pi_ctl_ext),
        .p_val(cdbg_intf_i.p_val),
        .i_val(cdbg_intf_i.i_val),
        .in(pd_out_astage1),
        .out(pi_filt_out)
    );

    genvar k;
    generate
        for(k=0;k<Nout;k=k+1) begin
            assign pi_ctl[k] = pi_filt_out;
        end
    endgenerate

endmodule

`default_nettype wire
