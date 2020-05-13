| Name                       | Signed? | Packed Dim      | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val                                    |
|----------------------------|---------|-----------------|----------------|--------------|----------|----------------------------------------------|
| prbs_cke                   |         |                 |                | Test         | out      | 1                                            |
| prbs_eqn                   |         | Nprbs-1:0       |                | Test         | out      | 'b00000000000000000000000001100000           |
| prbs_chan_sel              |         | Nti-1:0         |                | Test         | out      | 'hFFFF                                       |
| prbs_inv_chicken           |         | 1:0             |                | Test         | out      | 'b00                                         |
| prbs_checker_mode          |         | 1:0             |                | Test         | out      | 'b00                                         |
| prbs_error_bits_upper      |         | 31:0            |                | System       | in       |                                              |
| prbs_error_bits_lower      |         | 31:0            |                | System       | in       |                                              |
| prbs_total_bits_upper      |         | 31:0            |                | System       | in       |                                              |
| prbs_total_bits_lower      |         | 31:0            |                | System       | in       |                                              |
