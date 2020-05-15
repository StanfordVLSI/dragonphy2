interface prbs_debug_intf;

	import const_pack::*;

    logic prbs_cke;
    logic [(Nprbs-1):0] prbs_eqn;
    logic [(Nti-1):0] prbs_chan_sel;
    logic [1:0] prbs_inv_chicken;
    logic [1:0] prbs_checker_mode;

    logic [31:0] prbs_err_bits_upper;
    logic [31:0] prbs_err_bits_lower;
    logic [31:0] prbs_total_bits_upper;
    logic [31:0] prbs_total_bits_lower;

    logic prbs_gen_cke;
    logic [(Nprbs-1):0] prbs_gen_init;
    logic [(Nprbs-1):0] prbs_gen_eqn;
    logic prbs_gen_inj_err;
    logic [1:0] prbs_gen_chicken;

    modport prbs (
        input prbs_cke,
        input prbs_eqn,
        input prbs_chan_sel,
        input prbs_inv_chicken,
        input prbs_checker_mode,
        output prbs_err_bits_upper,
        output prbs_err_bits_lower,
        output prbs_total_bits_upper,
        output prbs_total_bits_lower,
        input prbs_gen_cke,
        input prbs_gen_init,
        input prbs_gen_eqn,
        input prbs_gen_inj_err,
        input prbs_gen_chicken
    );

    modport jtag (
        output prbs_cke,
        output prbs_eqn,
        output prbs_chan_sel,
        output prbs_inv_chicken,
        output prbs_checker_mode,
        input prbs_err_bits_upper,
        input prbs_err_bits_lower,
        input prbs_total_bits_upper,
        input prbs_total_bits_lower,
        output prbs_gen_cke,
        output prbs_gen_init,
        output prbs_gen_eqn,
        output prbs_gen_inj_err,
        output prbs_gen_chicken
    );
endinterface
