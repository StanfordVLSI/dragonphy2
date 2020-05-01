
module del_PI (input in, output out );
wire mid;
inv_PI iinv_PI1_dont_touch (.in(in), .out(mid));
inv_PI iinv_PI2_dont_touch (.in(mid), .out(out));
endmodule

