
module del_PI (input in, output out );
wire mid;

// synopsys dc_script_begin
// set_dont_touch {mid}
// synopsys dc_script_end

inv_PI_1_fixed iinv_PI1_dont_touch (.in(in), .out(mid));
inv_PI_2_fixed iinv_PI2_dont_touch (.in(mid), .out(out));
endmodule

