| Name                       | Signed? | Packed Dim      | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val                                    |
|----------------------------|---------|-----------------|----------------|--------------|----------|----------------------------------------------|
| tx_data_gen_rst            |         |                 |                | Test         | out      | 1                                            |
| tx_data_gen_mode           |         | 2:0             |                | Test         | out      | 0                                            |
| tx_data_gen_cke            |         |                 |                | Test         | out      | 0                                            |
| tx_data_gen_per            |         | 15:0            |                | Test         | out      | 0                                            |
| tx_data_gen_semaphore      |         |                 |                | Test         | out      | 0                                            |
| tx_data_gen_register       |         | Nti-1           |                | Test         | out      | 0                                            | 
| tx_prbs_gen_init           |         | Nprbs-1:0       | Nti-1:0        | Test         | out      | 'h0ffd4066&'h38042b00&'h001fffff&'h39fbfe59&'h1ffd40cc&'h3e055e6a&'h03ff554c&'h3e0aa195&'h1f02aa60&'h31f401f3&'h00000555&'h300bab55&'h1f05559f&'h3f8afe65&'h07ff5566&'h7f8afccf |
| tx_prbs_gen_eqn            |         | Nprbs-1:0       |                | Test         | out      | 'h100002                                     |
| tx_prbs_gen_inj_err        |         | Nti-1:0         |                | Test         | out      | 0                                            |
| tx_prbs_gen_chicken        |         | 1:0             |                | Test         | out      | 'b00                                         |
