## July 7, 2020
* JTAG test 1: bit_bang=False, uart=True, jtag_sleep_us=1, use_batch_mode=False, print_mode='test', cdr_settling_time=0.1, prbs_test_dur=0.1
  * Test time: 6.9896769523620605 seconds
  * UART bytes transmitted: 39690 
* JTAG test 2: bit_bang=False, uart=True, jtag_sleep_us=1, use_batch_mode=True, print_mode='test', cdr_settling_time=0.1, prbs_test_dur=0.1
  * Test time: 4.185762166976929 seconds
  * UART bytes transmitted: 39690
* JTAG test 3: bit_bang=True, uart=True, jtag_sleep_us=1, use_batch_mode=False, print_mode='debug', cdr_settling_time=0.1, prbs_test_dur=0.1
  * Test time: 237.75752425193787 seconds
  * UART bytes transmitted: 2416386
* JTAG test 4: bit_bang=True, uart=True, jtag_sleep_us=1, use_batch_mode=True, print_mode='debug', cdr_settling_time=0.1, prbs_test_dur=0.1
  * Test time: 211.79461526870728 seconds
  * UART bytes transmitted: 2416386

## July 8, 2020
* Trial 1:
  * JtagTester(comm_style='vio', bit_bang=True, use_ffe=True, print_mode='debug')
  * Register writes: 41
  * Register reads: 4
  * Test took 1573.117070198059 seconds.
* Trial 2:
  * t = JtagTester(comm_style='vio', bit_bang=True, use_ffe=True, print_mode='debug')
  * Register writes: 697
  * Register reads: 4
  * Test took 23908.544766187668 seconds.
  
## July 9, 2020
* Trial 1:
  * JtagTester(use_batch_mode=False, bit_bang=False, print_mode='test')
  * Register writes: 697
  * Register reads: 4
  * Test took 3.76419997215271 seconds.
  * Total bytes transmitted (UART): 41789
* Trial 2:
  * JtagTester(use_batch_mode=True, bit_bang=False, print_mode='test')
  * Register writes: 697
  * Register reads: 4
  * Test took 3.7579543590545654 seconds.
  * Total bytes transmitted (UART): 41789
* Trial 3:
  * JtagTester(use_batch_mode=False, bit_bang=True, print_mode='debug')
  * Test took 186.3524034023285 seconds.
  * Register writes: 697
  * Register reads: 4
  * Total bytes transmitted (UART): 2148226
* Trial 4:
  * JtagTester(use_batch_mode=True, bit_bang=True, print_mode='debug')
  * Test took 186.54292559623718 seconds.
  * Register writes: 697
  * Register reads: 4
  * Total bytes transmitted (UART): 2148226





