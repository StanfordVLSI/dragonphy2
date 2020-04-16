| Name | Signed? | Packed Dim | Unpacked Dim | Clock Domain | JTAG Dir | Reset Val |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| pd_offset_ext | yes | Nadc-1:0 |  | Test | out | 0 |
| Ki | yes | Nadc+1+phase_est_shift:0 |  | Test | out | 'h000100 |
| Kp | yes | Nadc+1+phase_est_shift:0 |  | Test | out | 'h010000 |
| en_ext_pi_ctl | no |  |  | Test | out | 0 |
| en_freq_est | no |  |  | Test | out | 0 |
| phase_est | yes | Npi-1:0 |  | System | in |  |