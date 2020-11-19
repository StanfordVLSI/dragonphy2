import re, sys

output = ""
#output += """set ext_dont_touch_false_path {{ \\
#    ext_rx_inp \\
#    ext_rx_inn \\
#    ext_Vcm \\
#    ext_Vcal \\
#    ext_rx_inp_test \\
#    ext_rx_inn_test \\
#    ext_tx_outp \\
#    ext_tx_outn \\
#    ext_clk_async_p \\
#    ext_clk_async_n \\
#    ext_clkp \\
#    ext_clkn \\
#    ext_mdll_clk_refp \\
#    ext_mdll_clk_refn \\
#    ext_mdll_clk_monp \\
#    ext_mdll_clk_monn \\
#    clk_out_p \\
#    clk_out_n \\
#    clk_trig_p \\
#    clk_trig_n \\
#}}\n"""
#output += f'set_dont_touch_network [get_ports $ext_dont_touch_false_path]\n'

#output += f'set_dont_touch_network [get_pins ibuf_async/inp]\n'
#output += f'set_dont_touch_network [get_pins ibuf_async/inn]\n'
#output +=f'set_dont_touch_network [get_pins ibuf_main/inp]\n'
#output +=f'set_dont_touch_network [get_pins ibuf_main/inn]\n'
#output +=f'set_dont_touch_network [get_pins ibuf_mdll_ref/inp]\n'
#output +=f'set_dont_touch_network [get_pins ibuf_mdll_ref/inn]\n'
#output +=f'set_dont_touch_network [get_pins ibuf_mdll_mon/inp]\n'
#output +=f'set_dont_touch_network [get_pins ibuf_mdll_mon/inn]\n'

#output +=f'set tdbg_clk_pins [get_pins {{ \\\n'
#output +=f'\titx/tx_del_out_pi \\\n'
#output +=f'\titx/tx_pi_out_meas \\\n'
#output +=f'\titx/tx_inbuf_out_meas \\\n'
#output +=f'}}]\n'

#output += f'set_dont_touch_network $tdbg_clk_pins\n'

#for ii in range(4):
#    output += f'set_dont_touch [get_cells "itx/iPI_{ii}\__iPI"]\n'

#output += f'set_dont_touch [get_cells itx/indiv]\n'
#output += f'set_dont_touch [get_nets "itx/qr_data_p"]\n'
#output += f'set_dont_touch [get_nets "itx/qr_data_n"]\n'
#output += f'set_dont_touch [get_nets "itx/mtb_n"]\n'
#output += f'set_dont_touch [get_nets "itx/mtb_p"]\n'

#for ii in range(2): 
#    for jj in range(1,5):
#        output += f'set_dont_touch [get_nets "itx/hr_mux_16t4_{ii}/iMUX_{jj}\\__mux_4t1_hd"]\n'
#        for kk in range(3):
#            output += f'set_dont_touch [get_nets "itx/hr_mux_16t4_{ii}/iMUX_{jj}\\__mux_4t1_hr_2t1_mux_{kk}/D0L"]\n'
#            output += f'set_dont_touch [get_nets "itx/hr_mux_16t4_{ii}/iMUX_{jj}\\__mux_4t1_hr_2t1_mux_{kk}/D1M"]\n'
#            output += f'set_dont_touch [get_nets "itx/hr_mux_16t4_{ii}/iMUX_{jj}\\__mux_4t1_hr_2t1_mux_{kk}/L0M"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/D0DQ"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/D0DI"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/D0DQB"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/D1DQB"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/D0DIB"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/D1DIB"]\n'
#    output += f'set_dont_touch [get_nets "itx/qr_mux_4t1_{ii}/mux_out"]\n'
#    output += f'set_dont_touch [get_cells "itx/qr_mux_4t1_{ii}/mux_4/mux_4_fixed"]\n'
#    for jj in range(4):
#        output += f'set_dont_touch [get_cells "itx/qr_mux_4t1_{ii}/i_INVBUF_{jj}\\__inv_buf/inv_4_fixed"]\n'

#for ii in range(2):
#    output += f'set_dont_touch [get_cells "itx/buf1/iBUF_{ii}\\__i_tri_buf_n/tri_buf"]\n'
#    output += f'set_dont_touch [get_cells "itx/buf1/iBUF_{ii}\\__i_tri_buf_p/tri_buf"]\n'

output += """set_dont_touch [get_nets "itx/buf1/BTN"]
set_dont_touch [get_nets "itx/buf1/BTP"]
set_dont_touch [get_cells "itx/buf1/i_term_n"]
set_dont_touch [get_cells "itx/buf1/i_term_p"]

set_dont_touch [get_pins "itx/buf1/DOUTP"]
set_dont_touch [get_pins "itx/buf1/DOUTN"]
set_dont_touch [get_pins "itx/dout_p"]
set_dont_touch [get_pins "itx/dout_n"]\n"""

#set_dont_touch_network [get_pins imdll/clk_90]
#set_dont_touch_network [get_pins imdll/clk_180]
#set_dont_touch_network [get_pins imdll/clk_270]\n"""

output += f'set_propagated_clock [all_clocks]\n' 
output += f'set_dont_touch_network [get_pins idcore/out_buff_i/clock_out_p]\n'
output += f'set_dont_touch_network [get_pins idcore/out_buff_i/clock_out_n]\n'
output += f'set_dont_touch_network [get_pins idcore/out_buff_i/trigg_out_p]\n'
output += f'set_dont_touch_network [get_pins idcore/out_buff_i/trigg_out_n]\n'
with open(sys.argv[1], "w") as fout:
    print(output, file=fout)




