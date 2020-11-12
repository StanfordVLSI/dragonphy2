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

create_qtm_port -type input { adbg_intf_i.rstb }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.rstb }

create_qtm_port -type input { adbg_intf_i.en_v2t }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_v2t }

create_qtm_port -type input { adbg_intf_i.en_slice[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_slice[15:0] }

create_qtm_port -type input { adbg_intf_i.ctl_v2tn[79:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_v2tn[79:0] }

create_qtm_port -type input { adbg_intf_i.ctl_v2tp[79:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_v2tp[79:0] }

create_qtm_port -type input { adbg_intf_i.init[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.init[31:0] }

create_qtm_port -type input { adbg_intf_i.ALWS_ON[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ALWS_ON[15:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_late[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_late[31:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_early[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_early[31:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_TDC[79:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_TDC[79:0] }

# PI

create_qtm_port -type input { adbg_intf_i.en_gf }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_gf }

create_qtm_port -type input { adbg_intf_i.en_arb_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_arb_pi[3:0] }

create_qtm_port -type input { adbg_intf_i.en_delay_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_delay_pi[3:0] }

create_qtm_port -type input { adbg_intf_i.en_ext_Qperi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_ext_Qperi[3:0] }

create_qtm_port -type input { adbg_intf_i.en_pm_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_pm_pi[3:0] }

create_qtm_port -type input { adbg_intf_i.en_cal_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_cal_pi[3:0] }

create_qtm_port -type input { adbg_intf_i.ext_Qperi[19:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ext_Qperi[19:0] }

create_qtm_port -type input { adbg_intf_i.sel_pm_sign_pi[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_pm_sign_pi[7:0] }

create_qtm_port -type input { adbg_intf_i.del_inc[127:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.del_inc[127:0] }

create_qtm_port -type input { adbg_intf_i.enb_unit_pi[127:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.enb_unit_pi[127:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_slice[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_slice[7:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_sw[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_sw[7:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_clk_encoder[7:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_clk_encoder[7:0] }

create_qtm_port -type input { adbg_intf_i.disable_state[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.disable_state[3:0] }

create_qtm_port -type input { adbg_intf_i.en_clk_sw[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_clk_sw[3:0] }

create_qtm_port -type input { adbg_intf_i.en_meas_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_meas_pi[3:0] }

create_qtm_port -type input { adbg_intf_i.sel_meas_pi[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_meas_pi[3:0] }

# ADCrep

create_qtm_port -type input { adbg_intf_i.en_slice_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_slice_rep[1:0] }

create_qtm_port -type input { adbg_intf_i.ctl_v2tn_rep[9:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_v2tn_rep[9:0] }

create_qtm_port -type input { adbg_intf_i.ctl_v2tp_rep[9:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_v2tp_rep[9:0] }

create_qtm_port -type input { adbg_intf_i.init_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.init_rep[3:0] }

create_qtm_port -type input { adbg_intf_i.ALWS_ON_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ALWS_ON_rep[1:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_late_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_late_rep[3:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_early_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_early_rep[3:0] }

create_qtm_port -type input { adbg_intf_i.ctl_dcdl_TDC_rep[9:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_dcdl_TDC_rep[9:0] }

# ADCtest (only for ADCrep1)

create_qtm_port -type input { adbg_intf_i.sel_del_out }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_del_out }

# input clock buffer

create_qtm_port -type input { adbg_intf_i.en_inbuf }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_inbuf }

create_qtm_port -type input { adbg_intf_i.sel_clk_source }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_clk_source }

create_qtm_port -type input { adbg_intf_i.bypass_inbuf_div }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.bypass_inbuf_div }

create_qtm_port -type input { adbg_intf_i.bypass_inbuf_div2 }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.bypass_inbuf_div2 }

create_qtm_port -type input { adbg_intf_i.inbuf_ndiv[2:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.inbuf_ndiv[2:0] }

create_qtm_port -type input { adbg_intf_i.en_inbuf_meas }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_inbuf_meas }

# biasgen

create_qtm_port -type input { adbg_intf_i.en_biasgen[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_biasgen[3:0] }

create_qtm_port -type input { adbg_intf_i.ctl_biasgen[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.ctl_biasgen[15:0] }

# ACORE

create_qtm_port -type input { adbg_intf_i.sel_del_out_pi }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_del_out_pi }

create_qtm_port -type input { adbg_intf_i.en_del_out_pi }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_del_out_pi }

## outputs from analog core

# ADC

create_qtm_port -type output { adbg_intf_i.del_out[15:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.del_out[15:0] }

# PI

create_qtm_port -type output { adbg_intf_i.pm_out_pi[79:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.pm_out_pi[79:0] }

create_qtm_port -type output { adbg_intf_i.del_out_pi }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.del_out_pi }

create_qtm_port -type output { adbg_intf_i.cal_out_pi[3:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.cal_out_pi[3:0] }

create_qtm_port -type output { adbg_intf_i.Qperi[19:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.Qperi[19:0] }

create_qtm_port -type output { adbg_intf_i.max_sel_mux[19:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.max_sel_mux[19:0] }

create_qtm_port -type output { adbg_intf_i.pi_out_meas[3:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.pi_out_meas[3:0] }

# ADCrep

create_qtm_port -type output { adbg_intf_i.del_out_rep[1:0] }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.del_out_rep[1:0] }

# input clock buffer

create_qtm_port -type output { adbg_intf_i.inbuf_out_meas }
set_qtm_port_drive -type qtm_drive { adbg_intf_i.inbuf_out_meas }

# TDC phase reversal (input to analog core but appears at the bottom of acore_debug_intf)

create_qtm_port -type input { adbg_intf_i.en_TDC_phase_reverse }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.en_TDC_phase_reverse }

# ADC retimer (input to analog core but appears at the bottom of acore_debug_intf)

create_qtm_port -type input { adbg_intf_i.retimer_mux_ctrl_1[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.retimer_mux_ctrl_1[15:0] }

create_qtm_port -type input { adbg_intf_i.retimer_mux_ctrl_2[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.retimer_mux_ctrl_2[15:0] }

create_qtm_port -type input { adbg_intf_i.retimer_mux_ctrl_1_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.retimer_mux_ctrl_1_rep[1:0] }

create_qtm_port -type input { adbg_intf_i.retimer_mux_ctrl_2_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.retimer_mux_ctrl_2_rep[1:0] }


create_qtm_port -type input { adbg_intf_i.sel_PFD_in[31:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_PFD_in[31:0] }

create_qtm_port -type input { adbg_intf_i.sign_PFD_clk_in[15:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sign_PFD_clk_in[15:0] }

create_qtm_port -type input { adbg_intf_i.sel_PFD_in_rep[3:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sel_PFD_in_rep[3:0] }

create_qtm_port -type input { adbg_intf_i.sign_PFD_clk_in_rep[1:0] }
set_qtm_port_load -type qtm_load -factor 2 { adbg_intf_i.sign_PFD_clk_in_rep[1:0] }



###################### Timing Arcs ######################

## Clock outputs

create_qtm_delay_arc -from ext_clk -edge rise -to clk_adc -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.del_out_pi -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.pi_out_meas[0] -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.pi_out_meas[1] -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.pi_out_meas[2] -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.pi_out_meas[3] -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.del_out_rep[0] -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.del_out_rep[1] -value 0
create_qtm_delay_arc -from ext_clk -edge rise -to adbg_intf_i.inbuf_out_meas -value 0

## PI control signals

# setup/hold for ctl_valid
create_qtm_constraint_arc -setup -edge rise -from ext_clk -to ctl_valid \
    -value [expr {0.400}]
create_qtm_constraint_arc -hold -edge rise -from ext_clk -to ctl_valid \
    -value [expr {0.100}]

# setup/hold for ctl_pi[35:0]
for {set idx 0} {$idx < 36} {incr idx} {
    create_qtm_constraint_arc -setup -edge rise -from ext_clk -to "ctl_pi[$idx]" \
        -value [expr {0.400}]
    create_qtm_constraint_arc -hold -edge rise -from ext_clk -to "ctl_pi[$idx]" \
        -value [expr {0.100}]
}

## Main ADCs

for {set adc_idx 0} {$adc_idx < 16} {incr adc_idx} {
    # loop over the bits in this ADC
    for {set bit_idx 0} {$bit_idx < 8} {incr bit_idx} {
        # determine the index of this bit in the flattened bus
        set flat_idx [expr {($adc_idx * 8) + $bit_idx}]

        # create the delay arcs
        create_qtm_delay_arc -from ext_clk -edge rise -to "adder_out[$flat_idx]" \
            -value [expr {0.230 * $::env(constr_time_scale)}]
        create_qtm_delay_arc -from ext_clk -edge rise -to "sign_out[$adc_idx]" \
            -value [expr {0.230 * $::env(constr_time_scale)}]
    }
}

## Replica ADCs

# adder_out_rep[15:0]
for {set idx 0} {$idx < 16} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adder_out_rep[$idx]" \
        -value [expr {0.230 * $::env(constr_time_scale)}]
}

# sign_out_rep[1:0]
for {set idx 0} {$idx < 2} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "sign_out_rep[$idx]" \
        -value [expr {0.230 * $::env(constr_time_scale)}]
}

## miscellaneous outputs

# adbg_intf_i.pm_out_pi[79:0]
for {set idx 0} {$idx < 80} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i.pm_out_pi[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

# adbg_intf_i.cal_out_pi[3:0]
for {set idx 0} {$idx < 4} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i.cal_out_pi[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

# adbg_intf_i.Qperi[19:0]
for {set idx 0} {$idx < 20} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i.Qperi[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

# adbg_intf_i.max_sel_mux[19:0]
for {set idx 0} {$idx < 20} {incr idx} {
    create_qtm_delay_arc -from ext_clk -edge rise -to "adbg_intf_i.max_sel_mux[$idx]" \
        -value [expr {0.02 * $::env(constr_time_scale)}]
}

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
