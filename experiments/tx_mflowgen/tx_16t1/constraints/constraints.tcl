# Modified from ButterPHY and Garnet constraints

set_load -pin_load $ADK_TYPICAL_ON_CHIP_LOAD [all_outputs]

set_driving_cell -no_design_rule \
  -lib_cell $ADK_DRIVING_CELL [all_inputs]

set_max_fanout 20 $dc_design_name

set T 0.5

set T0 [expr {0.00*$T}]
set T1 [expr {0.25*$T}]
set T2 [expr {0.50*$T}]
set T3 [expr {0.75*$T}]
set T4 [expr {1.00*$T}]
set T5 [expr {1.25*$T}]

set TR_4X [expr {0.025*$T}]
set TR [expr {0.1*$T}]
set TR_HR [expr {0.2*$T}]
set TR_QR [expr {0.4*$T}]

create_clock -name clk_tx_pi_0 \
    -period $T \
    -waveform "$T0 $T2" \
    [get_ports {clk_interp_slice[0]}]

create_clock -name clk_tx_pi_1 \
    -period $T \
    -waveform "$T1 $T3" \
    [get_ports {clk_interp_slice[1]}]

create_clock -name clk_tx_pi_2 \
    -period $T \
    -waveform "$T2 $T4" \
    [get_ports {clk_interp_slice[2]}]

create_clock -name clk_tx_pi_3 \
    -period $T \
    -waveform "$T3 $T5" \
    [get_ports {clk_interp_slice[3]}]

# Half-rate and quarter-rate clocks

create_generated_clock -name clk_tx_hr \
    -source [get_pins div0/clkin] \
    -divide_by 2 \
    [get_pins div0/clkout]

create_generated_clock -name clk_tx_qr \
    -source [get_pins div1/clkin] \
    -divide_by 2 \
    [get_pins div1/clkout]

# External inputs
set_false_path -through [get_ports {din* rst}]

# Internal nets
set_dont_touch [get_nets "qr_data_p"]
set_dont_touch [get_nets "qr_data_n"]

# Muxes
for {set i 0} {$i < 2} {incr i} {
    # Half-rate muxes (the mux is intentionally left out because
    # there is a mapping problem for FreePDK45
    for {set j 1} {$j < 5} {incr j} {
        set_dont_touch [get_nets "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hd"]

        # multipath constraint from quarter-rate to half-rate muxes
        for {set k 0} {$k < 2} {incr k} {
            set_multicycle_path \
                1 \
                -setup \
                -end \
                -from [get_pins "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/mux_0/sel"] \
                -to [get_pins "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_2/dff_$k/D"]

            set_multicycle_path \
                0 \
                -hold \
                -end \
                -from [get_pins "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/mux_0/sel"] \
                -to [get_pins "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_2/dff_$k/D"]
        }

        # dont_touch nets within each 2t1 mux
        for {set k 0} {$k < 3} {incr k} {
            set_dont_touch [get_nets "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/D0L"]
            set_dont_touch [get_nets "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/D1M"]
            set_dont_touch [get_nets "hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/L0M"]
        }
    }

    # Quarter-rate muxes
    set_dont_touch [get_nets "qr_mux_4t1_$i/D0DQ"]
    set_dont_touch [get_nets "qr_mux_4t1_$i/D0DI"]
    set_dont_touch [get_nets "qr_mux_4t1_$i/D0DQB"]
    set_dont_touch [get_nets "qr_mux_4t1_$i/D1DQB"]
    set_dont_touch [get_nets "qr_mux_4t1_$i/D0DIB"]
    set_dont_touch [get_nets "qr_mux_4t1_$i/D1DIB"]

    ####################
    # Multicycle paths #
    ####################
 
    # all are launched on clk_tx_hr, which is
    # divided by two from clk_tx_pi_2 (QB)

    # din[0]: captured on I @ dff_IB0

    set_multicycle_path \
        1 \
        -setup \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[1].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_IB0/D"]

    set_multicycle_path \
        0 \
        -hold \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[1].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_IB0/D"]

    # din[1]: captured on Q @ dff_QB0

    set_multicycle_path \
        1 \
        -setup \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[2].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_QB0/D"]

    set_multicycle_path \
        0 \
        -hold \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[2].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_QB0/D"]

    # din[2]: captured on I @ dff_I0

    set_multicycle_path \
        1 \
        -setup \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[3].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_I0/D"]

    set_multicycle_path \
        0 \
        -hold \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[3].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_I0/D"]

    # din[3]: captured on Q @ dff_Q0

    set_multicycle_path \
        1 \
        -setup \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[4].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_Q0/D"]

    set_multicycle_path \
        0 \
        -hold \
        -end \
        -from [get_pins "hr_mux_16t4_$i/iMUX[4].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \
        -to [get_pins "qr_mux_4t1_$i/dff_Q0/D"]
}

# Tighten transition constraint for clocks declared so far
set_max_transition $TR_HR -clock_path [get_clock clk_tx_hr]
set_max_transition $TR_QR -clock_path [get_clock clk_tx_qr]

# Set transition times in the transmitter

# Mux +
set_max_transition $TR [get_pin {qr_mux_4t1_0/din[0]}]
set_max_transition $TR [get_pin {qr_mux_4t1_0/din[1]}]
set_max_transition $TR [get_pin {qr_mux_4t1_0/din[2]}]
set_max_transition $TR [get_pin {qr_mux_4t1_0/din[3]}]
set_max_transition $TR_4X [get_pin {qr_mux_4t1_0/data}]

# Mux -
set_max_transition $TR [get_pin {qr_mux_4t1_1/din[0]}]
set_max_transition $TR [get_pin {qr_mux_4t1_1/din[1]}]
set_max_transition $TR [get_pin {qr_mux_4t1_1/din[2]}]
set_max_transition $TR [get_pin {qr_mux_4t1_1/din[3]}]
set_max_transition $TR_4X [get_pin {qr_mux_4t1_1/data}]

# #Buffer
# set_max_transition $TR_4X [get_pin {buf1/i_term_n/VinP}]
# set_max_transition $TR_4X [get_pin {buf1/i_term_n/VinN}]
# set_max_transition $TR_4X [get_pin {buf1/i_term_p/VinP}]
# set_max_transition $TR_4X [get_pin {buf1/i_term_p/VinN}]