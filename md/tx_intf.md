| Name                          | Signed? | Packed Dim             | Unpacked Dim | Clock Domain | JTAG Dir | Reset Val          |
|-------------------------------|---------|------------------------|--------------|--------------|----------|--------------------|
| tx_en_gf                      |         |                        |              | Test         | out      | 0                  |
| tx_en_arb_pi                  |         | Nout-1:0               |              | Test         | out      | 'hF                |
| tx_en_delay_pi                |         | Nout-1:0               |              | Test         | out      | 'hF                |
| tx_en_ext_Qperi               |         | Nout-1:0               |              | Test         | out      | 0                  |
| tx_en_pm_pi                   |         | Nout-1:0               |              | Test         | out      | 0                  |
| tx_en_cal_pi                  |         | Nout-1:0               |              | Test         | out      | 0                  |
| tx_ext_Qperi                  |         | $clog2(Nunit_pi)-1:0   | Nout-1:0     | Test         | out      | 17                 |
| tx_sel_pm_sign_pi             |         | 1:0                    | Nout-1:0     | Test         | out      | 0                  |
| tx_del_inc                    |         | Nunit_pi-1:0           | Nout-1:0     | Test         | out      | 0                  |
| tx_enb_unit_pi                |         | Nunit_pi-1:0           | Nout-1:0     | Test         | out      | 0                  |
| tx_ctl_dcdl_slice             |         | 1:0                    | Nout-1:0     | Test         | out      | 0                  |
| tx_ctl_dcdl_sw                |         | 1:0                    | Nout-1:0     | Test         | out      | 0                  |
| tx_ctl_dcdl_clk_encoder       |         | 1:0                    | Nout-1:0     | Test         | out      | 0                  |
| tx_disable_state              |         | Nout-1:0               |              | Test         | out      | 0                  |
| tx_en_clk_sw                  |         | Nout-1:0               |              | Test         | out      | 'hF                |
| tx_en_meas_pi                 |         | Nout-1:0               |              | Test         | out      | 0                  |
| tx_sel_meas_pi                |         | Nout-1:0               |              | Test         | out      | 0                  |
| tx_en_inbuf                   |         |                        |              | Test         | out      | 0                  |
| tx_sel_clk_source             |         |                        |              | Test         | out      | 0                  |
| tx_ctl_buf_n                  |         | 35:0                   |              | Test         | out      | 0                  |
| tx_ctl_buf_p                  |         | 35:0                   |              | Test         | out      | 0                  |
| tx_bypass_inbuf_div           |         |                        |              | Test         | out      | 1                  |
| tx_bypass_inbuf_div2          |         |                        |              | Test         | out      | 0                  |
| tx_inbuf_ndiv                 |         | 2:0                    |              | Test         | out      | 0                  |
| tx_en_inbuf_meas              |         |                        |              | Test         | out      | 0                  |
| tx_sel_del_out_pi             |         |                        |              | Test         | out      | 0                  |
| tx_en_del_out_pi              |         |                        |              | Test         | out      | 0                  |
| tx_pm_out_pi                  |         | 19:0                   | Nout-1:0     | System       | in       |                    |
| tx_cal_out_pi                 |         | Nout-1:0               |              | System       | in       |                    |
| tx_Qperi                      |         | $clog2(Nunit_pi)-1:0   | Nout-1:0     | System       | in       |                    |
| tx_max_sel_mux                |         | $clog2(Nunit_pi)-1:0   | Nout-1:0     | System       | in       |                    |



