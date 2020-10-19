interface tx_data_intf;

	import const_pack::*;

    logic [2:0] tx_data_gen_mode;
    logic tx_data_gen_cke;
    logic [15:0] tx_data_gen_per;
    logic tx_data_gen_semaphore;
    logic [(Nti-1):0] tx_data_gen_register;

    logic [(Nprbs-1):0] tx_prbs_gen_init [(Nti-1):0];
    logic [(Nprbs-1):0] tx_prbs_gen_eqn;
    logic [(Nti-1):0] tx_prbs_gen_inj_err;
    logic [1:0] tx_prbs_gen_chicken;

    modport tx_data (
        input tx_data_gen_mode,
        input tx_data_gen_cke,
        input tx_data_gen_per,
        input tx_data_gen_semaphore,
        input tx_data_gen_register,
        input tx_prbs_gen_init,
        input tx_prbs_gen_eqn,
        input tx_prbs_gen_inj_err,
        input tx_prbs_gen_chicken
    );

    modport jtag (
        output tx_data_gen_mode,
        output tx_data_gen_cke,
        output tx_data_gen_per,
        output tx_data_gen_semaphore,
        output tx_data_gen_register,
        output tx_prbs_gen_init,
        output tx_prbs_gen_eqn,
        output tx_prbs_gen_inj_err,
        output tx_prbs_gen_chicken
    );
endinterface
