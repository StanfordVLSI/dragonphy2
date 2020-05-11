create_qtm_model input_buffer

create_qtm_port { \
    inp \
    inm \
    pd \
} -type input

create_qtm_port {
    clk \
    clk_b \
} -type output

set_qtm_port_load { \
    inp \
    inm \
    pd \
} -value 0.02

set_qtm_port_drive { \
    clk \
    clk_b \
} -value 100

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
