module mux_network #(
    parameter Nunit = 32,
    parameter Nmux = 5,
    parameter Nblender = 4
)( 
    input en_gf,
    input [Nunit-1:0]  ph_in,
    input [1:0] sel_mux_1st_even [3:0],
    input [1:0] sel_mux_1st_odd [3:0],
    input [1:0] sel_mux_2nd_even,
    input [1:0] sel_mux_2nd_odd,
    output [1:0] ph_out
);
    wire  [7:0]  ph_mid;

    genvar k;
    generate
        for (k=0;k<4;k++) begin:imux4_gf_1st
            mux4_gf even (
                .out(ph_mid[2*k]),
                .in({ph_in[8*k+6], ph_in[8*k+4], ph_in[8*k+2], ph_in[8*k+0]}),
                .sel(sel_mux_1st_even[k]),
                .en_gf(en_gf)
            );
            mux4_gf odd (
                .out(ph_mid[2*k+1]),
                .in({ph_in[8*k+7], ph_in[8*k+5], ph_in[8*k+3], ph_in[8*k+1]}),
                .sel(sel_mux_1st_odd[k]),
                .en_gf(en_gf)
            );
        end
    endgenerate

    mux4_gf imux4_gf_2nd_even (
        .out(ph_out[0]),
        .in({ph_mid[6], ph_mid[4], ph_mid[2], ph_mid[0]}),
        .sel(sel_mux_2nd_even),
        .en_gf(en_gf)
    );

    mux4_gf imux4_gf_2nd_odd (
        .out(ph_out[1]),
        .in({ph_mid[7], ph_mid[5], ph_mid[3], ph_mid[1]}),
        .sel(sel_mux_2nd_odd),
        .en_gf(en_gf)
    );
endmodule

