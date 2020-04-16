module phase_blender #(
  parameter integer Nblender = 4
) (
    input [1:0] ph_in,
    input [2**Nblender-1:0] thm_sel_bld,
    output ph_out
);
endmodule