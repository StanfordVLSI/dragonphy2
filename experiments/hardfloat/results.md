August 17, 2020
* First experiment run with HardFloat.  The high-level architecture was used, and the board targeted was ZC706.
  * command: ``time pytest -s -k test_3 --board_name ZC706 --emu_clk_freq 30e6``
  * Timing:
    * worst negative slack is -48.926ns (issue on emu_clk)
    * minor hold time violations as well that would likely be cleaned up during routing
  * Slice LUTs: 714458 / 218600
    * analog_core: 662072
      * per slice: 41327 (one slice takes up the whole digital core worth of LUTs)
      * outside of the slices: 840
    * digital_core: 41184
    * outside of analog_core and digital_core: 11202
    * outside of the slices: 53226
  * Slice Registers: 29168 / 437200
    * analog_core: 7408
    * digital_core: 17797
  * DSP: 1380 / 900
    * 86 per slice
  * BRAM: 218.5 / 545
  * Build time: 93m49.364s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM.  32 GB swap space.
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Looks like using a chunk size of "1" would fit with an expected LUT utilization of 135880 (there may be some fixed offsets not accounted, though)
  * Looks like emu_clk needs to be slowed down to around 10 MHz to pass timing.
  * Overall expected reduction in speed is 3x8 = 24x, or around 3.3 Mb/s.
* Adjusting the high-level model to allow chunks of non-default size.
  * Works fine down to chunk_width=2, but there is a problem with chunk_width=1
  * That issue is now fixed by special-casing chunk_width=1 in the model generator
* Second experiment run with HardFloat.  The high-level architecture was used, and the board targeted was ZC706.
  * command: ``time pytest -s -k test_3 --board_name ZC706 --emu_clk_freq 10e6``
  * Timing: passes (small hold time violations)
    * For emu_clk, the worst slack is +19.314ns, so the speed could be increased to around 11.2 MHz if need be.
  * Slice LUTs: 252555 / 218600
    * analog_core: 202310
      * per slice: 12595 
      * outside of the slices: 790
    * digital_core: 41057
    * outside of analog_core and digital_core: 9188
    * outside of the slices: 51035 
  * Slice Registers: 25579 / 437200
    * analog_core: 3819
    * digital_core: 17795
  * DSP: 868 / 900
    * 54 per slice
  * BRAM: 106.5 / 545
  * Build time: 38m47.677s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM.  32 GB swap space.
* Third experiment run with HardFloat.  The high-level architecture was used, and the board targeted was ZC706.  This time ADC noise was disabled to save space.  Unfortunately, the build still didn't complete since the LUTs could not be packed into slices (the number of LUTs is very close to the limit)
  * command: ``time pytest -s -k test_3 --board_name ZC706 --emu_clk_freq 10e6``
  * Timing: Slack is +19.314ns as before
  * Slice LUTs: 212049 / 218600
    * analog_core: 161665
      * per slice: 10071 
      * outside of the slices: 
    * digital_core: 41196
    * outside of analog_core and digital_core: 
    * outside of the slices: 
  * Slice Registers: 24555 / 437200
    * analog_core: 2795
    * digital_core: 17795
  * DSP: 706 / 900
    * 44 per slice
  * BRAM: 90.5 / 545
  * Build time: 45m40.054s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM.  32 GB swap space.
* Fourth experiment run with HardFloat.  The high-level architecture was used, and the board targeted was ZC706.  ADC noise and jitter both had to be disabled.
  * command: ``time pytest -s -k test_3 --board_name ZC706 --emu_clk_freq 10e6``
  * Timing: no issues
  * Slice LUTs: 163122 / 218600
    * analog_core: 113946
      * per slice: 7084
      * outside of the slices: 
    * digital_core: 40093
    * outside of analog_core and digital_core: 
    * outside of the slices: 
  * Slice Registers: 24037 / 437200
    * analog_core: 1771
    * digital_core: 17796
  * Slices: 47477 / 54650
  * DSP: 544 / 900
    * 34 per slice
  * BRAM: 74.5 / 545
  * Build time: 56m21.136s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM.  32 GB swap space.
  * Doesn't seem to work unfortunately, need to add some debug probes to investigate.
* Fifth experiment run with HardFloat.  The high-level architecture was used, and the board targeted was ZC706.  Both noise sources had to be disabled to fit within board resources, and a bug in the clk_adc generated was fixed.  Also, a bunch of debug probes were added.
  * command: ``time pytest -s -k test_3 --board_name ZC706 --emu_clk_freq 10e6``
  * Timing: no issues, but slack is down to 3.636ns
  * Slice LUTs: 163909 / 218600
    * analog_core: 113922
      * per slice: 7086
      * outside of the slices: 
    * digital_core: 40121
    * outside of analog_core and digital_core: 
    * outside of the slices: 
  * Slice Registers: 25211 / 437200
    * analog_core: 1771
    * digital_core: 17797
  * Slices: 47888 / 54650
  * DSP: 544 / 900
    * per slice: 34
  * BRAM: 82 / 545
  * Build time: 55m41.090s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM.  32 GB swap space.
  * Didn't work, appears the problem may be within one of the slices so that will be tested next

August 18, 2020
* Sixth experiment with HardFloat
  * Build time: 54m23.446s
  * Looks OK: chunk, chunk_idx, pi_ctl, samp_ctl, incr_sum, write_output, slice_rst
  * Not OK: out_sgn, out_mag
  * Looks OK: weights, t_samp_pre (should be zero in this case), 
  * Not OK: chg_idx looks suspect for two reasons: first the values are the same for both 0 and 1.  Second, the values look like they would be pretty large.
  * With that in mind, t_chg and t_eval look OK.  f_eval looks OK too.
  * By the time the signal gets to pulse_resp, it is zero
  * Seems that it is possible that, only in synthesis, integer constants used in MAKE_CONST_REAL, MUL_REAL, etc. are getting converted to zero.
* Seventh experiment with HardFloat.  The clock frequency was reduced to 5MHz, the noise sources were disabled, and a bunch of debug probes were added.  Since the clock frequency was reduced, the JTAG sleep time was set to 20us (originally 1us)
  * Build time: 59m43.479s
  * Seems to have worked.
  * Timing: No issues; slack is 96.023ns on a 200ns clock period.  Suggests the design could have worked up to 9.6 MHz.
  * Slice LUTs: 169057 / 218600
    * analog_core: 117205
      * per slice: 7350
    * digital_core: 39901
  * Slice Registers: 29299 / 437200
    * analog_core: 1894
    * digital_core: 17795
  * Slices: 48991 / 54650
  * DSP: 544 / 900
    * per slice: 34
  * BRAM: 133 / 545
  * PRBS test took 30.07004952430725 seconds.
  * Total bits: 70694320
  * 2.35 Mb/s
