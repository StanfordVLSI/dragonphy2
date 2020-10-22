| Name                       | Signed? | Packed Dim      | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val                                    |
|----------------------------|---------|-----------------|----------------|--------------|----------|----------------------------------------------|
| prbs_cke                   |         |                 |                | System       | out      | 1                                            |
| prbs_eqn                   |         | Nprbs-1:0       |                | System       | out      | 'b00000000000000000000000001100000           |
| prbs_chan_sel              |         | Nti-1:0         |                | System       | out      | 'hFFFF                                       |
| prbs_inv_chicken           |         | 1:0             |                | System       | out      | 'b00                                         |
| prbs_checker_mode          |         | 1:0             |                | System       | out      | 'b00                                         |
| prbs_err_bits_upper        |         | 31:0            |                | System       | in       |                                              |
| prbs_err_bits_lower        |         | 31:0            |                | System       | in       |                                              |
| prbs_total_bits_upper      |         | 31:0            |                | System       | in       |                                              |
| prbs_total_bits_lower      |         | 31:0            |                | System       | in       |                                              |
| prbs_gen_cke               |         |                 |                | System       | out      | 0                                            |
| prbs_gen_init              |         | Nprbs-1:0       |                | System       | out      | 'h00000001                                   |
| prbs_gen_eqn               |         | Nprbs-1:0       |                | System       | out      | 'b00000000000000000000000001100000           |
| prbs_gen_inj_err           |         |                 |                | System       | out      | 0                                            |
| prbs_gen_chicken           |         | 1:0             |                | System       | out      | 'b00                                         |

