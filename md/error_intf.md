| Name                      | Signed? | Packed Dim                    | Unpacked Dim   | Clock Domain | JTAG Dir | Reset Val  |
|---------------------------|---------|-------------------------------|----------------|--------------|----------|------------|
| read_errt 	  		    |         | 	                          |                | Test         | out      | 0          |
| addr_errt		  		    |         | 9:0					          |                | Test         | out      | 0          |
| enable_errt               |         |                               |                | Test         | out      | 0          |
| mode_errt                 |         | 1:0                           |                | Test         | out      | 0          |
| output_data_frame_errt    |         | 31:0                          | 4:0            | System       | in       |            |
| number_stored_frames_errt |         | 9:0                           |                | System       | in       |            |
