interface hist_debug_intf;

	import const_pack::*;

    // histogram inputs
    logic [2:0] hist_mode;
    logic hist_sram_ceb;
    logic [(Nadc-1):0] hist_addr;
    logic [1:0] hist_source; // 2'b00: ADC, 2'b01: FFE, 2'b10: unused, 2'b11: BIST
    logic [4:0] hist_src_idx; // 0-17 index for ADC, FFE (i.e., includes replicas)

    // data generator inputs
    logic [2:0] data_gen_mode;
    logic [(Nadc-1):0] data_gen_in_0;
    logic [(Nadc-1):0] data_gen_in_1;

    // histogram outputs
    logic [31:0] hist_count_upper;
    logic [31:0] hist_count_lower;
    logic [31:0] hist_total_upper;
    logic [31:0] hist_total_lower;

    modport hist (
        input hist_mode,
        input hist_sram_ceb,
        input hist_addr,
        input hist_source,
        input hist_src_idx,
        input data_gen_mode,
        input data_gen_in_0,
        input data_gen_in_1,
        output hist_count_upper,
        output hist_count_lower,
        output hist_total_upper,
        output hist_total_lower
    );

    modport jtag (
        output hist_mode,
        output hist_sram_ceb,
        output hist_addr,
        output hist_source,
        output hist_src_idx,
        output data_gen_mode,
        output data_gen_in_0,
        output data_gen_in_1,
        input hist_count_upper,
        input hist_count_lower,
        input hist_total_upper,
        input hist_total_lower
    );
endinterface
