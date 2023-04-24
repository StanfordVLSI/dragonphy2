module fast_square (
    input logic signed [8:0] a,

    output logic [17:0] sqr_a
);
    
    logic [8:0] abs_a, abs_mskd_a;
    logic sign;
    logic [3:0] lod_pos;

    assign sign = a[8];
    assign abs_a = $unsigned(sign ? -a : a);

    leading_one_detector lod (
        .value(abs_a),
        .leading_one_position(lod_pos),
        .masked_value(abs_mskd_a)
    );

    always_comb begin
        sqr_a = ((3*(abs_mskd_a + sign)) << lod_pos) + (1 << (lod_pos << 1));
    end

endmodule