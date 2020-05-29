`include "mLingua_pwl.vh"

`default_nettype none

module tx_stim
	import const_pack::*;
	import test_pack::*; 
#(
	parameter real RJrms = 1e-12,		// random clock jitter
	parameter real DJmax = 5e-12,		// deterministic clock jitter
	parameter real amp = 0.4,
	parameter real wtap1 = -0.2,
	parameter real wtap0 = 0.8,
	parameter real tr = 10e-12,
	parameter real Vcm = 0.25,
	parameter real etol=0.001,
	parameter skew_cal = 0
) (
	output pwl ch_outp,
	output pwl ch_outn
);

	// generate TX clock

	logic tx_clk;

	clock #(
		.freq(full_rate),
		.duty(0.5),
		.td(0)
	) iTXCLK (
		.ckout(tx_clk)
	); 

	// generate TX data

	logic tx_data;

	generate
		if (skew_cal == 1) begin
			// 8Ghz periodic input data
			clock #(
				.freq(full_rate/2),
				.duty(0.5),
				.td(30e-12)
			) iTXDATA (
				.ckout(tx_data)
			);
		end else begin
			logic rst;
			
			initial begin
				rst = 'b1;
				#(1ns);
				rst = 'b0;
			end

			prbs21 xprbs (
				.clk(tx_clk),
				.rst(rst),
				.out(tx_data)
			);
		end
	endgenerate

	// TX drivers (without zero common-mode)

	pwl tx_outp1;
	pwl tx_outn1;

	tx_driver #(
		.amp(+amp),
		.wtap1(wtap1),
		.wtap0(wtap0),
		.tr(tr)
	) iTXp (
		.in(tx_data),
		.clk(tx_clk),
		.out(tx_outp1)
	);

	tx_driver #(
		.amp(-amp),
		.wtap1(wtap1),
		.wtap0(wtap0),
		.tr(tr)
	) iTXn (
		.in(tx_data),
		.clk(tx_clk),
		.out(tx_outn1)
	);

	// add common mode

	pwl Vcm_pwl;
	pwl tx_outp;
	pwl tx_outn;

	initial begin
		Vcm_pwl = pm.write(Vcm, 0, 0);
	end
	
	pwl_add2 iaddp (
		.enable(1'b1),
		.in1(tx_outp1),
		.in2(Vcm_pwl),
		.scale1(1.0),
		.scale2(1.0),
		.out(tx_outp)
	);

	pwl_add2 iaddn (
		.enable(1'b1),
		.in1(tx_outn1),
		.in2(Vcm_pwl),
		.scale1(1.0),
		.scale2(1.0),
		.out(tx_outn)
	);

	// channel

	channel #(
		.etol(etol)
	) iCHp (
		.in(tx_outp),
		.out(ch_outp)
	);

	channel #(
		.etol(etol)
	) iCHn (
		.in(tx_outn),
		.out(ch_outn)
	);

endmodule 

`default_nettype wire