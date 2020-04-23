| Name                       | Signed? | Packed Dim      | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val                                    |
|----------------------------|---------|-----------------|----------------|--------------|----------|----------------------------------------------|
| prbs_checker_mode          |         | 1:0             |                | Test         | out      | 0                                            |
| prbs_init_vals             |         | Nprbs-1:0       | Nti-1:0        | Test         | out      | 3&10&60&11&58&31&67&9&54&55&49&37&92&74&63&1 |
| prbs_correct_bits_upper    |         | 31:0            |                | System       | in       |                                              |
| prbs_correct_bits_lower    |         | 31:0            |                | System       | in       |                                              |
| prbs_total_bits_upper      |         | 31:0            |                | System       | in       |                                              |
| prbs_total_bits_lower      |         | 31:0            |                | System       | in       |                                              |
| prbs_rx_shift              |         | $clog2(Nti)-1:0 |                | System       | in       |                                              |