| Name                       | Signed? | Packed Dim      | Unpacked Dim | Clock Domain | JTAG Dir | Reset Val |
|----------------------------|---------|-----------------|--------------|--------------|----------|-----------|
| in_addr                    |         | N_mem_addr-1:0  |              | Test         | out      |   'd0     |
| out_data                   | yes     | Nadc-1:0        | Nti+Nti_rep-1:0      | System       | in       |           |
| addr                       |         | N_mem_addr-1:0  |              | System       | in       |           |
