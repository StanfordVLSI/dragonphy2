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
