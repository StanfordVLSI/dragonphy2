module inc_delay (
    input in,
    input inc_del,
    output out
);
 //synopsys dc_script_begin
 //set_dont_touch {out}
 //synopsys dc_script_end

 assign inc_delb =  ~inc_del;

 tri_buff_fixed itri_buff1_dont_touch(.in(in), .out(out), .en(inc_delb));
 tri_buff_fixed itri_buff2_dont_touch(.in(in), .out(out), .en(1'b1));

endmodule




