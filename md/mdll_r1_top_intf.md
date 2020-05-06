| Name                     | Signed?   | Packed Dim | Unpacked Dim  | Clock Domain | JTAG Dir | Reset Val |
|--------------------------|-----------|------------|---------------|--------------|----------|-----------|
| rstn                     |           |            |               | Test         | out      | 0         |
| en_osc_jtag              |           |            |               | Test         | out      | 0         |
| en_dac_sdm_jtag          |           |            |               | Test         | out      | 1         |
| en_monitor_jtag          |           |            |               | Test         | out      | 0         |
| inj_mode_jtag            |           |            |               | Test         | out      | 1         |
| freeze_lf_dco_track_jtag |           |            |               | Test         | out      | 0         |
| freeze_lf_dac_track_jtag |           |            |               | Test         | out      | 0         |
| load_lf_jtag             |           |            |               | Test         | out      | 0         |
| sel_dac_loop_jtag        |           |            |               | Test         | out      | 0         |
| en_hold_jtag             |           |            |               | Test         | out      | 0         |
| load_offset_jtag         |           |            |               | Test         | out      | 1         |
| en_fcal_jtag             |           |            |               | Test         | out      | 0         |
| fcal_start_jtag          |           |            |               | Test         | out      | 0         |
| jm_bb_out_pol_jtag       |           |            |               | Test         | out      | 1         |
| fb_ndiv_jtag             |           | 3:0        |               | Test         | out      | 'h5       |
| dco_ctl_offset_jtag      |           | 1:0        |               | Test         | out      | 'h0       |
| dco_ctl_track_lv_jtag    |           | 7:0        |               | Test         | out      | 'h1       |
| dac_ctl_track_lv_jtag    |           | 5:0        |               | Test         | out      | 'hf       |
| gain_bb_jtag             |           | 3:0        |               | Test         | out      | 'h8       |
| gain_bb_dac_jtag         |           | 3:0        |               | Test         | out      | 'h1       |
| sel_sdm_clk_jtag         |           | 2:0        |               | Test         | out      | 'h1       |
| prbs_mag_jtag            |           | 3:0        |               | Test         | out      | 'h0       |
| fcal_ndiv_ref_jtag       |           | 3:0        |               | Test         | out      | 'h8       |
| ctl_dac_bw_thm_jtag      |           | 6:0        |               | Test         | out      | 'h7f      |
| ctlb_dac_gain_oc_jtag    |           | 3:0        |               | Test         | out      | 'he       |
| jm_sel_clk_jtag          |           | 2:0        |               | Test         | out      | 'h0       |
| fcal_ready_2jtag         |           |            |               | System       | in       |           |
| fcal_cnt_2jtag           |           | 9:0        |               | System       | in       |           |
| dco_ctl_fine_mon_2jtag   |           | 7:0        |               | System       | in       |           |
| dac_ctl_mon_2jtag        |           | 5:0        |               | System       | in       |           |
| jm_cdf_out_2jtag         |           | 24:0       |               | System       | in       |           |
