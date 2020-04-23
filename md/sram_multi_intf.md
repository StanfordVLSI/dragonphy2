| Name                       | Signed? | Packed Dim                          | Unpacked Dim         | Clock Domain | JTAG Dir | Reset Val |
|----------------------------|---------|-------------------------------------|----------------------|--------------|----------|-----------|
| in_addr_multi              |         | N_mem_addr+$clog2(N_mem_tiles)-1:0  |                      | Test         | out      |   'd0     |
| out_data_multi             | yes     | Nadc-1:0                            | Nti+Nti_rep-1:0      | System       | in       |           |
| addr_multi                 |         | N_mem_addr+$clog2(N_mem_tiles)-1:0  |                      | System       | in       |           |
