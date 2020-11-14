import os
from pathlib import Path

OUTPUT_FILE = 'constraints.tcl'

design_name = os.environ['design_name']
time_scale = float(os.environ['constr_time_scale'])
cap_scale = float(os.environ['constr_cap_scale'])
main_per = float(os.environ['constr_main_per'])
clk_4x_per = 0.25*main_per*time_scale

output = ''

output += f'''
# Modified from ButterPHY and Garnet constraints

############
# Main clock
############

# Frequency is 1.4 GHz (40% above nominal) 
# For timining analysis, the IO of analog core is considered to be clocked on 
# ext_clk (input) rather than clk_adc (output).  Hence the ext_clk signal is 
# declared to have the same frequency as clk_adc.  This should be OK because there
# is no synthesized logic that actually runs on ext_clk, and the ext_clk transition
# time is set to be very fast later in this constraints file.
create_clock -name clk_main_buf \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pin ibuf_main/clk]
create_clock -name clk_retimer \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pins iacore/clk_adc]
    
#################
# Input buffers #
#################

# ibuf_async

create_clock -name clk_async \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pins ibuf_async/clk]

# ibuf_main already covered above...

# ibuf_mdll_ref

create_clock -name clk_mdll_ref_p \\
    -period {clk_4x_per} \\
    -waveform {{0 {0.5*clk_4x_per}}} \\
    [get_pins ibuf_mdll_ref/clk]

create_clock -name clk_mdll_ref_n \\
    -period {clk_4x_per} \\
    -waveform {{0 {0.5*clk_4x_per}}} \\
    [get_pins ibuf_mdll_ref/clk_b]

# ibuf_mdll_mon

create_clock -name clk_mdll_mon_p \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pins ibuf_mdll_mon/clk]

create_clock -name clk_mdll_mon_n \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pins ibuf_mdll_mon/clk_b]

##############
# MDLL clock #
##############

create_clock -name clk_mdll \\
    -period {clk_4x_per} \\
    -waveform {{0 {0.5*clk_4x_per}}} \\
    [get_pins imdll/clk_0]

#############
# TX clocks #
#############

# Input divider

create_clock -name clk_tx_indiv \\
    -period {clk_4x_per} \\
    -waveform {{0 {0.5*clk_4x_per}}} \\
    [get_pins itx/indiv/out]

# PI outputs

create_clock -name clk_tx_pi_0 \\
    -period {clk_4x_per} \\
    -waveform {{0 {0.5*clk_4x_per}}} \\
    [get_pins itx/iPI[0].iPI/clk_out_slice]

create_clock -name clk_tx_pi_1 \\
    -period {clk_4x_per} \\
    -waveform {{{0.25*clk_4x_per} {0.75*clk_4x_per}}} \\
    [get_pins itx/iPI[1].iPI/clk_out_slice]

create_clock -name clk_tx_pi_2 \\
    -period {clk_4x_per} \\
    -waveform {{{0.5*clk_4x_per} {clk_4x_per}}} \\
    [get_pins itx/iPI[2].iPI/clk_out_slice]

create_clock -name clk_tx_pi_3 \\
    -period {clk_4x_per} \\
    -waveform {{{0.75*clk_4x_per} {1.25*clk_4x_per}}} \\
    [get_pins itx/iPI[3].iPI/clk_out_slice]

# Half-rate and quarter-rate clocks

create_generated_clock -name clk_tx_hr \\
    -source [get_pins itx/div0/clkin] \\
    -divide_by 2 \\
    [get_pins itx/div0/clkout]

create_generated_clock -name clk_tx_qr \\
    -source [get_pins itx/div1/clkin] \\
    -divide_by 2 \\
    [get_pins itx/div1/clkout]

#####################
# clock uncertainty #
#####################

# clk_retimer
set_clock_uncertainty -setup 0.03 clk_retimer
set_clock_uncertainty -hold 0.03 clk_retimer

# clk_tx_pi
set_clock_uncertainty -setup 0.01 clk_tx_pi_0
set_clock_uncertainty -hold 0.01 clk_tx_pi_0
set_clock_uncertainty -setup 0.01 clk_tx_pi_1
set_clock_uncertainty -hold 0.01 clk_tx_pi_1
set_clock_uncertainty -setup 0.01 clk_tx_pi_2
set_clock_uncertainty -hold 0.01 clk_tx_pi_2
set_clock_uncertainty -setup 0.01 clk_tx_pi_3
set_clock_uncertainty -hold 0.01 clk_tx_pi_3

# half rate
set_clock_uncertainty -setup 0.02 clk_tx_hr
set_clock_uncertainty -hold 0.02 clk_tx_hr

# quarter rate
set_clock_uncertainty -setup 0.03 clk_tx_qr
set_clock_uncertainty -hold 0.03 clk_tx_qr

################
# JTAG interface
################

# These numbers come from looking at datasheets for JTAG cables
# https://www.analog.com/media/en/technical-documentation/application-notes/ee-68.pdf
# https://www2.lauterbach.com/pdf/arm_app_jtag.pdf

# TCK clock signal: 20 MHz max
create_clock -name clk_jtag -period 50.0 [get_ports jtag_intf_i.phy_tck]
set_clock_uncertainty -setup 0.03 clk_jtag
set_clock_uncertainty -hold 0.03 clk_jtag

# TCK constraints
set_input_transition 0.5 [get_port jtag_intf_i.phy_tck]

# timing constraints for TDI (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_transition 0.5 [get_port jtag_intf_i.phy_tdi]
set_input_delay -clock clk_jtag -max 0.5 -clock_fall [get_port jtag_intf_i.phy_tdi]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_port jtag_intf_i.phy_tdi]

# timing constraints for TMS (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_transition 0.5 [get_port jtag_intf_i.phy_tms]
set_input_delay -clock clk_jtag -max 5.0 -clock_fall [get_port jtag_intf_i.phy_tms]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_port jtag_intf_i.phy_tms]

# timing constraints for TDO (setup time 12.5 ns, hold time 0.0)
# TDO changes on the falling edge of TCK but is sampled on the rising edge
set_output_delay -clock clk_jtag -max 12.5 [get_port jtag_intf_i.phy_tdo]
set_output_delay -clock clk_jtag -min 0.0 [get_port jtag_intf_i.phy_tdo]

# TRST_N is asynchronous
set_input_transition 0.5 [get_port jtag_intf_i.phy_trst_n]

############################
# Asynchronous clock domains
############################

set_clock_groups -asynchronous \\
    -group {{ clk_jtag }} \\
    -group {{ \\
        clk_tx_pi_0 \\
        clk_tx_pi_1 \\
        clk_tx_pi_2 \\
        clk_tx_pi_3 \\
        clk_tx_hr \\
        clk_tx_qr \\
    }} \\
    -group {{ clk_retimer clk_main_buf }} \\
    -group {{ clk_async }} \\
    -group {{ clk_mdll_ref_p clk_mdll_ref_n }} \\
    -group {{ clk_mdll_mon_p clk_mdll_mon_n }} \\
    -group {{ clk_mdll }} \\
    -group {{ clk_tx_indiv }}
 
####################
# Other external I/O
####################

# external analog inputs

set ext_dont_touch_false_path {{ \\
    ext_rx_inp \\
    ext_rx_inn \\
    ext_Vcm \\
    ext_Vcal \\
    ext_rx_inp_test \\
    ext_rx_inn_test \\
    ext_tx_outp \\
    ext_tx_outn \\
    ext_clk_async_p \\
    ext_clk_async_n \\
    ext_clkp \\
    ext_clkn \\
    ext_mdll_clk_refp \\
    ext_mdll_clk_refn \\
    ext_mdll_clk_monp \\
    ext_mdll_clk_monn \\
    clk_out_p \\
    clk_out_n \\
    clk_trig_p \\
    clk_trig_n \\
}}

set_dont_touch_network [get_ports $ext_dont_touch_false_path]
set_false_path -through [get_ports $ext_dont_touch_false_path]

set ext_false_path_only {{ \\
    ext_rstb \\
    ext_dump_start \\
    clk_cgra \\
    ramp_clock \\
    freq_lvl_cross \\
}}

set_false_path -through [get_ports $ext_false_path_only]

###################
# Top-level buffers
###################

# IOs are all false paths
set_false_path -through [get_pins ibuf_*/*]

# Input buffer inputs (which are external pins)
# should not have buffers added
set_dont_touch_network [get_pins ibuf_*/in*]

#############
# Analog core
#############

# Debugging signals are all false paths
set_false_path -through [get_pins iacore/adbg_intf_i.*]

# Clock outputs in the debug interface should not have buffers added
set adbg_clk_pins [get_pins {{ \\
    iacore/adbg_intf_i.del_out_pi \\
    iacore/adbg_intf_i.pi_out_meas* \\
    iacore/adbg_intf_i.del_out_rep* \\
    iacore/adbg_intf_i.inbuf_out_meas \\
}}]

#############
# Transmitter
#############

# Debugging signals are all false paths
set_false_path -through [get_pins itx/tx.*]

# Clock outputs in the debug interface should not have buffers added
set tdbg_clk_pins [get_pins {{ \\
    itx/*del_out_pi* \\
    itx/*pi_out_meas* \\
    itx/*inbuf_out_meas* \\
}}]
set_dont_touch_network $tdbg_clk_pins

# TODO: do we need to set dont_touch through the hierarchy?
# Or will it be applied automatically to instances within?

# Phase interpolators
for {{set i 0}} {{$i < 4}} {{incr i}} {{
    set_dont_touch [get_cells "itx/iPI[$i].iPI"]
}}

# Input divider
set_dont_touch [get_cells itx/indiv]

# Internal nets
set_dont_touch [get_nets "itx/qr_data_p"]
set_dont_touch [get_nets "itx/qr_data_n"]
set_dont_touch [get_nets "itx/mtb_n"]
set_dont_touch [get_nets "itx/mtb_p"]

# Muxes
for {{set i 0}} {{$i < 2}} {{incr i}} {{
    # Half-rate muxes (the mux is intentionally left out because
    # there is a mapping problem for FreePDK45
    for {{set j 1}} {{$j < 5}} {{incr j}} {{
        set_dont_touch [get_nets "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hd"]

        # multipath constraint from quarter-rate to half-rate muxes
        for {{set k 0}} {{$k < 2}} {{incr k}} {{
            set_multicycle_path \\
                1 \\
                -setup \\
                -end \\
                -from [get_pins "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/mux_0/sel"] \\
                -to [get_pins "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_2/dff_$k/D"]

            set_multicycle_path \\
                0 \\
                -hold \\
                -end \\
                -from [get_pins "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/mux_0/sel"] \\
                -to [get_pins "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_2/dff_$k/D"]
        }}

        # dont_touch nets within each 2t1 mux
        for {{set k 0}} {{$k < 3}} {{incr k}} {{
            set_dont_touch [get_nets "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/D0L"]
            set_dont_touch [get_nets "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/D1M"]
            set_dont_touch [get_nets "itx/hr_mux_16t4_$i/iMUX[$j].mux_4t1/hr_2t1_mux_$k/L0M"]
        }}
    }}

    # Quarter-rate muxes
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/D0DQ"]
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/D0DI"]
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/D0DQB"]
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/D1DQB"]
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/D0DIB"]
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/D1DIB"]
    set_dont_touch [get_nets "itx/qr_mux_4t1_$i/mux_out"]

    ####################
    # Multicycle paths #
    ####################
 
    # all are launched on clk_tx_hr, which is
    # divided by two from clk_tx_pi_2 (QB)

    # din[0]: captured on I @ dff_IB0

    set_multicycle_path \\
        1 \\
        -setup \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[1].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_IB0/D"]

    set_multicycle_path \\
        0 \\
        -hold \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[1].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_IB0/D"]

    # din[1]: captured on Q @ dff_QB0

    set_multicycle_path \\
        1 \\
        -setup \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[2].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_QB0/D"]

    set_multicycle_path \\
        0 \\
        -hold \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[2].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_QB0/D"]

    # din[2]: captured on I @ dff_I0

    set_multicycle_path \\
        1 \\
        -setup \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[3].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_I0/D"]

    set_multicycle_path \\
        0 \\
        -hold \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[3].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_I0/D"]

    # din[3]: captured on Q @ dff_Q0

    set_multicycle_path \\
        1 \\
        -setup \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[4].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_Q0/D"]

    set_multicycle_path \\
        0 \\
        -hold \\
        -end \\
        -from [get_pins "itx/hr_mux_16t4_$i/iMUX[4].mux_4t1/hr_2t1_mux_2/mux_0/sel"] \\
        -to [get_pins "itx/qr_mux_4t1_$i/dff_Q0/D"]
'''

if os.environ['adk_name'] == 'tsmc16':
    output += f'''
    set_dont_touch [get_cells "itx/qr_mux_4t1_$i/mux_4/mux_4_fixed"]
'''

output += f'''
    for {{set j 0}} {{$j < 4}} {{incr j}} {{
        set_dont_touch [get_cells "itx/qr_mux_4t1_$i/i_INVBUF[$j].inv_buf/inv_4_fixed"]
    }}    
}}

# Output buffer
for {{set i 0}} {{$i < 2}} {{incr i}} {{
    set_dont_touch [get_cells "itx/buf1/iBUF[$i].i_tri_buf_n/tri_buf"]
    set_dont_touch [get_cells "itx/buf1/iBUF[$i].i_tri_buf_p/tri_buf"]
    set_false_path -through [get_pins -of_objects "itx/buf1/iBUF[$i].i_tri_buf_n/tri_buf"]
    set_false_path -through [get_pins -of_objects "itx/buf1/iBUF[$i].i_tri_buf_p/tri_buf"]
}}
set_dont_touch [get_nets "itx/buf1/BTN"]
set_dont_touch [get_nets "itx/buf1/BTP"]
set_dont_touch [get_cells "itx/buf1/i_term_n"]
set_dont_touch [get_cells "itx/buf1/i_term_p"]

# Make sure termination resistor is wired up
set_dont_touch [get_pins "itx/buf1/DOUTP"]
set_dont_touch [get_pins "itx/buf1/DOUTN"]
set_dont_touch [get_pins "itx/dout_p"]
set_dont_touch [get_pins "itx/dout_n"]

# Set a false path on the termination resistors to avoid
# a combinational loop error
set_false_path -through [get_pins -of_objects "itx/buf1/i_term_n"]
set_false_path -through [get_pins -of_objects "itx/buf1/i_term_p"]

# Make sure the transmitter is not retimed.  This may already be in
# the main DC step, but it's not clear that it's being applied.
set_dont_retime [get_cells itx]

######
# MDLL
######

# IOs for MDLL are all false paths
set_false_path -through [get_pins -of_objects imdll]

# Unused clock IOs should not have buffers added
set_dont_touch_network [get_pins imdll/clk_90]
set_dont_touch_network [get_pins imdll/clk_180]
set_dont_touch_network [get_pins imdll/clk_270]

################
# Output buffer
################

# IOs for output buffers are all false paths
set_false_path -through [get_pins -of_objects idcore/out_buff_i]

# Clock outputs should not have buffers added
set_dont_touch_network [get_pins idcore/out_buff_i/clock_out_*]
set_dont_touch_network [get_pins idcore/out_buff_i/trigg_out_*]

#################
# Net constraints
#################

# specify defaults for all nets
set_driving_cell -no_design_rule -lib_cell $ADK_DRIVING_CELL [all_inputs]
set_max_transition {0.2*time_scale} [current_design]
set_max_capacitance {0.1*cap_scale} [current_design]
set_max_fanout 20 {design_name}

# specify loads for outputs
set_load {0.1*cap_scale} [all_outputs]

# change the max capacitance for ext_Vcal only
# it's inout, so the previous "set_load"
# command appears to apply to it as well
set_max_capacitance {1.0*cap_scale} [get_port ext_Vcal]

# Tighten transition constraint for clocks declared so far
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_jtag]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_retimer]
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_tx_indiv]
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_tx_pi_0]
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_tx_pi_1]
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_tx_pi_2]
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_tx_pi_3]
set_max_transition {0.05*time_scale} -clock_path [get_clock clk_tx_hr]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_tx_qr]

# Set transition time for high-speed signals monitored from iacore
# The transition time is 10% of a 4 GHz period.

set adbg_count 0
foreach x [get_object_name $adbg_clk_pins] {{
    create_clock -name "clk_mon_net_$adbg_count" -period {0.25*time_scale} [get_pin $x]
    set_max_transition {0.025*time_scale} -clock_path [get_clock "clk_mon_net_$adbg_count"]
    incr adbg_count
}}

###################################
# Set transition times at top-level 
###################################

# clk_async
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_async]

# clk_main - cant be lower than 0.017!
set_max_transition {0.017*time_scale} -clock_path [get_clock clk_main_buf]

# MDLL reference
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_mdll_ref_p]
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_mdll_ref_n]

# MDLL monitor
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_mdll_mon_p]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_mdll_mon_n]

# MDLL output
set_max_transition {0.025*time_scale} -clock_path [get_clock clk_mdll]

# Clock going to the CGRA
set_max_transition {0.1*time_scale} [get_pin idcore/clk_cgra]

#########################################
# Set transition times in the transmitter
#########################################

# Mux +
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_0/din[0]}}]
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_0/din[1]}}]
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_0/din[2]}}]
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_0/din[3]}}]
set_max_transition {0.008*time_scale} [get_pin {{itx/qr_mux_4t1_0/data}}]

# Mux -
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_1/din[0]}}]
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_1/din[1]}}]
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_1/din[2]}}]
set_max_transition {0.025*time_scale} [get_pin {{itx/qr_mux_4t1_1/din[3]}}]
set_max_transition {0.008*time_scale} [get_pin {{itx/qr_mux_4t1_1/data}}]

echo [all_clocks]
'''

# process-specific constraints
if os.environ['adk_name'] == 'tsmc16':
    output += f'''
# From ButterPHY

# TODO: what is mvt_target_libs?
# foreach lib $mvt_target_libs {{
#   set_dont_use [file rootname [file tail $lib]]/*D0BWP*
# }}

# From Garnet
# Apparently ANAIOPAD and IOPAD cells don't all have the dont_touch property
# As a result, set the property here if there are any such cells

if {{[llength [get_cells ANAIOPAD*]] > 0}} {{
    set_dont_touch [get_cells ANAIOPAD*]
}}
if {{[llength [get_cells IOPAD*]] > 0}} {{
    set_dont_touch [get_cells IOPAD*]
}}
'''

# create output directory
OUTPUT_DIR = Path('outputs')
OUTPUT_DIR.mkdir(exist_ok=True, parents=True)

# write output text
with open(OUTPUT_DIR / OUTPUT_FILE, 'w') as f:
    f.write(output)
