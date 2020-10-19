`default_nettype none

module tx_top import const_pack::*; #(
) (
    input wire logic [15:0] din,
    input wire logic mdll_clk, // Clock from MDLL
    input wire logic ext_clk, // Clock from external source

    input wire logic rst, // Global reset for Tx
    input wire logic [Npi-1:0] ctl_pi [Nout-1:0],
    input wire logic clk_async,
    input wire logic clk_encoder,
    input wire logic ctl_valid,

    output wire logic clk_prbsgen,  // Output clock for 16-bit prbs generator
    output wire logic dout_p, // Data output
    output wire logic dout_n,
    tx_debug_intf.tx tx
);

    assign clk_prbsgen = 0;
    assign dout_p = 0;
    assign dout_n = 0;

    genvar ii;
    generate
        for (ii=0; ii<Nout; ii=ii+1) begin
            assign tx.pm_out_pi[ii] = 0;
            assign tx.Qperi[ii] = 0;
            assign tx.max_sel_mux[ii] = 0;
        end
    endgenerate

    assign tx.cal_out_pi = 0;

endmodule

`default_nettype wire
