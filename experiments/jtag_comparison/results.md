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


