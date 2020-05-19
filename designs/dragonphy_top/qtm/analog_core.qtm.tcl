source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model analog_core

set_qtm_technology -library $::env(qtm_tech_lib)

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_output -value 0.0

create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

############### Port Definitions ###############

### non-interface I/O

create_qtm_port -type input { rx_inp }
set_qtm_port_load -type qtm_load -factor 2 { rx_inp }

create_qtm_port -type input { rx_inn }
set_qtm_port_load -type qtm_load -factor 2 { rx_inn }

create_qtm_port -type input { Vcm }
set_qtm_port_load -type qtm_load -factor 2 { Vcm }

create_qtm_port -type input { rx_inp_test }
set_qtm_port_load -type qtm_load -factor 2 { rx_inp_test }

create_qtm_port -type input { rx_inn_test }
set_qtm_port_load -type qtm_load -factor 2 { rx_inn_test }

create_qtm_port -type clock { ext_clk }
set_qtm_port_load -type qtm_load -factor 2 { ext_clk }

create_qtm_port -type input { mdll_clk }
set_qtm_port_load -type qtm_load -factor 2 { mdll_clk }

create_qtm_port -type input { ext_clk_test0 }
set_qtm_port_load -type qtm_load -factor 2 { ext_clk_test0 }

create_qtm_port -type input { ext_clk_test1 }
set_qtm_port_load -type qtm_load -factor 2 { ext_clk_test1 }

create_qtm_port -type input { clk_async }
set_qtm_port_load -type qtm_load -factor 2 { clk_async }

create_qtm_port -type input { ctl_pi[35:0] }
set_qtm_port_load -type qtm_load -factor 2 { ctl_pi[35:0] }

create_qtm_port -type input { ctl_valid }
set_qtm_port_load -type qtm_load -factor 2 { ctl_valid }

create_qtm_port -type inout { Vcal }
set_qtm_port_load -type qtm_load -factor 2 { Vcal }
set_qtm_port_drive -type qtm_drive { Vcal }

create_qtm_port -type output { clk_adc }
set_qtm_port_drive -type qtm_drive { clk_adc }

create_qtm_port -type output { adder_out[127:0] }
set_qtm_port_drive -type qtm_drive { adder_out[127:0] }

create_qtm_port -type output { sign_out[15:0] }
set_qtm_port_drive -type qtm_drive { sign_out[15:0] }

create_qtm_port -type output { adder_out_rep[15:0] }
set_qtm_port_drive -type qtm_drive { adder_out_rep[15:0] }

create_qtm_port -type output { sign_out_rep[1:0] }
set_qtm_port_drive -type qtm_drive { sign_out_rep[1:0] }

### interface I/O

# ADC

create_qtm_port -type input { adbg_intf_i_rstb }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_rstb }

create_qtm_port -type input { adbg_intf_i_en_v2t }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_v2t }

create_qtm_port -type input { adbg_intf_i_en_slice[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_slice[15:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tn[79:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_v2tn[79:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tp[79:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_v2tp[79:0] }

create_qtm_port -type input { adbg_intf_i_init[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_init[31:0] }

create_qtm_port -type input { adbg_intf_i_ALWS_ON[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ALWS_ON[15:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_sign[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pm_sign[31:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_in[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pm_in[31:0] }

create_qtm_port -type input { adbg_intf_i_sel_clk_TDC[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_clk_TDC[15:0] }

create_qtm_port -type input { adbg_intf_i_en_pm[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_pm[15:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_late[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_late[31:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_early[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_early[31:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_TDC[79:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_TDC[79:0] }

# PI

create_qtm_port -type input { adbg_intf_i_en_gf }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_gf }

create_qtm_port -type input { adbg_intf_i_en_arb_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_arb_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_delay_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_delay_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_ext_Qperi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_ext_Qperi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_pm_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_pm_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_cal_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_cal_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_ext_Qperi[19:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ext_Qperi[19:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_sign_pi[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pm_sign_pi[7:0] }

create_qtm_port -type input { adbg_intf_i_del_inc[127:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_del_inc[127:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_slice[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_slice[7:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_sw[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_sw[7:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_clk_encoder[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_clk_encoder[7:0] }

create_qtm_port -type input { adbg_intf_i_disable_state[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_disable_state[3:0] }

create_qtm_port -type input { adbg_intf_i_en_clk_sw[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_clk_sw[3:0] }

create_qtm_port -type input { adbg_intf_i_en_meas_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_meas_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_sel_meas_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_meas_pi[3:0] }

# ADCrep

create_qtm_port -type input { adbg_intf_i_en_slice_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_slice_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tn_rep[9:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_v2tn_rep[9:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tp_rep[9:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_v2tp_rep[9:0] }

create_qtm_port -type input { adbg_intf_i_init_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_init_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_ALWS_ON_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ALWS_ON_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_sign_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pm_sign_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_in_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pm_in_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_sel_clk_TDC_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_clk_TDC_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_en_pm_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_pm_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_late_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_late_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_early_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_early_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_TDC_rep[9:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_dcdl_TDC_rep[9:0] }

# ADCtest (only for ADCrep1)

create_qtm_port -type input { adbg_intf_i_sel_pfd_in }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pfd_in }

create_qtm_port -type input { adbg_intf_i_sel_pfd_in_meas }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_pfd_in_meas }

create_qtm_port -type input { adbg_intf_i_en_pfd_inp_meas }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_pfd_inp_meas }

create_qtm_port -type input { adbg_intf_i_en_pfd_inn_meas }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_pfd_inn_meas }

create_qtm_port -type input { adbg_intf_i_sel_del_out }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_del_out }

# input clock buffer

create_qtm_port -type input { adbg_intf_i_en_inbuf }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_inbuf }

create_qtm_port -type input { adbg_intf_i_sel_clk_source }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_clk_source }

create_qtm_port -type input { adbg_intf_i_bypass_inbuf_div }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_bypass_inbuf_div }

create_qtm_port -type input { adbg_intf_i_bypass_inbuf_div2 }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_bypass_inbuf_div2 }

create_qtm_port -type input { adbg_intf_i_inbuf_ndiv[2:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_inbuf_ndiv[2:0] }

create_qtm_port -type input { adbg_intf_i_en_inbuf_meas }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_inbuf_meas }

# biasgen

create_qtm_port -type input { adbg_intf_i_en_biasgen[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_biasgen[3:0] }

create_qtm_port -type input { adbg_intf_i_ctl_biasgen[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_ctl_biasgen[15:0] }

# ACORE

create_qtm_port -type input { adbg_intf_i_sel_del_out_pi }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_sel_del_out_pi }

create_qtm_port -type input { adbg_intf_i_en_del_out_pi }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_del_out_pi }

## outputs from analog core

# ADC

create_qtm_port -type output { adbg_intf_i_pm_out[319:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_pm_out[319:0] }

create_qtm_port -type output { adbg_intf_i_del_out[15:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_del_out[15:0] }

# PI

create_qtm_port -type output { adbg_intf_i_pm_out_pi[79:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_pm_out_pi[79:0] }

create_qtm_port -type output { adbg_intf_i_del_out_pi }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_del_out_pi }

create_qtm_port -type output { adbg_intf_i_cal_out_pi[3:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_cal_out_pi[3:0] }

create_qtm_port -type output { adbg_intf_i_Qperi[19:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_Qperi[19:0] }

create_qtm_port -type output { adbg_intf_i_max_sel_mux[19:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_max_sel_mux[19:0] }

create_qtm_port -type output { adbg_intf_i_pi_out_meas[3:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_pi_out_meas[3:0] }

# ADCrep

create_qtm_port -type output { adbg_intf_i_pm_out_rep[39:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_pm_out_rep[39:0] }

create_qtm_port -type output { adbg_intf_i_del_out_rep[1:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_del_out_rep[1:0] }

create_qtm_port -type output { adbg_intf_i_pfd_inp_meas }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_pfd_inp_meas }

create_qtm_port -type output { adbg_intf_i_pfd_inn_meas }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_pfd_inn_meas }

# input clock buffer

create_qtm_port -type output { adbg_intf_i_inbuf_out_meas }
set_qtm_port_drive -type qtm_drive { adbg_intf_i_inbuf_out_meas }

# TDC phase reversal (input to analog core but appears at the bottom of acore_debug_intf)

create_qtm_port -type input { adbg_intf_i_en_TDC_phase_reverse }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i_en_TDC_phase_reverse }

###################### Timing Arcs ######################

## PI control signals

# setup/hold for ctl_valid
create_qtm_constraint_arc -setup -edge rise -from ext_clk -to ctl_valid \
    -value [expr {5.0}]
create_qtm_constraint_arc -hold -edge rise -from ext_clk -to ctl_valid \
    -value [expr {0.0}]

# setup/hold for ctl_pi[35:0]
for {set idx 0} {$idx < 36} {incr idx} {
    create_qtm_constraint_arc -setup -edge rise -from ext_clk -to "ctl_pi[$idx]" \
        -value [expr {5.0}]
    create_qtm_constraint_arc -hold -edge rise -from ext_clk -to "ctl_pi[$idx]" \
        -value [expr {0.0}]
}

## Main ADCs

set clk_adc_per [expr {$::env(constr_main_per) * $::env(constr_time_scale)}]
for {set adc_idx 0} {$adc_idx < 16} {incr adc_idx} {
    # determine bank and slice
    set adc_bank [expr {$adc_idx / 4}]
    set adc_slice [expr {$adc_idx % 4}]

    # determine ADC sequential order
    set adc_order [expr {$adc_bank + (4*$adc_slice)}]
    if { $adc_order < 8 } {
        set adc_edge rise
        set delay_val [expr {(($adc_order + 0.5)/16.0)*$clk_adc_per}]
    } else {
        set adc_edge fall
        set delay_val [expr {(($adc_order - 7.5)/16.0)*$clk_adc_per}]
    }

    # print out computed delay
    puts [format "idx: %0d, bank: %0d, slice: %0d, delay: %0f, edge: %0s" \
          $adc_idx $adc_bank $adc_slice $delay_val $adc_edge]

    # loop over the bits in this ADC
    for {set bit_idx 0} {$bit_idx < 8} {incr bit_idx} {
        # determine the index of this bit in the flattened bus
        set flat_idx [expr {($adc_idx * 8) + $bit_idx}]

        # create the delay arcs
        create_qtm_delay_arc -from ext_clk -edge $adc_edge -to "adder_out[$flat_idx]" \
            -value $delay_val
        create_qtm_delay_arc -from ext_clk -edge $adc_edge -to "sign_out[$adc_idx]" \
            -value $delay_val
    }
}

# adbg_intf_i_pm_out[319:0]
for {set idx 0} {$idx < 320} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i_pm_out[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

## Replica ADCs

# adder_out_rep[15:0]
for {set idx 0} {$idx < 16} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adder_out_rep[$idx]" \
        -value [expr {0.05 * $::env(constr_time_scale)}]
}

# sign_out_rep[1:0]
for {set idx 0} {$idx < 2} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "sign_out_rep[$idx]" \
        -value [expr {0.05 * $::env(constr_time_scale)}]
}

# adbg_intf_i_pm_out_rep[39:0]
for {set idx 0} {$idx < 40} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i_pm_out_rep[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

## miscellaneous outputs

# adbg_intf_i_pm_out_pi[79:0]
for {set idx 0} {$idx < 80} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i_pm_out_pi[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

# adbg_intf_i_cal_out_pi[3:0]
for {set idx 0} {$idx < 4} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i_cal_out_pi[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

# adbg_intf_i_Qperi[19:0]
for {set idx 0} {$idx < 20} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i_Qperi[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

# adbg_intf_i_max_sel_mux[19:0]
for {set idx 0} {$idx < 20} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i_max_sel_mux[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit