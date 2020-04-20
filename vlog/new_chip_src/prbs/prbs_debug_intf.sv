interface prbs_debug_intf;

	import const_pack::*;

    logic [1:0] prbs_checker_mode;
    logic [Nprbs-1:0] prbs_init_vals [Nti-1:0];
    logic [31:0] prbs_correct_bits_upper;
    logic [31:0] prbs_correct_bits_lower;
    logic [31:0] prbs_total_bits_upper;
    logic [31:0] prbs_total_bits_lower;
    logic [$clog2(Nti)-1:0] prbs_rx_shift;

    modport prbs (
	    input prbs_checker_mode,
	    input prbs_init_vals,
	    output prbs_correct_bits_upper,
	    output prbs_correct_bits_lower,
	    output prbs_total_bits_upper,
	    output prbs_total_bits_lower,
	    output prbs_rx_shift
    );

    modport jtag (
	    output prbs_checker_mode,
	    output prbs_init_vals,
	    input prbs_correct_bits_upper,
	    input prbs_correct_bits_lower,
	    input prbs_total_bits_upper,
	    input prbs_total_bits_lower,
	    input prbs_rx_shift
    );

endinterface
