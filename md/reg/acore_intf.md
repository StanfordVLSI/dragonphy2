| Name                       | Signed? | Packed Dim             | Unpacked Dim | Clock Domain | JTAG Dir | Reset Val |
|----------------------------|---------|------------------------|--------------|--------------|----------|-----------|
| en_v2t                     |         |                        |              | Test         | out      |   0       |
| en_slice                   |         | Nti-1:0                |              | Test         | out      |   'hFFFF  |
| ctl_v2tn                   |         | Nv2t-1:0               | Nti-1:0      | Test         | out      |   6       |
| ctl_v2tp                   |         | Nv2t-1:0               | Nti-1:0      | Test         | out      |   6       |
| init                       |         | $clog2(Nout)-1:0       | Nti-1:0      | Test         | out      |   0       |
| ALWS_ON                    |         | Nti-1:0                |              | Test         | out      |   0       |
| sel_pm_sign                |         | 1:0                    | Nti-1:0      | Test         | out      |   0       |
| sel_pm_in                  |         | 1:0                    | Nti-1:0      | Test         | out      |   0       |
| sel_clk_TDC                |         | Nti-1:0                |              | Test         | out      |   0       |
| en_pm                      |         | Nti-1:0                |              | Test         | out      |   0       |
| en_v2t_clk_next            |         | Nti-1:0                |              | Test         | out      |   0       |
| en_sw_test                 |         | Nti-1:0                |              | Test         | out      |   0       |
| ctl_dcdl_late              |         | 1:0                    | Nti-1:0      | Test         | out      |   0       |
| ctl_dcdl_early             |         | 1:0                    | Nti-1:0      | Test         | out      |   0       |
| ctl_dcdl_TDC               |         | 4:0                    | Nti-1:0      | Test         | out      |   0       |
| en_gf                      |         |                        |              | Test         | out      |   0       |
| en_arb_pi                  |         | Nout-1:0               |              | Test         | out      |   'hF     |
| en_delay_pi                |         | Nout-1:0               |              | Test         | out      |   'hF     |
| en_ext_Qperi               |         | Nout-1:0               |              | Test         | out      |   0       |
| en_pm_pi                   |         | Nout-1:0               |              | Test         | out      |   0       |
| en_cal_pi                  |         | Nout-1:0               |              | Test         | out      |   0       |
| ext_Qperi                  |         | $clog2(Nunit_pi)-1:0   | Nout-1:0     | Test         | out      |   17      |
| sel_pm_sign_pi             |         | 1:0                    | Nout-1:0     | Test         | out      |   0       |
| del_inc                    |         | Nunit_pi-1:0           | Nout-1:0     | Test         | out      |   0       |
| ctl_dcdl_slice             |         | 1:0                    | Nout-1:0     | Test         | out      |   0       |
| ctl_dcdl_sw                |         | 1:0                    | Nout-1:0     | Test         | out      |   0       |
| disable_state              |         | Nout-1:0               |              | Test         | out      |   0       |
| en_clk_sw                  |         | Nout-1:0               |              | Test         | out      |   'hF     |
| en_meas_pi                 |         | Nout-1:0               |              | Test         | out      |   0       |
| sel_meas_pi                |         | Nout-1:0               |              | Test         | out      |   0       |
| en_slice_rep               |         | 1:0                    |              | Test         | out      |   0       |
| ctl_v2tn_rep               |         | Nv2t-1:0               | 1:0          | Test         | out      |   16      |
| ctl_v2tp_rep               |         | Nv2t-1:0               | 1:0          | Test         | out      |   16      |
| init_rep                   |         | $clog2(Nout)-1:0       | 1:0          | Test         | out      |   0       |
| ALWS_ON_rep                |         | 1:0                    |              | Test         | out      |   0       |
| sel_pm_sign_rep            |         | 1:0                    | 1:0          | Test         | out      |   0       |
| sel_pm_in_rep              |         | 1:0                    | 1:0          | Test         | out      |   0       |
| sel_clk_TDC_rep            |         | 1:0                    |              | Test         | out      |   0       |
| en_pm_rep                  |         | 1:0                    |              | Test         | out      |   0       |
| en_v2t_clk_next_rep        |         | 1:0                    |              | Test         | out      |   0       |
| en_sw_test_rep             |         | 1:0                    |              | Test         | out      |   0       |
| ctl_dcdl_late_rep          |         | 1:0                    | 1:0          | Test         | out      |   0       |
| ctl_dcdl_early_rep         |         | 1:0                    | 1:0          | Test         | out      |   0       |
| ctl_dcdl_TDC_rep           |         | 4:0                    | 1:0          | Test         | out      |   0       |
| sel_pfd_in                 |         |                        |              | Test         | out      |   0       |
| sel_pfd_in_meas            |         |                        |              | Test         | out      |   0       |
| en_pfd_inp_meas            |         |                        |              | Test         | out      |   0       |
| en_pfd_inn_meas            |         |                        |              | Test         | out      |   0       |
| sel_del_out                |         |                        |              | Test         | out      |   0       |
| disable_ibuf_async         |         |                        |              | Test         | out      |   1       |
| disable_ibuf_aux           |         |                        |              | Test         | out      |   1       |
| disable_ibuf_test0         |         |                        |              | Test         | out      |   1       |
| disable_ibuf_test1         |         |                        |              | Test         | out      |   1       |
| en_inbuf                   |         |                        |              | Test         | out      |   0       |
| sel_inbuf_in               |         |                        |              | Test         | out      |   0       |
| bypass_inbuf_div           |         |                        |              | Test         | out      |   1       |
| inbuf_ndiv                 |         | 2:0                    |              | Test         | out      |   0       |
| en_inbuf_meas              |         |                        |              | Test         | out      |   0       |
| en_biasgen                 |         | 3:0                    |              | Test         | out      |   1       |
| ctl_biasgen                |         | Nbias-1:0              | 3:0          | Test         | out      |   7       |
| sel_del_out_pi             |         |                        |              | Test         | out      |   0       |
| en_del_out_pi              |         |                        |              | Test         | out      |   0       |
| pm_out                     |         | 19:0                   | Nti-1:0      | System       | in       |           |
| pm_out_pi                  |         | 19:0                   | Nout-1:0     | System       | in       |           |
| cal_out_pi                 |         | Nout-1:0               |              | System       | in       |           |
| Qperi                      |         | $clog2(Nunit_pi)-1:0   | Nout-1:0     | System       | in       |           |
| max_sel_mux 				 |         | $clog2(Nunit_pi)-1:0   | Nout-1:0     | System       | in       |           |
| pm_out_rep                 |         | 19:0                   | 1:0          | System       | in       |           |
