module phase_monitor (
    input wire logic ph_ref,            // reference phase
    input wire logic ph_in,             // input phase to be measured
    input wire logic [1:0] sel_sign,
    input wire logic clk_async,         // asynchronous clock
    input wire logic en_pm,	            // enable phase monitor
    output reg [19:0] pm_out            // output of phase monitor
);

reg [2:0] en_pm_d;
reg [20:0] cntr;
reg ff_in;
reg ff_ref;
wire en_sync;
wire xor_ref, xor_in;
wire xor_ref_bf;

assign en_sync = en_pm & en_pm_d[2];

// create synchronous reset 
always @(posedge xor_ref_bf, negedge en_pm) begin
    if (!en_pm) begin
        en_pm_d <= 3'b0;
    end else begin
        en_pm_d <= {en_pm_d[1:0], 1'b1};
    end
end

always @(negedge xor_ref_bf, negedge en_sync) begin
    if (!en_sync) begin
        cntr <= '0;
        pm_out <= '0;
    end else if (cntr < 2**20) begin
        cntr <= cntr + 1;
        pm_out <= pm_out + (ff_in^ff_ref);
    end
end

phase_monitor_sub uPMSUB (
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
