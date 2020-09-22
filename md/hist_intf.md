| Name                       | Signed? | Packed Dim      | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val                                    |
|----------------------------|---------|-----------------|----------------|--------------|----------|----------------------------------------------|
| hist_mode                  |         | 2:0             |                | System       | out      | 'b000                                        |
| hist_sram_ceb              |         |                 |                | System       | out      | 'b0                                          |
| hist_addr                  |         | Nadc-1:0        |                | System       | out      | 0                                            |
| hist_source                |         | 1:0             |                | System       | out      | 'b00                                         |    
| hist_src_idx               |         | 4:0             |                | System       | out      | 0                                            |
| data_gen_mode              |         | 2:0             |                | System       | out      | 'b000                                        |
| data_gen_in_0              |         | Nadc-1:0        |                | System       | out      | 0                                            |
| data_gen_in_1              |         | Nadc-1:0        |                | System       | out      | 0                                            |
| hist_count_upper           |         | 31:0            |                | System       | in       |                                              |
| hist_count_lower           |         | 31:0            |                | System       | in       |                                              |
| hist_total_upper           |         | 31:0            |                | System       | in       |                                              |
| hist_total_lower           |         | 31:0            |                | System       | in       |                                              |
