create_qtm_model output_buffer

# inputs
create_qtm_port { \
    bypass_out_div \
    bypass_trig_div \
    en_outbuff \
    en_trigbuff \
    sel_trigbuff[3:0] \
    bufferend_signals[15:0] \
    Ndiv_trigbuff[2:0] \
    Ndiv_outbuff[2:0] \
    sel_outbuff[3:0] \
} -type input

# outputs
create_qtm_port { \
    clock_out_n \
    clock_out_p \
    trigg_out_n \
    trigg_out_p \
} -type output

set_qtm_port_load { \
    bypass_out_div \
    bypass_trig_div \
    en_outbuff \
    en_trigbuff \
    sel_trigbuff[3:0] \
    bufferend_signals[15:0] \
    Ndiv_trigbuff[2:0] \
    Ndiv_outbuff[2:0] \
    sel_outbuff[3:0] \
} -value 0.02

set_qtm_port_drive { \
    clock_out_n \
    clock_out_p \
    trigg_out_n \
    trigg_out_p \
} -value 1

redirect qtm.rpt report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
