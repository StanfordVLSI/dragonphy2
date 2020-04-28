module V2T_clock_gen_S2D (input in, output out, output outb);

    inv_1_fixed iV2T_fixeder_n_inv2 (.in(in), .out(mid_n_1));
    inv_2_fixed iV2T_fixeder_n_inv1 (.in(mid_n_1), .out(mid_n_2));
    inv_3_fixed iV2T_fixeder_n_inv0 (.in(mid_n_2), .out(outb));

    inv_1_fixed iV2T_fixeder_p_inv1 (.in(in), .out(mid_p_1));
    inv_3_fixed iV2T_fixeder_p_inv0 (.in(mid_p_1), .out(out));

    inv_4_fixed iV2T_fixeder_xc_inv0 (.in(mid_n_2), .out(mid_p_1));
    inv_4_fixed iV2T_fixeder_xc_inv1 (.in(mid_p_1), .out(mid_n_2));

endmodule


