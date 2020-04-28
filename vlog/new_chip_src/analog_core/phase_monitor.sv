
module phase_monitor (
  input ph_ref,  //  reference phase
  input ph_in,  //  input phase to be measured
  input [1:0] sel_sign,
  input clk_async,  // acynchronous clock
  input en_pm,	//enable phase monitor
  output reg [19:0] pm_out    // output of phase monitor
);

reg [2:0] en_pm_d;
logic [20:0] cntr;
reg ff_in;
reg ff_ref;
wire en_sync;
wire xor_ref, xor_in;
wire xor_ref_bf;


assign en_sync = en_pm & en_pm_d[2];

// create synchronous reset 
always @(posedge xor_ref_bf, negedge en_pm) 
  if (!en_pm) en_pm_d <= 3'b0;
  else en_pm_d <= {en_pm_d[1:0], 1'b1};


always @(posedge xor_ref_bf, negedge en_sync)
  if (!en_sync) begin
    cntr <= '0;
    pm_out <= '0;
 
  end  else if (cntr < 2**20) begin
    cntr <= cntr + 1;
    pm_out <= pm_out + (ff_in^ff_ref);
  end

phase_monitor_sub iPM_sub (
	.ph_ref(ph_ref),
	.ph_in(ph_in),
	.en_sync(en_sync),
	.clk_async(clk_async),
	.sel_sign(sel_sign),
	.ff_in(ff_in),
	.ff_ref(ff_ref),
	.xor_ref_bf(xor_ref_bf)
);

endmodule


