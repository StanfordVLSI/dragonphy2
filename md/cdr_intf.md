| Name           | Signed?   | Packed Dim                | Unpacked Dim  | Clock Domain | JTAG Dir | Reset Val |
|----------------|-----------|---------------------------|---------------|--------------|----------|-----------|
| pd_offset_ext  | yes       | Nadc-1:0                  |               | Test         | out      | 0         |
| Ki             | yes       | 4:0                       |               | Test         | out      | 0         |
| Kp             | yes       | 4:0                       |               | Test         | out      | 0         |
| Kr             | yes       | 4:0                       |               | Test         | out      | 0         |
| en_ext_pi_ctl  |           |                           |               | Test         | out      | 1         |
| ext_pi_ctl     |           | Npi-1:0                   |               | Test         | out      | 'h0       |
| en_freq_est    |           |                           |               | Test         | out      | 0         |
| en_ramp_est    |           |                           |               | Test         | out      | 0         |
| phase_est      | yes       | Nadc+1+phase_est_shift:0  |               | System       | in       |           |
| freq_est       | yes       | Nadc+1+phase_est_shift:0  |               | System       | in       |           |
| ramp_est       | yes       | Nadc+1+phase_est_shift:0  |               | System       | in       |           |
| sel_inp_mux    |           |                           |               | Test         | out      | 0         |
| sample_state   |           |                           |               | Test         | out      | 0         |
| invert         |           |                           |               | Test         | out      | 1         |

