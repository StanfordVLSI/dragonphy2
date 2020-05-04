| Name            | Signed? | Packed Dim                    | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val  |
|-----------------|---------|-------------------------------|----------------|--------------|----------|------------|
| wme_ffe_data    |         | 31:0                          |                | Test         | out      | 0          |
| wme_ffe_inst    |         | $clog2(Nti)+$clog2(10):0      |                | Test         | out      | 0          |
| wme_ffe_exec    |         |                               |                | Test         | out      | 0          |
| wme_ffe_read    |   yes   | 9:0                           |                | System       | in       |            |
| wme_mlsd_data   |         | 31:0                          |                | Test         | out      | 0          |
| wme_mlsd_inst   |         | $clog2(Nti)+$clog2(30):0      |                | Test         | out      | 0          |
| wme_mlsd_exec   |         |                               |                | Test         | out      | 0          |
| wme_mlsd_read   |   yes   | 7:0                           |                | System       | in       |            |

