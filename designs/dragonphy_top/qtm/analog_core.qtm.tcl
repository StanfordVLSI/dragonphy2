create_qtm_model analog_core

############### Port Definitions ###############

### non-interface I/O

create_qtm_port -type input { rx_inp }
set_qtm_port_load -value 0.010000 { rx_inp }

create_qtm_port -type input { rx_inn }
set_qtm_port_load -value 0.010000 { rx_inn }

create_qtm_port -type input { Vcm }
set_qtm_port_load -value 0.010000 { Vcm }

create_qtm_port -type input { rx_inp_test }
set_qtm_port_load -value 0.010000 { rx_inp_test }

create_qtm_port -type input { rx_inn_test }
set_qtm_port_load -value 0.010000 { rx_inn_test }

create_qtm_port -type clock { ext_clk }
set_qtm_port_load -value 0.010000 { ext_clk }

create_qtm_port -type clock { mdll_clk }
set_qtm_port_load -value 0.010000 { mdll_clk }

create_qtm_port -type input { ext_clk_test0 }
set_qtm_port_load -value 0.010000 { ext_clk_test0 }

create_qtm_port -type input { ext_clk_test1 }
set_qtm_port_load -value 0.010000 { ext_clk_test1 }

create_qtm_port -type input { clk_async }
set_qtm_port_load -value 0.010000 { clk_async }

create_qtm_port -type input { ctl_pi[35:0] }
set_qtm_port_load -value 0.010000 { ctl_pi[35:0] }

create_qtm_port -type input { ctl_valid }
set_qtm_port_load -value 0.010000 { ctl_valid }

create_qtm_port -type inout { Vcal }
set_qtm_port_load -value 0.010000 { Vcal }
set_qtm_port_drive -value 1.000000 { Vcal }

create_qtm_port -type output { clk_adc }
set_qtm_port_drive -value 1.000000 { clk_adc }

create_qtm_port -type output { adder_out[127:0] }
set_qtm_port_drive -value 1.000000 { adder_out[127:0] }

create_qtm_port -type output { sign_out[15:0] }
set_qtm_port_drive -value 1.000000 { sign_out[15:0] }

create_qtm_port -type output { adder_out_rep[15:0] }
set_qtm_port_drive -value 1.000000 { adder_out_rep[15:0] }

create_qtm_port -type output { sign_out_rep[1:0] }
set_qtm_port_drive -value 1.000000 { sign_out_rep[1:0] }

### interface I/O

# ADC

create_qtm_port -type input { adbg_intf_i_rstb }
set_qtm_port_load -value 0.010000 { adbg_intf_i_rstb }

create_qtm_port -type input { adbg_intf_i_en_v2t }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_v2t }

create_qtm_port -type input { adbg_intf_i_ctl_v2tn[79:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_v2tn[79:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tp[79:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_v2tp[79:0] }

create_qtm_port -type input { adbg_intf_i_en_slice[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_slice[15:0] }

create_qtm_port -type input { adbg_intf_i_init[31:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_init[31:0] }

create_qtm_port -type input { adbg_intf_i_ALWS_ON[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ALWS_ON[15:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_sign[31:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pm_sign[31:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_in[31:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pm_in[31:0] }

create_qtm_port -type input { adbg_intf_i_sel_clk_TDC[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_clk_TDC[15:0] }

create_qtm_port -type input { adbg_intf_i_en_pm[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_pm[15:0] }

create_qtm_port -type input { adbg_intf_i_en_v2t_clk_next[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_v2t_clk_next[15:0] }

create_qtm_port -type input { adbg_intf_i_en_sw_test[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_sw_test[15:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_late[31:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_late[31:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_early[31:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_early[31:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_TDC[79:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_TDC[79:0] }

# PI

create_qtm_port -type input { adbg_intf_i_en_gf }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_gf }

create_qtm_port -type input { adbg_intf_i_en_arb_pi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_arb_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_delay_pi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_delay_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_ext_Qperi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_ext_Qperi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_pm_pi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_pm_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_en_cal_pi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_cal_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_ext_Qperi[19:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ext_Qperi[19:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_sign_pi[7:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pm_sign_pi[7:0] }

create_qtm_port -type input { adbg_intf_i_del_inc[127:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_del_inc[127:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_slice[7:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_slice[7:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_sw[7:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_sw[7:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_clk_encoder[7:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_clk_encoder[7:0] }

create_qtm_port -type input { adbg_intf_i_disable_state[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_disable_state[3:0] }

create_qtm_port -type input { adbg_intf_i_en_clk_sw[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_clk_sw[3:0] }

create_qtm_port -type input { adbg_intf_i_en_meas_pi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_meas_pi[3:0] }

create_qtm_port -type input { adbg_intf_i_sel_meas_pi[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_meas_pi[3:0] }

# ADCrep

create_qtm_port -type input { adbg_intf_i_en_slice_rep[1:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_slice_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tn_rep[9:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_v2tn_rep[9:0] }

create_qtm_port -type input { adbg_intf_i_ctl_v2tp_rep[9:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_v2tp_rep[9:0] }

create_qtm_port -type input { adbg_intf_i_init_rep[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_init_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_ALWS_ON_rep[1:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ALWS_ON_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_sign_rep[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pm_sign_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_sel_pm_in_rep[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pm_in_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_sel_clk_TDC_rep[1:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_clk_TDC_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_en_pm_rep[1:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_pm_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_en_v2t_clk_next_rep[1:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_v2t_clk_next_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_en_sw_test_rep[1:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_sw_test_rep[1:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_late_rep[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_late_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_early_rep[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_early_rep[3:0] }

create_qtm_port -type input { adbg_intf_i_ctl_dcdl_TDC_rep[9:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_dcdl_TDC_rep[9:0] }

# Input Buffers

create_qtm_port -type input { adbg_intf_i_disable_ibuf_async }
set_qtm_port_load -value 0.010000 { adbg_intf_i_disable_ibuf_async }

create_qtm_port -type input { adbg_intf_i_disable_ibuf_main }
set_qtm_port_load -value 0.010000 { adbg_intf_i_disable_ibuf_main }

create_qtm_port -type input { adbg_intf_i_disable_ibuf_test0 }
set_qtm_port_load -value 0.010000 { adbg_intf_i_disable_ibuf_test0 }

create_qtm_port -type input { adbg_intf_i_disable_ibuf_test1 }
set_qtm_port_load -value 0.010000 { adbg_intf_i_disable_ibuf_test1 }

# ADCtest (only for ADCrep1)

create_qtm_port -type input { adbg_intf_i_sel_pfd_in }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pfd_in }

create_qtm_port -type input { adbg_intf_i_sel_pfd_in_meas }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_pfd_in_meas }

create_qtm_port -type input { adbg_intf_i_en_pfd_inp_meas }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_pfd_inp_meas }

create_qtm_port -type input { adbg_intf_i_en_pfd_inn_meas }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_pfd_inn_meas }

create_qtm_port -type input { adbg_intf_i_sel_del_out }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_del_out }

# input clock buffer

create_qtm_port -type input { adbg_intf_i_en_inbuf }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_inbuf }

create_qtm_port -type input { adbg_intf_i_sel_clk_source }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_clk_source }

create_qtm_port -type input { adbg_intf_i_bypass_inbuf_div }
set_qtm_port_load -value 0.010000 { adbg_intf_i_bypass_inbuf_div }

create_qtm_port -type input { adbg_intf_i_bypass_inbuf_div2 }
set_qtm_port_load -value 0.010000 { adbg_intf_i_bypass_inbuf_div2 }

create_qtm_port -type input { adbg_intf_i_inbuf_ndiv[2:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_inbuf_ndiv[2:0] }

create_qtm_port -type input { adbg_intf_i_en_inbuf_meas }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_inbuf_meas }

# biasgen

create_qtm_port -type input { adbg_intf_i_en_biasgen[3:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_biasgen[3:0] }

create_qtm_port -type input { adbg_intf_i_ctl_biasgen[15:0] }
set_qtm_port_load -value 0.010000 { adbg_intf_i_ctl_biasgen[15:0] }

# ACORE

create_qtm_port -type input { adbg_intf_i_sel_del_out_pi }
set_qtm_port_load -value 0.010000 { adbg_intf_i_sel_del_out_pi }

create_qtm_port -type input { adbg_intf_i_en_del_out_pi }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_del_out_pi }

## outputs from analog core

# ADC

create_qtm_port -type output { adbg_intf_i_pm_out[319:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_pm_out[319:0] }

create_qtm_port -type output { adbg_intf_i_del_out[15:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_del_out[15:0] }

# PI

create_qtm_port -type output { adbg_intf_i_pm_out_pi[79:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_pm_out_pi[79:0] }

create_qtm_port -type output { adbg_intf_i_del_out_pi }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_del_out_pi }

create_qtm_port -type output { adbg_intf_i_cal_out_pi[3:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_cal_out_pi[3:0] }

create_qtm_port -type output { adbg_intf_i_Qperi[19:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_Qperi[19:0] }

create_qtm_port -type output { adbg_intf_i_max_sel_mux[19:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_max_sel_mux[19:0] }

create_qtm_port -type output { adbg_intf_i_pi_out_meas[3:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_pi_out_meas[3:0] }

# ADCrep

create_qtm_port -type output { adbg_intf_i_pm_out_rep[39:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_pm_out_rep[39:0] }

create_qtm_port -type output { adbg_intf_i_del_out_rep[1:0] }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_del_out_rep[1:0] }

create_qtm_port -type output { adbg_intf_i_pfd_inp_meas }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_pfd_inp_meas }

create_qtm_port -type output { adbg_intf_i_pfd_inn_meas }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_pfd_inn_meas }

# input clock buffer

create_qtm_port -type output { adbg_intf_i_inbuf_out_meas }
set_qtm_port_drive -value 1.000000 { adbg_intf_i_inbuf_out_meas }

# TDC phase reversal (input to analog core but appears at the bottom of acore_debug_intf)

create_qtm_port -type input { adbg_intf_i_en_TDC_phase_reverse }
set_qtm_port_load -value 0.010000 { adbg_intf_i_en_TDC_phase_reverse }

###################### Timing Arcs ######################

# timing arcs for the Vcal net
# TODO: why are these needed?
create_qtm_delay_arc -from { ext_clk } -to { Vcal } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { Vcal } -from_edge rise -to_edge fall -value 0.020000

# timing arcs that make clk_adc match ext_clk
# TODO: why is this needed?  ext_clk and clk_adc have an unknown phase relationship
create_qtm_delay_arc -from { ext_clk } -to { clk_adc } -from_edge rise -to_edge rise -value 0.000000
create_qtm_delay_arc -from { ext_clk } -to { clk_adc } -from_edge rise -to_edge fall -value 0.000000

## timing arcs for the replica slices

# adder_out_rep
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[0] } -from_edge rise -to_edge fall -value 0.020000

# sign_out_rep
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for the ADC phase monitors
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[319] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[319] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[318] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[318] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[317] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[317] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[316] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[316] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[315] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[315] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[314] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[314] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[313] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[313] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[312] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[312] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[311] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[311] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[310] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[310] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[309] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[309] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[308] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[308] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[307] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[307] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[306] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[306] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[305] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[305] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[304] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[304] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[303] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[303] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[302] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[302] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[301] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[301] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[300] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[300] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[299] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[299] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[298] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[298] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[297] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[297] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[296] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[296] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[295] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[295] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[294] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[294] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[293] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[293] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[292] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[292] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[291] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[291] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[290] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[290] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[289] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[289] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[288] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[288] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[287] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[287] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[286] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[286] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[285] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[285] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[284] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[284] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[283] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[283] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[282] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[282] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[281] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[281] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[280] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[280] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[279] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[279] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[278] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[278] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[277] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[277] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[276] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[276] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[275] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[275] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[274] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[274] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[273] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[273] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[272] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[272] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[271] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[271] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[270] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[270] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[269] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[269] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[268] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[268] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[267] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[267] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[266] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[266] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[265] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[265] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[264] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[264] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[263] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[263] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[262] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[262] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[261] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[261] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[260] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[260] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[259] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[259] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[258] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[258] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[257] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[257] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[256] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[256] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[255] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[255] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[254] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[254] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[253] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[253] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[252] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[252] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[251] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[251] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[250] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[250] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[249] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[249] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[248] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[248] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[247] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[247] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[246] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[246] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[245] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[245] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[244] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[244] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[243] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[243] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[242] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[242] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[241] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[241] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[240] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[240] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[239] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[239] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[238] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[238] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[237] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[237] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[236] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[236] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[235] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[235] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[234] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[234] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[233] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[233] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[232] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[232] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[231] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[231] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[230] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[230] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[229] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[229] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[228] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[228] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[227] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[227] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[226] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[226] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[225] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[225] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[224] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[224] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[223] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[223] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[222] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[222] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[221] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[221] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[220] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[220] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[219] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[219] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[218] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[218] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[217] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[217] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[216] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[216] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[215] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[215] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[214] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[214] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[213] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[213] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[212] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[212] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[211] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[211] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[210] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[210] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[209] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[209] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[208] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[208] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[207] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[207] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[206] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[206] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[205] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[205] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[204] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[204] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[203] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[203] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[202] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[202] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[201] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[201] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[200] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[200] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[199] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[199] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[198] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[198] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[197] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[197] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[196] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[196] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[195] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[195] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[194] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[194] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[193] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[193] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[192] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[192] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[191] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[191] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[190] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[190] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[189] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[189] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[188] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[188] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[187] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[187] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[186] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[186] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[185] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[185] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[184] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[184] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[183] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[183] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[182] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[182] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[181] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[181] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[180] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[180] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[179] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[179] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[178] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[178] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[177] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[177] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[176] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[176] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[175] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[175] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[174] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[174] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[173] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[173] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[172] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[172] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[171] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[171] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[170] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[170] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[169] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[169] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[168] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[168] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[167] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[167] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[166] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[166] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[165] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[165] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[164] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[164] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[163] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[163] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[162] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[162] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[161] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[161] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[160] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[160] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[159] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[159] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[158] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[158] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[157] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[157] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[156] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[156] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[155] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[155] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[154] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[154] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[153] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[153] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[152] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[152] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[151] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[151] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[150] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[150] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[149] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[149] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[148] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[148] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[147] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[147] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[146] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[146] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[145] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[145] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[144] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[144] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[143] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[143] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[142] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[142] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[141] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[141] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[140] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[140] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[139] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[139] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[138] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[138] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[137] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[137] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[136] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[136] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[135] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[135] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[134] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[134] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[133] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[133] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[132] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[132] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[131] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[131] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[130] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[130] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[129] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[129] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[128] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[128] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[127] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[127] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[126] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[126] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[125] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[125] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[124] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[124] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[123] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[123] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[122] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[122] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[121] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[121] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[120] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[120] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[119] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[119] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[118] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[118] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[117] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[117] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[116] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[116] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[115] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[115] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[114] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[114] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[113] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[113] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[112] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[112] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[111] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[111] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[110] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[110] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[109] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[109] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[108] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[108] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[107] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[107] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[106] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[106] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[105] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[105] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[104] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[104] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[103] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[103] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[102] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[102] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[101] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[101] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[100] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[100] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[99] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[99] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[98] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[98] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[97] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[97] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[96] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[96] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[95] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[95] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[94] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[94] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[93] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[93] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[92] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[92] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[91] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[91] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[90] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[90] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[89] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[89] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[88] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[88] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[87] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[87] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[86] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[86] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[85] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[85] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[84] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[84] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[83] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[83] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[82] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[82] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[81] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[81] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[80] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[80] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[79] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[79] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[78] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[78] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[77] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[77] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[76] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[76] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[75] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[75] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[74] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[74] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[73] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[73] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[72] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[72] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[71] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[71] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[70] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[70] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[69] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[69] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[68] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[68] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[67] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[67] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[66] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[66] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[65] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[65] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[64] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[64] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[63] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[63] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[62] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[62] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[61] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[61] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[60] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[60] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[59] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[59] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[58] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[58] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[57] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[57] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[56] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[56] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[55] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[55] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[54] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[54] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[53] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[53] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[52] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[52] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[51] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[51] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[50] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[50] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[49] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[49] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[48] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[48] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[47] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[47] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[46] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[46] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[45] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[45] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[44] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[44] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[43] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[43] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[42] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[42] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[41] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[41] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[40] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[40] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[39] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[39] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[38] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[38] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[37] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[37] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[36] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[36] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[35] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[35] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[34] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[34] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[33] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[33] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[32] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[32] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[31] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[31] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[30] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[30] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[29] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[29] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[28] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[28] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[27] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[27] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[26] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[26] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[25] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[25] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[24] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[24] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[23] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[23] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[22] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[22] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[21] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[21] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[20] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[20] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[19] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[19] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[18] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[18] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[17] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[17] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[16] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[16] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for del_out
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for PI phase monitors
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[79] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[79] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[78] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[78] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[77] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[77] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[76] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[76] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[75] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[75] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[74] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[74] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[73] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[73] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[72] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[72] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[71] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[71] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[70] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[70] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[69] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[69] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[68] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[68] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[67] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[67] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[66] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[66] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[65] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[65] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[64] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[64] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[63] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[63] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[62] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[62] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[61] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[61] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[60] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[60] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[59] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[59] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[58] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[58] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[57] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[57] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[56] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[56] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[55] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[55] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[54] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[54] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[53] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[53] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[52] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[52] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[51] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[51] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[50] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[50] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[49] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[49] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[48] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[48] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[47] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[47] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[46] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[46] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[45] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[45] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[44] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[44] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[43] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[43] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[42] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[42] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[41] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[41] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[40] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[40] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[39] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[39] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[38] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[38] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[37] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[37] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[36] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[36] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[35] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[35] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[34] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[34] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[33] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[33] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[32] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[32] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[31] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[31] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[30] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[30] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[29] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[29] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[28] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[28] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[27] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[27] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[26] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[26] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[25] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[25] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[24] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[24] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[23] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[23] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[22] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[22] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[21] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[21] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[20] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[20] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[19] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[19] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[18] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[18] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[17] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[17] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[16] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[16] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_pi[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for del_out_pi
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_pi } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_pi } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for cal_out_pi
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_cal_out_pi[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for Qperi
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[19] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[19] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[18] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[18] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[17] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[17] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[16] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[16] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_Qperi[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for max_sel_mux
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[19] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[19] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[18] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[18] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[17] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[17] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[16] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[16] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_max_sel_mux[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for pi_out_meas
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pi_out_meas[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for pm_out_rep
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[39] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[39] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[38] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[38] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[37] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[37] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[36] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[36] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[35] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[35] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[34] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[34] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[33] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[33] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[32] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[32] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[31] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[31] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[30] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[30] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[29] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[29] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[28] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[28] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[27] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[27] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[26] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[26] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[25] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[25] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[24] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[24] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[23] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[23] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[22] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[22] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[21] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[21] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[20] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[20] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[19] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[19] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[18] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[18] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[17] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[17] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[16] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[16] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[15] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[15] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[14] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[14] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[13] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[13] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[12] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[12] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[11] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[11] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[10] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[10] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[9] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[9] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[8] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[8] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[7] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[7] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[6] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[6] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[5] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[5] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[4] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[4] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[3] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[3] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[2] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[2] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for del_out_rep
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[1] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[1] } -from_edge rise -to_edge fall -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[0] } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[0] } -from_edge rise -to_edge fall -value 0.020000

# timing arcs for inbuf_out_meas
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_inbuf_out_meas } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_inbuf_out_meas } -from_edge rise -to_edge fall -value 0.020000

## Timing arcs for PFD inputs

# pfd_inp_meas
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pfd_inp_meas } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pfd_inp_meas } -from_edge rise -to_edge fall -value 0.020000

# pfd_inn_meas
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pfd_inn_meas } -from_edge rise -to_edge rise -value 0.020000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pfd_inn_meas } -from_edge rise -to_edge fall -value 0.020000

### Timing arcs for adder_out and sign_out
### TODO: check that the order is as expected (i.e., array port is flattened in expected order)

## ADC 0

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[0] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[0] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[1] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[1] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[2] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[2] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[3] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[3] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[4] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[4] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[5] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[5] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[6] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[6] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[7] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[7] } -from_edge rise -to_edge fall -value 0.050000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[0] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[0] } -from_edge rise -to_edge fall -value 0.050000

## ADC 1

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[8] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[8] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[9] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[9] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[10] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[10] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[11] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[11] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[12] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[12] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[13] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[13] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[14] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[14] } -from_edge rise -to_edge fall -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[15] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[15] } -from_edge rise -to_edge fall -value 0.112500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[1] } -from_edge rise -to_edge rise -value 0.112500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[1] } -from_edge rise -to_edge fall -value 0.112500

## ADC 2

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[16] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[16] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[17] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[17] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[18] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[18] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[19] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[19] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[20] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[20] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[21] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[21] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[22] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[22] } -from_edge rise -to_edge fall -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[23] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[23] } -from_edge rise -to_edge fall -value 0.175000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[2] } -from_edge rise -to_edge rise -value 0.175000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[2] } -from_edge rise -to_edge fall -value 0.175000

## ADC 3

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[24] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[24] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[25] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[25] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[26] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[26] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[27] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[27] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[28] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[28] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[29] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[29] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[30] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[30] } -from_edge rise -to_edge fall -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[31] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[31] } -from_edge rise -to_edge fall -value 0.237500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[3] } -from_edge rise -to_edge rise -value 0.237500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[3] } -from_edge rise -to_edge fall -value 0.237500

## ADC 4

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[32] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[32] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[33] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[33] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[34] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[34] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[35] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[35] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[36] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[36] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[37] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[37] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[38] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[38] } -from_edge rise -to_edge fall -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[39] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[39] } -from_edge rise -to_edge fall -value 0.300000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[4] } -from_edge rise -to_edge rise -value 0.300000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[4] } -from_edge rise -to_edge fall -value 0.300000

## ADC 5

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[40] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[40] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[41] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[41] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[42] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[42] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[43] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[43] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[44] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[44] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[45] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[45] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[46] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[46] } -from_edge rise -to_edge fall -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[47] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[47] } -from_edge rise -to_edge fall -value 0.362500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[5] } -from_edge rise -to_edge rise -value 0.362500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[5] } -from_edge rise -to_edge fall -value 0.362500

## ADC 6

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[48] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[48] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[49] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[49] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[50] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[50] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[51] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[51] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[52] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[52] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[53] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[53] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[54] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[54] } -from_edge rise -to_edge fall -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[55] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[55] } -from_edge rise -to_edge fall -value 0.425000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[6] } -from_edge rise -to_edge rise -value 0.425000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[6] } -from_edge rise -to_edge fall -value 0.425000

## ADC 7

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[56] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[56] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[57] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[57] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[58] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[58] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[59] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[59] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[60] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[60] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[61] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[61] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[62] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[62] } -from_edge rise -to_edge fall -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[63] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[63] } -from_edge rise -to_edge fall -value 0.487500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[7] } -from_edge rise -to_edge rise -value 0.487500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[7] } -from_edge rise -to_edge fall -value 0.487500

## ADC 8

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[64] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[64] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[65] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[65] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[66] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[66] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[67] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[67] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[68] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[68] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[69] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[69] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[70] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[70] } -from_edge rise -to_edge fall -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[71] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[71] } -from_edge rise -to_edge fall -value 0.550000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[8] } -from_edge rise -to_edge rise -value 0.550000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[8] } -from_edge rise -to_edge fall -value 0.550000

## ADC 9

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[72] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[72] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[73] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[73] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[74] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[74] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[75] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[75] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[76] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[76] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[77] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[77] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[78] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[78] } -from_edge rise -to_edge fall -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[79] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[79] } -from_edge rise -to_edge fall -value 0.612500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[9] } -from_edge rise -to_edge rise -value 0.612500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[9] } -from_edge rise -to_edge fall -value 0.612500

## ADC 10

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[80] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[80] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[81] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[81] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[82] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[82] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[83] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[83] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[84] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[84] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[85] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[85] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[86] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[86] } -from_edge rise -to_edge fall -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[87] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[87] } -from_edge rise -to_edge fall -value 0.675000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[10] } -from_edge rise -to_edge rise -value 0.675000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[10] } -from_edge rise -to_edge fall -value 0.675000

## ADC 11

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[88] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[88] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[89] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[89] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[90] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[90] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[91] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[91] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[92] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[92] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[93] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[93] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[94] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[94] } -from_edge rise -to_edge fall -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[95] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[95] } -from_edge rise -to_edge fall -value 0.737500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[11] } -from_edge rise -to_edge rise -value 0.737500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[11] } -from_edge rise -to_edge fall -value 0.737500

## ADC 12

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[96] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[96] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[97] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[97] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[98] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[98] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[99] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[99] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[100] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[100] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[101] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[101] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[102] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[102] } -from_edge rise -to_edge fall -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[103] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[103] } -from_edge rise -to_edge fall -value 0.800000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[12] } -from_edge rise -to_edge rise -value 0.800000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[12] } -from_edge rise -to_edge fall -value 0.800000

## ADC 13

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[104] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[104] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[105] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[105] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[106] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[106] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[107] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[107] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[108] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[108] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[109] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[109] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[110] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[110] } -from_edge rise -to_edge fall -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[111] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[111] } -from_edge rise -to_edge fall -value 0.862500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[13] } -from_edge rise -to_edge rise -value 0.862500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[13] } -from_edge rise -to_edge fall -value 0.862500

## ADC 14

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[112] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[112] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[113] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[113] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[114] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[114] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[115] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[115] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[116] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[116] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[117] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[117] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[118] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[118] } -from_edge rise -to_edge fall -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[119] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { adder_out[119] } -from_edge rise -to_edge fall -value 0.925000

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[14] } -from_edge rise -to_edge rise -value 0.925000
create_qtm_delay_arc -from { ext_clk } -to { sign_out[14] } -from_edge rise -to_edge fall -value 0.925000

## ADC 15

# adder_out
create_qtm_delay_arc -from { ext_clk } -to { adder_out[120] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[120] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[121] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[121] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[122] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[122] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[123] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[123] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[124] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[124] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[125] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[125] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[126] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[126] } -from_edge rise -to_edge fall -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[127] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { adder_out[127] } -from_edge rise -to_edge fall -value 0.987500

# sign_out
create_qtm_delay_arc -from { ext_clk } -to { sign_out[15] } -from_edge rise -to_edge rise -value 0.987500
create_qtm_delay_arc -from { ext_clk } -to { sign_out[15] } -from_edge rise -to_edge fall -value 0.987500

## Replica ADCs

# adder_out_rep
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[15] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[15] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[14] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[14] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[13] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[13] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[12] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[12] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[11] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[11] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[10] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[10] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[9] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[9] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[8] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[8] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[7] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[7] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[6] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[6] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[5] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[5] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[4] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[4] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[3] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[3] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[2] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[2] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[1] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[1] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[0] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adder_out_rep[0] } -from_edge rise -to_edge fall -value 0.050000

# sign_out_rep
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[1] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[1] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[0] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { sign_out_rep[0] } -from_edge rise -to_edge fall -value 0.050000

# pm_out_rep
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[39] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[39] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[38] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[38] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[37] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[37] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[36] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[36] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[35] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[35] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[34] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[34] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[33] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[33] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[32] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[32] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[31] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[31] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[30] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[30] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[29] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[29] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[28] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[28] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[27] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[27] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[26] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[26] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[25] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[25] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[24] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[24] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[23] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[23] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[22] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[22] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[21] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[21] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[20] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[20] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[19] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[19] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[18] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[18] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[17] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[17] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[16] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[16] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[15] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[15] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[14] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[14] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[13] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[13] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[12] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[12] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[11] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[11] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[10] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[10] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[9] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[9] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[8] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[8] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[7] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[7] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[6] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[6] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[5] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[5] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[4] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[4] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[3] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[3] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[2] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[2] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[1] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[1] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[0] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_pm_out_rep[0] } -from_edge rise -to_edge fall -value 0.050000

# del_out_rep
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[1] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[1] } -from_edge rise -to_edge fall -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[0] } -from_edge rise -to_edge rise -value 0.050000
create_qtm_delay_arc -from { ext_clk } -to { adbg_intf_i_del_out_rep[0] } -from_edge rise -to_edge fall -value 0.050000

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit