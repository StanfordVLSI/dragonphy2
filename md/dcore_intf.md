| Name                       | Signed? | Packed Dim             | Unpacked Dim     | Clock Domain | JTAG Dir | Reset Val |
|----------------------------|---------|------------------------|------------------|--------------|----------|-----------|
| ext_pi_ctl_offset          |         | Npi-1:0                | Nout-1:0         | Test         | out      | 0&135&270&405|
| en_ext_pfd_offset          |         |                        |                  | Test         | out      | 'b1       |
| ext_pfd_offset             |         | Nadc-1:0               | Nti-1:0          | Test         | out      | 'd47      |
| en_ext_pfd_offset_rep      |         |                        |                  | Test         | out      | 'b1       |
| ext_pfd_offset_rep         |         | Nadc-1:0               | Nti_rep-1:0      | Test         | out      | 'd27      |
| en_ext_max_sel_mux         |         |                        |                  | Test         | out      | 'b0       |
| ext_max_sel_mux 		     |         | Npi-1                  | Nout-1:0         | Test         | out      | 'd127     |
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
| ctrl_rstb                  |         | 2:0                    |                  | Test         | out      |   0       |
| exec_ctrl_rstb             |         |                        |                  | Test         | out      |   0       |
| sel_outbuff				 | 		   | 3:0					|				   | Test		  | out 	 |   0		 |
| sel_trigbuff				 | 		   | 3:0					|				   | Test		  | out 	 |   0		 |
| en_outbuff				 | 		   |     					|				   | Test		  | out 	 |   0		 |
| en_trigbuff				 | 		   |     					|				   | Test		  | out 	 |   0		 |
| Ndiv_outbuff				 | 		   | 2:0					|				   | Test		  | out 	 |   0		 |
| Ndiv_trigbuff 			 | 		   | 2:0					|				   | Test		  | out 	 |   0		 |
| bypass_out				 | 		   |     					|				   | Test		  | out 	 |   1		 |
| bypass_trig				 | 		   |     					|				   | Test		  | out 	 |   1		 |
| ffe_shift                  |         | 4:0                    | Nti-1:0          | Test         | out      |   0       |
| channel_shift              |         | 3:0                    | Nti-1:0          | Test         | out      |   0       |
| align_pos		             |         | 3:0			        | 		           | Test 	      | out      |   0 	     |
| fe_inst                    |         | 2:0                    |                  | Test         | out      |   0       |
| fe_exec_inst               |         |                        |                  | Test         | out      |   0       |
| init_ffe_taps              |  yes    | 9:0                    | 15:0             | Test         | out      |   0       |
| fe_adapt_gain              |         | 4:0                    |                  | Test         | out      |   0       |
| fe_bit_target_level        |  yes    | 9:0                    |                  | Test         | out      |   'd70    |
| ce_gain                    |         | 3:0                    |                  | Test         | out      |   1       |
| ce_inst                    |         | 2:0                    |                  | Test         | out      |   0       |
| ce_exec_inst               |         |                        |                  | Test         | out      |   0       |
| ce_addr                    |         | 4:0                    |                  | Test         | out      |   0       |
| ce_val                     |   yes   | 9:0                    |                  | Test         | out      |   0       |
| sample_fir_est             |         |                        |                  | Test         | out      |   0       |
| sample_pos                 |         | 4:0                    |                  | Test         | out      |   0       |
| ce_sampled_value           |   yes   | 9:0                    |                  | System       | in       |           |
| fe_sampled_value           |   yes   | 9:0                    |                  | System       | in       |           |
| cmp_thresh                 |   yes   | 9:0                    | Nti-1:0          | Test         | out      |   0       |
| ffe_thresh                 |   yes   | 9:0                    | Nti-1:0          | Test         | out      |   0       |
| new_trellis_pattern        |   yes   | 1:0                    | 3:0              | Test         | out      |   0       |
| new_trellis_pattern_idx    |         | 1:0                    |                  | Test         | out      |   0       |
| update_trellis_pattern     |         |                        |                  | Test         | out      |   0       |
| adc_thresh                 |   yes   | 7:0                    | Nti-1:0          | Test         | out      |   0       |
| sel_prbs_mux               |         | 1:0                    |                  | System       | out      |   0       |
| sel_trig_prbs_mux          |         | 1:0                    |                  | System       | out      |   0       |
| sel_prbs_bits              |         |                        |                  | System       | out      |   0       |
| en_cgra_clk                |         |                        |                  | Test         | out      |   0       |
| pfd_cal_ext_ave            | yes     | Nadc-1:0               |                  | Test         | out      |   0       |
| pfd_cal_flip_feedback      |         |                        |                  | Test         | out      |   0       |
| en_pfd_cal_ext_ave         |         |                        |                  | Test         | out      |   0       |
| en_int_dump_start          |         |                        |                  | Test         | out      |   0       |
| int_dump_start             |         |                        |                  | Test         | out      |   0       |







