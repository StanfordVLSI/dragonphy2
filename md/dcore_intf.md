| Name                       | Signed? | Packed Dim             | Unpacked Dim     | Clock Domain | JTAG Dir | Reset Val |
|----------------------------|---------|------------------------|------------------|--------------|----------|-----------|
| ext_pi_ctl_offset          |         | Npi-1:0                | Nout-1:0         | Test         | out      | 0&135&270&405|
| en_ext_pfd_offset          |         |                        |                  | Test         | out      | 'b1       |
| bypass_pi_ctl              |         | Npi-1:0                | Nout-1:0         | Test         | out      | 0         |
| en_bypass_pi_ctl           |         | Npi-1:0                |                  | Test         | out      | 0         |
| ext_pfd_offset             |         | Nadc-1:0               | Nti-1:0          | Test         | out      | 'd47      |
| en_ext_pfd_offset_rep      |         |                        |                  | Test         | out      | 'b1       |
| ext_pfd_offset_rep         |         | Nadc-1:0               | Nti_rep-1:0      | Test         | out      | 'd27      |
| en_ext_max_sel_mux         |         |                        |                  | Test         | out      | 'b0       |
| ext_max_sel_mux 		     |         | $clog2(Nunit_pi)-1:0   | Nout-1:0         | Test         | out      | 'h1F      |
| en_pfd_cal                 |         |                        |                  | Test         | out      | 'b0       |
| en_pfd_cal_rep             |         |                        |                  | Test         | out      | 'b0       |
| Navg_adc                   |         | Nrange-1:0             |                  | Test         | out      | 'd10      |
| Nbin_adc                   |         | Nrange-1:0             |                  | Test         | out      | 'd6       |
| DZ_hist_adc                |         | Nrange-1:0             |                  | Test         | out      | 'd3       |
| Navg_adc_rep               |         | Nrange-1:0             |                  | Test         | out      | 'd10      |
| Nbin_adc_rep               |         | Nrange-1:0             |                  | Test         | out      | 'd6       |
| DZ_hist_adc_rep            |         | Nrange-1:0             |                  | Test         | out      | 'd3       |
| adcout_avg                 | yes     | Nadc-1:0               | Nti-1:0          | System       | in       |           |
| adcout_sum                 | yes     | 23:0                   | Nti-1:0          | System       | in       |           |
| adcout_hist_center         |         | 2\*\*Nrange-1:0        | Nti-1:0          | System       | in       |           |
| adcout_hist_side           |         | 2\*\*Nrange-1:0        | Nti-1:0          | System       | in       |           |
| pfd_offset                 | yes     | Nadc-1:0               | Nti-1:0          | System       | in       |           |
| adcout_avg_rep             | yes     | Nadc-1:0               | Nti_rep-1:0      | System       | in       |           |
| adcout_sum_rep             | yes     | 23:0                   | Nti_rep-1:0      | System       | in       |           |
| adcout_hist_center_rep     |         | 2\*\*Nrange-1:0        | Nti_rep-1:0      | System       | in       |           |
| adcout_hist_side_rep       |         | 2\*\*Nrange-1:0        | Nti_rep-1:0      | System       | in       |           |
| pfd_offset_rep             | yes     | Nadc-1:0               | Nti_rep-1:0      | System       | in       |           |
| Ndiv_clk_avg               |         | Nrange-1:0             |                  | Test         | out      |   10      |
| Ndiv_clk_cdr               |         | 3:0                    |                  | Test         | out      |   4       |
| int_rstb                   |         |                        |                  | Test         | out      |   0       |
| sram_rstb                  |         |                        |                  | Test         | out      |   1       |
| cdr_rstb                   |         |                        |                  | Test         | out      |   1       |
| prbs_rstb                  |         |                        |                  | System       | out      |   0       |
| prbs_gen_rstb              |         |                        |                  | System       | out      |   0       |
| sel_outbuff				 | 		   | 3:0					|				   | Test		  | out 	 |   0		 |
| sel_trigbuff				 | 		   | 3:0					|				   | Test		  | out 	 |   0		 |
| en_outbuff				 | 		   |     					|				   | Test		  | out 	 |   0		 |
| en_trigbuff				 | 		   |     					|				   | Test		  | out 	 |   0		 |
| Ndiv_outbuff				 | 		   | 2:0					|				   | Test		  | out 	 |   0		 |
| Ndiv_trigbuff 			 | 		   | 2:0					|				   | Test		  | out 	 |   0		 |
| bypass_out				 | 		   |     					|				   | Test		  | out 	 |   1		 |
| bypass_trig				 | 		   |     					|				   | Test		  | out 	 |   1		 |
| ffe_shift                  |         | 4:0                    | Nti-1:0          | Test         | out      |   0       |
| mlsd_shift                 |         | 3:0                    | Nti-1:0          | Test         | out      |   0       |
| cmp_thresh                 |   yes   | 9:0                    | Nti-1:0          | Test         | out      |   0       |
| disable_product            |         | Nti-1:0                | 9:0              | Test         | out      |   0       |
| ffe_thresh                 |   yes   | 9:0                    | Nti-1:0          | Test         | out      |   0       |
| adc_thresh                 |   yes   | 7:0                    | Nti-1:0          | Test         | out      |   0       |
| sel_prbs_mux               |         | 1:0                    |                  | System       | out      |   0       |
| en_cgra_clk                |         |                        |                  | Test         | out      |   0       |
| pfd_cal_ext_ave            | yes     | Nadc-1:0               |                  | Test         | out      |   0       |
| pfd_cal_flip_feedback      |         |                        |                  | Test         | out      |   0       |
| en_pfd_cal_ext_ave         |         |                        |                  | Test         | out      |   0       |
| en_int_dump_start          |         |                        |                  | Test         | out      |   0       |
| int_dump_start             |         |                        |                  | Test         | out      |   0       |
| tx_en_ext_max_sel_mux      |         |                        |                  | Test         | out      | 'b0       |
| tx_ext_max_sel_mux         |         | $clog2(Nunit_pi)-1:0   | Nout-1:0         | Test         | out      | 'h1F      |
| tx_pi_ctl                  |         | Npi-1:0                | Nout-1:0         | Test         | out      | 0&135&270&405|
| tx_en_bypass_pi_ctl        |         | Npi-1:0                |                  | Test         | out      | 0         |
| tx_bypass_pi_ctl           |         | Npi-1:0                | Nout-1:0         | Test         | out      | 0         |
| tx_rst                     |         |                        |                  | Test         | out      |   1       |
| tx_ctl_valid               |         |                        |                  | Test         | out      |   0       |