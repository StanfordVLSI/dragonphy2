module V2T_clock_gen_S2D (input in, output out, output outb);

    inv_v2t_1_fixed iV2T_fixed_n_inv2 (.in(in), .out(mid_n_1));
    inv_v2t_2_fixed iV2T_fixed_n_inv1 (.in(mid_n_1), .out(mid_n_2));
    inv_v2t_3_fixed iV2T_fixed_n_inv0 (.in(mid_n_2), .out(outb));

    inv_v2t_2_fixed iV2T_fixed_p_inv1 (.in(in), .out(mid_p_1));
    inv_v2t_3_fixed iV2T_fixed_p_inv0 (.in(mid_p_1), .out(out));

    inv_v2t_1_fixed iV2T_fixed_xc_inv0 (.in(mid_n_2), .out(mid_p_1));
    inv_v2t_1_fixed iV2T_fixed_xc_inv1 (.in(mid_p_1), .out(mid_n_2));

endmodule


