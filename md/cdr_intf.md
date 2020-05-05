| Name           | Signed?   | Packed Dim                | Unpacked Dim  | Clock Domain | JTAG Dir | Reset Val |
|----------------|-----------|---------------------------|---------------|--------------|----------|-----------|
| pd_offset_ext  | yes       | Nadc-1:0                  |               | Test         | out      | 0         |
| Ki             | yes       | Nadc+1+phase_est_shift:0  |               | Test         | out      | 0         |
| Kp             | yes       | Nadc+1+phase_est_shift:0  |               | Test         | out      | 0         |
| Kr             | yes       | Nadc+1+phase_est_shift:0  |               | Test         | out      | 0         |
| en_ext_pi_ctl  |           |                           |               | Test         | out      | 1         |
| ext_pi_ctl     |           | Npi-1:0                   |               | Test         | out      | 'h0       |
| en_freq_est    |           |                           |               | Test         | out      | 0         |
| en_ramp_est    |           |                           |               | Test         | out      | 0         |
| phase_est      | yes       | Nadc+1+phase_est_shift:0  |               | System       | in       |           |
| freq_est       | yes       | Nadc+1+phase_est_shift:0  |               | System       | in       |           |
| ramp_est       | yes       | Nadc+1+phase_est_shift:0  |               | System       | in       |           |
| sample_state   |           |                           |               | Test         | out      | 0         |
