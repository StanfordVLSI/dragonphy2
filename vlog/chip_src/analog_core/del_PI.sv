
module del_PI (input in, input en, output out );
wire mid;

// synopsys dc_script_begin
// set_dont_touch {mid}
// synopsys dc_script_end

n_and_PI_1_fixed in_and_PI1_dont_touch (.in1(in), .in2(en), .out(mid));
inv_PI_2_fixed iinv_PI2_dont_touch (.in(mid), .out(out));
endmodule

