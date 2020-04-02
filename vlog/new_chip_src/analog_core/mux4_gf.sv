module mux4_gf ( out, en_gf, in,  sel );

input  en_gf;
input [1:0]  sel;
input [3:0]  in;
output  out;

reg  [1:0] sel_retimed;
wire [1:0] sel_mux;
wire out_d;

mux4 imux4_dont_touch (.in(in), .sel(sel_mux), .out(out));

always @(posedge out_d or negedge en_gf) begin
  if(!en_gf) sel_retimed <= 2'b00;
  else sel_retimed <= sel;
end

del_PI idel_PI_dont_touch (.in(out), .out(out_d)); 

assign sel_mux = en_gf ? sel_retimed : sel;

endmodule







