`include "mLingua_pwl.vh"

module sine_stim import const_pack::*; #(
	parameter real Vcm = 0.25,
	parameter real sine_freq = 161e6,
	parameter real sine_ampl = 0.2,
	parameter real etol = 0.0003
) (
	output pwl ch_outp,
	output pwl ch_outn
);

	pwl_cos #(
		.etol(etol),
		.freq(sine_freq),
		.amp(+sine_ampl),
		.offset(Vcm)
	) icos_pwlp(
		.out(ch_outp)
	);

	pwl_cos #(
		.etol(etol),
		.freq(sine_freq),
		.amp(-sine_ampl),
		.offset(Vcm)
	) icos_pwln(
		.out(ch_outn)
	);

endmodule