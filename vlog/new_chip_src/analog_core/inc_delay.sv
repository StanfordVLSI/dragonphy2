module inc_delay (
    input in,
    input inc_del,
    output out
);

assign inc_delb =  ~inc_del;

tri_buff itri_buff1(.in(in), .out(out), .en(inc_delb));
tri_buff itri_buff2(.in(in), .out(out), .en(1'b1));

endmodule




