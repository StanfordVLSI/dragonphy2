Jun 22, 2020
* simulation with 4x channels:
  * PRBS test took 27.614053 seconds.
  * Total bits: 600000
  * Throughput: 21.7 kb/s

Jun 24, 2020
* Emulation with 16x channels on ZC706:
  * PRBS test took 30.073444843292236 seconds.
  * Total bits: 150258080
  * 4.996 Mb/s
  * Slice LUTs: 58678 / 218600
  * Slice Registers: 24928 / 437200
  * Slice: 19436 / 54650
  * DSP: 299 / 900
  * BRAM: 42.5 / 545
  * Build time: 30m 35.161s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
* Simulation with 16x channels (using Xcelium)
  * PRBS test took 42.509094 seconds.
  * Total_bits: 608192
  * Throughput: 14.3 kb/s
  * r7cad-generic processor, CentOS Linux release 7.7.1908 (Core), 128 GB RAM
    * /proc/cpuinfo did not display the real CPU information since r7cad-generic is a VM

July 6, 2020
* Emulation with 16x channels on ZC706, using a macro model for analog_core that computes all of the ADC samples in parallel.  This measurement used a history length of 32 bits, processed over 4 cycles in chunks of size 8.  For this experiment, "flatten_hierarchy" was set to "none" since this had solved a synthesis issue in the previous emulation architecture.  However, this may have caused the resource utilization to be high.
  * Command: ``time pytest tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_6 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 20e6 --prbs_test_dur 30``
  * PRBS test took 30.072776794433594 seconds.
  * Total bits: 1602767056
  * 53.30 Mb/s
  * Slice LUTs: 99149 / 218600
    * analog_core: 48741 
    * digital_core: 47508
  * Slice Registers: 30487 / 437200
    * analog_core: 8132
    * digital_core: 17617
  * Slice: 32971 / 54650
    * analog_core: 16475
    * digital_core: 15730
  * DSP: 652 / 900
    * Each slice is using about 40-43 DSP blocks.  All 652 DSPs are used in the analog_slice instances.  
  * BRAM: 42.5 / 545
    * Interesting to note that each analog slice uses about 27 LUTs and 17 FF for each sync_rom_real.  Each slice has 18 ROMs, so that accounts for 7.8k LUTs and 4.9k FFs.
  * Build time: 38m17.143s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`

July 7, 2020
* Emulation with 16x channels on ZC706, using a macro model for analog_core that computes all of the ADC samples in parallel.  This measurement used a history length of 32 bits, processed over 4 cycles in chunks of size 8.  For this experiment, "flatten_hierarchy" was set to "rebuilt" (default from Vivado)
  * Command: ``time pytest tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_6 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 30e6 --prbs_test_dur 30``
  * PRBS test took 30.072660207748413 seconds.
  * Total bits: 2404040576
  * 79.94 Mb/s
  * Slice LUTs: 88561 / 218600
    * analog_core: 35756 
    * digital_core: 40118
  * Slice Registers: 25225 / 437200
    * analog_core: 3043
    * digital_core: 17797
  * Slice: 27900 / 54650
    * analog_core: 
    * digital_core: 
  * DSP: 720 / 900
  * BRAM: 42.5 / 545
  * Build time: 36m13.436s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`

July 8, 2020
* Emulation with 16x channels on ZC706, using a macro model for analog_core that computes all of the ADC samples in parallel.  This measurement used a history length of 32 bits, processed over 4 cycles in chunks of size 8.  For this experiment, "flatten_hierarchy" was set to "rebuilt" (default from Vivado).  The fpga_sim_ctrl option used here was "VIVADO_VIO", for comparison with "UART_ZYNQ"
  * Command: ``time pytest tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 30e6 --prbs_test_dur 30 --fpga_sim_ctrl VIVADO_VIO``
  * PRBS test took  seconds.
  * Total bits: 
  *  Mb/s
  * Slice LUTs: 88383 / 218600
    * analog_core: 35754
    * digital_core: 40170
  * Slice Registers: 24737 / 437200
    * analog_core: 3043
    * digital_core: 17796
  * Slice: 28508 / 54650
    * analog_core: 11354
    * digital_core: 15004
  * DSP: 720 / 900
  * BRAM: 42.5 / 545
  * Build time: 37m31.047s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`

July 16, 2020
* First experiment with Gaussian noise -- there is an issue in this particular implementation having to do with LFSR seeding, since all of the analog_slices unfortunately are using the same seeds (although within each slice, the seeds for the sampling time and ADC noise are different).  Emulation with 16x channels on ZC706, using a macro model for analog_core that computes all of the ADC samples in parallel.  This measurement used a history length of 32 bits, processed over 4 cycles in chunks of size 8.  For this experiment, "flatten_hierarchy" was set to "rebuilt" (default from Vivado).
  * Command: ``time pytest tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 30e6 --prbs_test_dur 1``
  * PRBS test took 30.050543308258057 seconds.
  * Total bits: 2402858272
  * 79.96 Mb/s
  * Slice LUTs: 94128 / 218600
    * analog_core: 38263
    * digital_core: 40007
  * Slice Registers: 26261 / 437200
    * analog_core: 4063
    * digital_core: 17795
  * Slice: 29521 / 54650
    * analog_core: 12110
    * digital_core: 14743
  * DSP: 850 / 900
  * BRAM: 50.5 / 545
  * Build time: 40m5.904s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * In CPU simulation, the max jitter is "31" (3.1ps) and max noise is "658" (65.8mV); the observation period is approximately 10,000 bits.  In emulation, which is running about 2 billion bits over 30 seconds, the max jitter is reduced to "23" (2.3ps) and max noise is reduced to "564" (56.4mV).  The "maximum" in this case is the highest value of the parameter that yields no bit errors over the observation period, with the other noise sources set to "0".

July 16, 2020
* Second experiment with Gaussian noise -- this one fixed the previous issue with random seeding.  Emulation with 16x channels on ZC706, using a macro model for analog_core that computes all of the ADC samples in parallel.  This measurement used a history length of 32 bits, processed over 4 cycles in chunks of size 8.  For this experiment, "flatten_hierarchy" was set to "rebuilt" (default from Vivado).
  * Command: ``time pytest tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 30e6 --prbs_test_dur 1``
  * PRBS test took 30.038529634475708 seconds.
  * Total bits: 2402005872
  * 79.96 Mb/s
  * Slice LUTs: 94244 / 218600
    * analog_core: 38184
    * digital_core: 40123
  * Slice Registers: 26259 / 437200
    * analog_core: 4060
    * digital_core: 17796
  * Slice: 29215 / 54650
    * analog_core: 12050
    * digital_core: 14464
  * DSP: 850 / 900
  * BRAM: 50.5 / 545
  * Build time: 42m31.562s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Max noise code: "501" (--noise_rms 50.1e-3)
  * Max jitter code: "25" (--jitter_rms 2.5e-12)

Jul 17, 2020
* Simulation with 16x channels (using Xcelium)
  * Command: ./experiment.py --noise_rms 10e-3 --jitter_rms 1e-12
  * PRBS test took 38.306903 seconds.
  * Total_bits: 608192
  * Throughput: 15.9 kb/s
  * Max noise: 61 mV RMS  (@600k bits)
  * Max jitter: 4.3 ps RMS (@600k bits)
  * Interesting to observe that slightly higher noise is tolerated in this setup, particularly for jitter.  Possibly due to the Gaussian tail distortion in the emulator, or differences in the channel model (PWL LPF in simulation vs. PWL lookup table superposition).
  * r7cad-generic processor, CentOS Linux release 7.7.1908 (Core), 128 GB RAM
    * /proc/cpuinfo did not display the real CPU information since r7cad-generic is a VM

July 18, 2020
* Gaussian noise expermient with "low-level" model.  Emulation on ZC706, with flatten_hierarchy set to none for debugging.
  * Command: ``time pytest tests/fpga_system_tests/emu/test_emu.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 20e6 --prbs_test_dur 1 --flatten_hierarchy none``
  * PRBS test took  seconds.
  * Total bits: 
  *  Mb/s
  * Slice LUTs: 64852 / 218600
    * analog_core: 8336
    * digital_core: 47254
  * Slice Registers: 26603 / 437200
    * analog_core: 2039
    * digital_core: 17635
  * Slice: 20911 / 54650
    * analog_core: 2694 
    * digital_core: 15253
  * DSP: 581 / 900
  * BRAM: 53.5 / 545
  * Build time: 33m36.902s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Max noise code: "560" (--noise_rms 56e-3)
  * Max jitter code: "26" (--jitter_rms 2.6e-12)
* same as previous, but using default flatten_hierarchy setting (rebuilt)
  * PRBS test took 30.04912281036377 seconds.
  * Total bits: 150773520
  * 5.018 Mb/s
  * Slice LUTs: 76989 / 218600
    * analog_core: 15547
    * digital_core: 40043
  * Slice Registers: / 437200
    * analog_core: 1247
    * digital_core: 17813
  * Slice: 23970 / 54650
    * analog_core: 4656
    * digital_core: 14123
  * DSP: 258 / 900
  * BRAM: 49 / 545
  * Build time: 34m7.993s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Max noise code: "570" (--noise_rms 57e-3)
  * Max jitter code: "26" (--jitter_rms 2.6e-12)

July 19, 2020
* Gaussian noise expermient with "low-level" model.  Emulation on ZC706 with flatten_hierarchy set to default (rebuilt).  For this experiment, there is just one CPU register each for noise_rms and jitter_rms to reduce resource utilization and simplify the design.
  * command: ``time pytest tests/fpga_system_tests/emu/test_emu.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 20e6 --prbs_test_dur 1``
  * PRBS test took 30.042307376861572 seconds.
  * Total bits: 150163760
  * 4.998 Mb/s
  * Slice LUTs: 77359 / 218600
    * analog_core: 15556
    * digital_core: 40056
  * Slice Registers: 24928 / 437200
    * analog_core: 1247
    * digital_core: 17813
  * Slice: 24221 / 54650
    * analog_core: 4635
    * digital_core: 14152
  * DSP: 238 / 900
    * interesting to note that some multiplications use up to 4 DSPs while others use 100-200 LUTs
    * for rx_adc_core, LUT utilization is 698 and DSP utilization is 6 (16x instances)
    * for clk_delay_core, LUT utilization is 701 and DSP utilization is 7 (4x instances)
    * for chan_core, LUT utilization is 11,856 and DSP utilization is 100 (1x instances)
    * total LUT utilization ends up being 13,972 for ADC and PI (124 DSPs)
  * BRAM: 49 / 545
  * Build time: 34m28.312s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Max noise code: "560" (--noise_rms 56e-3)
  * Max jitter code: "26" (--jitter_rms 2.6e-12)
* same as above, but with LONG_WIDTH_REAL and DT_WIDTH reduced from 32 to 25
  * command: ``time pytest tests/fpga_system_tests/emu/test_emu.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 20e6 --prbs_test_dur 1``
  * PRBS test took 30.054484367370605 seconds.
  * Total bits: 150206112
  * 4.998 Mb/s
  * Slice LUTs: 62288 / 218600
    * analog_core: 6407
    * digital_core: 40117
  * Slice Registers: 24690 / 437200
    * analog_core: 1191
    * digital_core: 17813
  * Slice: 20121 / 54650
    * analog_core: 2040
    * digital_core: 14248
  * DSP: 187 / 900
    * for rx_adc_core, LUT utilization is 255 and DSP utilization is 5 (16x instances)
    * for clk_delay_core, LUT utilization is 410 and DSP utilization is 5 (4x instances)
    * for chan_core, LUT utilization is 6096 and DSP utilization is 75 (1x instances)
    * total LUT utilization ends up being 5720 for ADC and PI (100 DSPs)
  * BRAM: 48.5 / 545
  * Build time: 30m44.765s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Max noise code: "560" (--noise_rms 56e-3)
  * Max jitter code: "26" (--jitter_rms 2.6e-12)

July 21, 2020
* First experiment with updatable functions, run on the "high-level" model.  A PWL representation was used for functions, with width=18 and exponent=-16 for both the offset and slope values (representing about +/-2 for each).  Run on ZC706.
  * command: ``time pytest tests/fpga_system_tests/emu_macro/test_emu_macro.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB0 --ffe_length 10 --emu_clk_freq 30e6 --prbs_test_dur 1``
  * PRBS test took 30.06890892982483 seconds.
  * Total bits: 2403924544
  * 79.95 Mb/s
  * Slice LUTs: 85102 / 218600
    * analog_core: 29028
    * digital_core: 40163
  * Slice Registers: 23828 / 437200
    * analog_core: 1596
    * digital_core: 17797
  * Slice: 27902 / 54650
    * analog_core: 9837
    * digital_core: 15254
  * DSP: 850 / 900
    * 53 per slice
  * BRAM: 194.5 / 545
    * 9.5 per slice (16x), 32 in digital core and 10.5 from debug core
    * sync_rams are all using 1/2 slice as expected
  * Build time: 47m40.715s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Maximum time constant: 217ps (--chan_tau=217e-12)

July 23, 2020
* Second experiment with updatable functions, this time run on the "low-level" model.  A PWL representation was used for functions, with width=18 and exponent=-16 for both the offset and slope values (representing about +/-2 for each).  Run on ZC706.
  * command: ``time pytest tests/fpga_system_tests/emu/test_emu.py::test_3 -s --board_name ZC706 --ser_port /dev/ttyUSB1 --ffe_length 10 --emu_clk_freq 20e6 --prbs_test_dur 1``
  * PRBS test took 30.0692880153656 seconds.
  * Total bits: 150234304
  * 4.996 Mb/s
  * Slice LUTs: 60655 / 218600
    * analog_core: 6405
    * digital_core: 40044
  * Slice Registers: 24311 / 437200
    * analog_core: 1191
    * digital_core: 17813
  * Slice: 19882 / 54650
    * analog_core: 2106 
    * digital_core: 14249
  * DSP: 187 / 900
  * BRAM: 73.5 / 545
    * exactly 25 for the channel model (i.e., number of taps).  this is the only delta in BRAM usage from the previous fixed-function version, so this is all as expected.
  * Build time:  31m3.938s with Vivado 2020.1 on Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz, Ubuntu 18.04.2 LTS, 6 GB RAM
    * use `cat /proc/cpuinfo`, `cat /proc/meminfo`, `lsb_release -a`
  * Maximum time constant: 217ps (--chan_tau=217e-12)

August 11, 2020
* Experiment building for ZCU106.  In general the build seems to be much slower, taking 1.6 hours to complete.  I had to use the option "-stack 2000" and increase swap space to 32 GB to get the build to complete.  Unknown whether both options are needed or just the swap space increase, but the peak memory consumption was 14.5 GB, which is 0.5 GB more than what was available before.
* The build took 1.6 hours & the design did not meet timing with emu\_clk\_freq set to 30 MHz.  WNS was 1.341 ns with 134 failing endpoints and WHS was 0.014 ns with 6 failing endpoints.
* All failing endpoints for WNS are from clk\_pl\_0 to emu\_clk, which shouldnt even be considered as a source\_clk.
* The hold-time violation is within emu\_clk and inside the PRBS generator.  Looks like it is caused by high clock skew.
* Overall resource utilization is 92455 LUTs, 25157 DFF, 194.5 BRAM, 850 DSPs, which is quite similar to what had been seen before.
* The clocks listed are:
  * clk_in1_p: external clock
  * clk_other_0: "clk ADC"
  * clk_out1_clk_wiz_0: emu_clk_2x
  * clk_out2_clk_wiz_0: dbg_hub_clk
  * clk_pl_0: internal to the block diagram
  * dbg_hub/inst/BSCANID.u_xsdbm_id/SWITCH_N_EXT_BSCAN.bscan_inst/SERIES7_BSCAN.bscan_inst/INTERNAL_TCK: ???
  * emu_clk: emu_clk
* A good path forward could be to set false paths on the outputs of the Zynq core.  The individual paths are:
  * ``sim_ctrl_gen_i/zynq_gpio_i/i_ctrl``
  * ``sim_ctrl_gen_i/zynq_gpio_i/i_data``
  * ``sim_ctrl_gen_i/zynq_gpio_i/o_ctrl``
  * ``sim_ctrl_gen_i/zynq_gpio_i/o_data``
* As a shorthand, we can specify:
  * ``set_false_path -through [get_pins sim_ctrl_gen_i/zynq_gpio_i/*]``
* After adding that false path, the timing issues are resolved and the build time was reduced to 1.3 hrs (still using a lot of memory, though).  Utilization is similar at 92420 LUTS, 25167 FFs, 194.5 BRAM, 850 DSPs.

August 25, 2020
* Experiment to verify BER result.
* Looked at a few different variables in the CPU comparison simulation.
  * Max time constant is 217 ps, so 100ps is a good default choice
  * For 100ps, 15 ps is a good default delay.  The PI code (with no noise) should be ... in that case.
  * For 100ps tau and 15 ps delay, the max jitter is 8 ps and the max noise is 32 mV
  * For the dist_normal functions, which had been using integers between 0 and 1000, it looks like a much higher value should be used for proper modeling of the tails.  10,000,000 seems to be a good choice since there is an issue with 1,000,000,000 (100,000,00 is OK too)
  * To get a small, but reliable, error rate in simulation, it is recommended to pick 5.6 ps jitter and 23 mV noise (with 100ps tau and 15 ps delay).  Expected BER is about 1.095e-4 (@2M)
  * With 2M bits, it takes 1.5 min to simulate, so 40 Mbit can fit in a half hour.
  * Can get down to 6e-6 BER (@2M) with 5ps and 20mV noise
  * With 8.4 ps and 37 mV, the BER is 1.218e-2 (@100k)
  * With 8.2 ps and 36 mV, the BER is 9.57e-3 (@100k), 1.012e-2 @ 1M samples 
    * For the FPGA: 7.572e-3 BER @ 80 M samples (using 100ps tau and 15 ps delay)
    * For the FPGA: 7.525e-3 BER @ 80 M samples (using 100ps tau and 18.75 ps delay)
    * mismatch could be related to short PRBS equation on FPGA -- 7 bit vs 21 bit in simulation.  may need to re-build to wire out that signal
    * After switching to the same PRBS equation for the FPGA, the BER is pretty much unchanged: 7.566e-3
    * Could be related to PWL accuracy settings in simulation, too.
    * In CPU simulation with etol=0.01: BER=1.267400e-02 (1M samples)
    * In CPU simulation with etol=0.001: BER=1.012000e-02 (1M samples)
    * In CPU simulation with etol=0.0001: BER=9.995000e-03 (1M samples)
    * In CPU simulation with etol=0.00001: BER=9.939000e-03 (1M samples)
    * In CPU simulation with etol=0.000001: BER=9.933000e-03 (1M samples)
    * In CPU simulation with t_tr=10e-12: BER=1.012000e-02 (1M samples)
    * In CPU simulation with t_tr=1e-12: BER=9.832000e-03 (1M samples)
    * In CPU simulation with t_tr=0.1e-12: BER=9.828000e-03 (1M samples)
    * In CPU simulation with t_tr=0.01e-12: BER=9.861000e-03 (1M samples)
    * In CPU simulation with timescales explicitly set for various blocks in the tb/ directory: BER: 1.012000e-02 (1M samples).  In other words no change at all
  * With 8.0 ps and 35 mV, the BER is 7.67e-3 (@100k)
  * With 7.8 ps and 34 mV, the BER is 6.47e-3 (@100k)
  * With 7.6 ps and 33 mV, the BER is 5.06e-3 (@100k)
  * With 7.4 ps and 32 mV, the BER is 3.80e-3 (@100k)
  * With 7.2 ps and 31 mV, the BER is 2.69e-3 (@100k)
  * With 7.0 ps and 30 mV, the BER is 1.88e-3 (@100k)
  * With 6.8 ps and 29 mV, the BER is 1.41e-3 (@100k)
  * With 6.6 ps and 28 mV, the BER is 1.11e-3 (@200k), 1.1325e-3 @ 2M samples
    * For the FPGA: 1.758e-3 BER @ 80 M samples (using 100ps tau and 15 ps delay)
    * For the FPGA: 1.722e-3 BER @ 80 M samples (using 100ps tau and 18.75 ps delay)
    * For the FPGA with updated PRBS eqn: 1.752273e-03 (with 15ps delay)
  * With 6.4 ps and 27 mV, the BER is 6.3e-4 (@200k)
  * With 6.2 ps and 26 mV, the BER is 4.35e-4 (@200k)
  * With 6.0 ps and 25 mV, the BER is 2.4e-4 (@200k)
  * With 5.8 ps and 24 mV, the BER is 2.33e-4 (@400k)
  * With 5.6 ps and 23 mV, the BER is 1.095e-4 (@2M), 1.1925e-4 @4M samples
    * For the FPGA: 4.251e-4 BER @ 80 M samples (using 100ps tau and 15 ps delay)
    * For the FPGA: 4.308e-4 BER @ 80 M samples (using 100ps tau and 18.75 ps delay)
    * For the FPGA with updated PRBS eqn: 4.233167e-04
  * With 5.0 ps and 20 mV, the BER is 1.275e-5 (@40M) 
    * For the FPGA: 1.356e-4 BER @ 80 M samples (using 100ps tau and 15 ps delay)
    * For the FPGA: 1.428e-4 BER @ 80 M samples (using 100ps tau and 18.75 ps delay)
    * For the FPGA with updated PRBS eqn: 1.331437e-04
* Debugging the mismatch.
  * On the FPGA, with a 100ps tau and 15ps delay, the PI CTL code is 30-32.  This matches pretty well with the CPU simulation which is 32-33 (originally there was some extra delay on the CPU side due to the rise/fall time of the TX driver -- this was bumping the codes up to 41-42)
  * On the FPGA, with a 100ps tau and 18.75ps delay, the PI CTL code is 39-40.  This is exactly the same as seen in the CPU simulation.
  * On the CPU side, need to investigate both the meaning of "tau" and the error tolerance settings.

August 27, 2020:
* Investigating BER discrepancy -- now using the new Gaussian modeling that better represents the tails of the distribution.
  * Build time: 41m58.077s
  * Timing: no issues
  * Slice LUTs: 89528 / 218600
    * analog_core: 33371
    * digital_core: 40018
  * Slice Registers: 24376 / 437200
    * analog_core: 1757
    * digital_core: 17795
  * Slice: 28983 / 54650
    * analog_core: 11107
    * digital_core: 15253
  * DSP: 850 / 900
  * BRAM: 194.5 / 545
* Tests
  * Use 100ps tau and 15 ps delay with 10s test duration as default expect where noted
  * FPGA (expected values from CPU)
    * Look at 8.2 ps and 36 mV (expect around 1.012e-2)
      * got 3.727750e-03
      * got 3.759463e-03 with 18.75 ps
      * got 3.727197e-03 over 30s
    * Look at 6.6 ps and 28 mV (expect around 1.1325e-3)
      * got 2.761388e-04
    * Look at 5.6 ps and 23 mV (expect around 1.1925e-4)
      * got 2.042935e-05
    * Look at 5.0 ps and 20 mV (expect around 1.275e-5)
      * got 2.347451e-06
    * Look at 47 mV (no jitter)
      * got 1.554461e-03
    * Look at 39 mV (no jitter)
      * got 1.273410e-04
    * Look at 32 mV (no jitter)
      * got 2.915821e-06
    * Look at 13 ps (no ADC noise)?
      * (scale only goes up to 10)
    * Look at 10 ps (no ADC noise)
      * got 1.391138e-03 (28.3% higher than CPU)
    * Look at 9 ps
      * got 4.865750e-04 (46.1% higher than CPU) 
    * Look at 8 ps (no ADC noise)
      * got 1.305171e-04 (85.1% higher than CPU)
  * CPU (measured values are 2M samples)
    * Look at 47 mV (no jitter)
      * got 9.134500e-03
    * Look at 39 mV (no jitter)
      * got 1.791000e-03
    * Look at 32 mV (no jitter)
      * got 1.290000e-04
    * Look at 13 ps (no ADC noise)
      * got 1.079800e-02
    * Look at 10 ps (no ADC noise)
      * got 1.084500e-03
    * Look at 9 ps (no ADC noise)
      * got 3.330000e-04
    * Look at 8 ps (no ADC noise)
      * got 7.050000e-05

August 28, 2020
* For comparison purposes, am running the same CPU vs. FPGA comparison using the low-level architecture.  One of the key differences are the values coming out of the PRBS generator.  In the low-level architecture, a single PRBS generator provides these, whereas in the low-level architecture, these come from parallel generators that are seeded to provide different sequences.  But the seeding does not yet produce the same sequence (i.e., would need to pick the seed values in a certain way to make the sequences match).  There is also potentially a difference in the effects of jitter, since in the low-level architecture, 4 PIs are run through clock dividers to produce sampling signals, whereas in the high-level architecture, all 16 sampling points are computed separately.
  * Build time: 32m8.282s
  * Timing: No issues
  * Slice LUTs: 63324 / 218600
    * analog_core: 9171
    * digital_core: 40046
  * Slice Registers: 24451 / 437200
    * analog_core: 1301
    * digital_core: 17813
  * Slice: 20639 / 54650
    * analog_core: 2925
    * digital_core: 14283
  * DSP: 110 / 900
  * BRAM: 187 / 545
* Experiments  
  * In terms of signal amplitude, seeing +/- 118 at tau == 100 ps.  For default setting (25ps?), the ADC output is basically clipped.  Could be that there is a discrepancy in amplitude between CPU and FPGA.
  * FPGA (expected values from CPU).  Using 10 second measurement except as noted.
    * Look at 8.2 ps and 36 mV (expect around 1.012e-2)
      * got 3.457085e-03.  pretty close to high-level, but not close to low-level
      * got 3.457829e-03 with 30 second measurement.  Almost exactly the same as shorter measurement.
      * got 9.963938e-02 with 18.75 ps delay. ???
      * got 9.979784e-02 with 18.5 ps delay. ???
      * got 3.486779e-03 with 18 ps delay.
    * Look at 6.6 ps and 28 mV (expect around 1.1325e-3)
      * got 2.340181e-04
      * got 2.511964e-04 with 18.75ps delay
    * Look at 5.6 ps and 23 mV (expect around 1.1925e-4)
      * got 1.440353e-05
      * got 1.667146e-05 with 18.75ps delay
    * Look at 5.0 ps and 20 mV (expect around 1.275e-5)
      * got 1.733487e-06 with 15ps delay
      * got 1.374297e-06 with 18.75ps delay
    * Look at 47 mV (no jitter).  Expect 9.134500e-03
      * got 1.506769e-03
      * got 9.110364e-04 with 18.75 ps delay
    * Look at 39 mV (no jitter).  Expect 1.791000e-03
      * got 1.165054e-04 with 15 ps delay
      * got 5.621766e-05 with 18.75 ps delay
    * Look at 32 mV (no jitter).  Expect 1.290000e-04
      * got 3.289563e-06 with 15 ps delay
      * got 1.016820e-06 with 18.75 ps delay
    * Look at 10 ps (no ADC noise).  Expect 1.084500e-03
      * got 1.797101e-01 with 15 ps delay
      * got 1.824650e-01 with 18.75 ps delay
    * Look at 9 ps.  Expect 3.330000e-04
      * got 1.056114e-02 with 15 ps delay
      * got 1.785382e-01 with 18.75 ps delay
    * Look at 8 ps (no ADC noise).  Expect 7.050000e-05
      * got 7.311704e-05 with 15 ps delay
      * got 9.444676e-02 with 18.75 ps delay
* Conclusions so far -- emulators match pretty well in terms of response to ADC noise when there is no jitter, as long as the delay is 15 ps.  Unclear what is happening at 18.75ps delay.  The jitter response for the low-level case, though, is somewhat sporadic and delay-dependent.
* CPU experiments: investigate discrepancy in data amplitude: vref for TX/RX is 0.4 on emulator but 0.3 on CPU simulation.  Faster to check CPU first so I changed both to 0.4 on the CPU.  Experiments are 2M bits, 100ps tau, 15ps delay except as noted.
  * Look at 8.2 ps and 36 mV (expect around 1.012e-2)
    * got 2.856500e-03
    * got 2.928000e-03 with 18.75 ps delay
    * got 3.724000e-03 after fixing the issue with the sign decision
    * got 3.724000e-03 after repeating experiment with sign decision fix
    * got 3.775500e-03 after using the floor operation
  * Look at 6.6 ps and 28 mV (expect around 1.1325e-3)
    * got 3.220000e-04
    * got 3.280000e-04 with 18.75 ps delay
    * got 3.015000e-04 using rounding instead of floor
  * Look at 5.6 ps and 23 mV (expect around 1.1925e-4)
    * got 2.400000e-05
    * got 2.100000e-05 with 18.75 ps delay
    * got 1.950000e-05 using rounding instead of floor
  * Look at 47 mV (no jitter).  Expect 9.134500e-03
    * got 1.200000e-03
  * Look at 39 mV (no jitter).  Expect 1.791000e-03
    * got 9.600000e-05
  * Look at 10 ps (no ADC noise).  Expect 1.084500e-03
    * got 1.209000e-03
  * Look at 9 ps (no ADC noise).  Expect 3.330000e-04
    * got 3.720000e-04
  * Look at 8 ps (no ADC noise).  Expect 7.050000e-05
    * got 8.850000e-05
    * got 8.400000e-05 with 18.75 ps delay
    * got 7.500000e-05 with ADC rounding
* Rebuilt the high-level emulator after fixing the TX/RX range issue and improving seeding for RNGs and the parallel PRBS
  * FPGA observations.  Using tau=100e-12, delay=18.75e-12
    * Look at 8.2 ps and 36 mV.  Expect 1.476850e-02 (CPU @ 2M)
      * got 1.472966e-02
    * Look at 6.6 ps and 28 mV.  Expect 1.718000e-03 (CPU @ 2M)
      * got 1.688736e-03
    * Look at 5.6 ps and 23 mV.  Expect 1.755000e-04 (CPU @ 2M)
      * got 1.795417e-04
    * Look at 47 mV (no jitter).  Expect 1.738050e-02 (CPU @ 2M)
      * got 1.663161e-02
    * Look at 39 mV (no jitter).  Expect 3.580500e-03 (CPU @ 2M)
      * got 3.350426e-03
    * Look at 32 mV (no jitter).  Expect 3.350000e-04 (CPU @ 2M)
      * got 2.990770e-04
    * Look at 10 ps (no ADC noise).  Expect 1.174500e-03 (CPU @ 2M)
      * got 1.694186e-03
    * Look at 9 ps (no ADC noise).  Expect 3.690000e-04 (CPU @ 2M)
      * got 6.193283e-04
    * Look at 8 ps (no ADC noise).  Expect 8.550000e-05 (CPU @ 2M)
      * got 1.753008e-04
* Investigate https://ieeexplore-ieee-org.stanford.idm.oclc.org/document/5380287
* Investigate https://github.com/alexforencich/verilog-mersenne

/////////////////
August 29
* Rebuilt high-level architecture with MT19937 PRNG instead of LFSRs
* Building took 44m36.835s (about 4-5 min longer)
* No timing issues
* Resources
  * Slice LUTs: 99440 / 218600
    * analog_core: 43185
    * digital_core: 40158
  * Slice Registers: 28651 / 437200
    * analog_core: 6031
    * digital_core: 17796
  * Slice: 32566 / 54650
    * analog_core: 14182
    * digital_core: 15446
  * DSP: 850 / 900
  * BRAM: 258.5 / 545
* FPGA observations.  Using tau=100e-12, delay=18.75e-12
  * Look at 8.2 ps and 36 mV.  Expect 1.476850e-02 (CPU @ 2M)
    * got 2.909135e-03
  * Look at 6.6 ps and 28 mV.  Expect 1.718000e-03 (CPU @ 2M)
    * got 2.382552e-04
  * Look at 5.6 ps and 23 mV.  Expect 1.755000e-04 (CPU @ 2M)
    * got 1.629381e-05
  * Look at 47 mV (no jitter).  Expect 1.738050e-02 (CPU @ 2M)
    * got 1.049163e-03
    * VCS: got 2.104134e-02 (\* likely bad, includes settling)
    * VCS: got 1.679300e-02
  * Look at 39 mV (no jitter).  Expect 3.580500e-03 (CPU @ 2M)
    * got 1.906558e-04
    * VCS: got 3.738500e-03 (\* includes settling)
  * Look at 32 mV (no jitter).  Expect 3.350000e-04 (CPU @ 2M)
    * got 1.568562e-05
    * VCS: got 3.465000e-04 (\* includes settling)
    * VCS: got 3.780000e-04
  * Look at 10 ps (no ADC noise).  Expect 1.174500e-03 (CPU @ 2M)
    * got 5.480766e-03
    * VCS: got 4.468000e-03 (\* includes settling)
  * Look at 9 ps (no ADC noise).  Expect 3.690000e-04 (CPU @ 2M)
    * got 2.162146e-03
    * VCS: got 1.885000e-03 (\* includes settling)
  * Look at 8 ps (no ADC noise).  Expect 8.550000e-05 (CPU @ 2M)
    * got 6.259609e-04
    * VCS: got 5.935000e-04 (\* includes settling)
* Found a big issue -- it takes at least 5us for the loop to settle when there is a lot of noise.  We should wait at least 10us.
* Ran an experiment where I set the voltage noise to 32mVrms and set the channel output to zero.  Got 13.588 rms noise in the ADC codes from the FPGA and 13.55 mVrms from the CPU.  

August 30
* Re-ran FPGA build with a more old-fashioned way of setting random seeds, using wires instead of parameters, in case a synthesis bug was causing parameters to all be set to the same value.  In addition, the resolution of the step response function was increased about 3x.  Additional probe signals were added as well to investigate the ADC ordering.  For these experiments, the channel delay changed to 19.5694716243e-12 so as to line up with the new sampling interval.
* Look at 47 mV (no jitter).  Previous value from the FPGA was 1.049163e-03.
  * got 1.047985e-03 -- almost exactly the same.  Perhaps the channel dynamics accuracy is not to blame for the discrepancy?
* Look at 39 mV
  * got 1.905372e-04
* Look at 32 mV
  * got 1.564454e-05
* Observations -- setting a much smaller ETOL and TX driver time makes little difference.  We might want to use 0.1e-3 ETOL and TX driver 0.1ps for a very close match, but the difference is less than 5%.
* Using the exact same PRBS generator in CPU simulation makes no difference to the result
* Summing together a bunch of pseudo-random numbers (either from different seeds or the same seed) makes no difference as long as their standard deviation matches that of the original generator.
* Maybe there is a limitation of the fixed-point representation?

Sept 3
* Re-built high-level emulator with LCG random number generator instead of MT19937.  Took 45m51.206s.  Experiments are run with --chan_delay 19.5694716243e-12 --chan_tau 100e-12.  CPU comparisons are taken with 2M points @ 0.1 ps T_TR and 1e-4 ETOL.
* Vivado Report (note: many probe signals are included)
  * No timing issue
  * Slice LUTs: 97460 / 218600
    * analog_core: 37553
    * digital_core: 40125
  * Slice Registers: 29078 / 437200
    * analog_core: 1743
    * digital_core: 17798
  * Slice: 31290 / 54650
    * analog_core: 12642
    * digital_core: 15234
  * DSP: 850 / 900
  * BRAM: 229.5 / 545
* Results
  * Look at 8.2 ps and 36 mV.  Expect  (CPU @ 2M)
    * got 1.431280e-02
  * Look at 6.6 ps and 28 mV.  Expect  (CPU @ 2M)
    * got 1.547181e-03
  * Look at 5.6 ps and 23 mV.  Expect  (CPU @ 2M)
    * got 1.460300e-04
  * Look at 47 mV (no jitter).  Expect 1.648650e-02 (CPU @ 2M)
    * got 1.662033e-02
  * Look at 39 mV (no jitter).  Expect 3.297000e-03 (CPU @ 2M)
    * got 3.352081e-03
  * Look at 32 mV (no jitter).  Expect 3.215000e-04 (CPU @ 2M, may need more)
    * got 3.000045e-04
  * Look at 10 ps (no ADC noise).  Expect 1.225500e-03 (CPU @ 2M)
    * got 1.134025e-03
  * Look at 9 ps (no ADC noise).  Expect 3.840000e-04 (CPU @ 2M)
    * got 3.460385e-04
  * Look at 8 ps (no ADC noise).  Expect  7.800000e-05 (CPU @ 2M)
    * got 7.496870e-05
* Low-level tests (simulation-based)
  * Look at 47 mV (no jitter).  Expect 1.648650e-02 (CPU @ 2M), got 1.716e-2 @ 10k pts.
  * Look at 10 ps (no noise).  Expect 1.225500e-03 (CPU @ 2M), got 1.116071e-03 @ 10k pts.

* Re-built low-level emulator with LCG.
  * Took 37m44.638s
* Vivado Report
  * Timing: 
  * Slice LUTs: / 218600
    * analog_core: 
    * digital_core: 
  * Slice Registers: / 437200
    * analog_core: 
    * digital_core: 
  * Slice: / 54650
    * analog_core: 
    * digital_core: 
  * DSP: / 900
  * BRAM:  / 545

* Results
  * Look at 8.2 ps and 36 mV.  Expect (CPU @ 2M)
    * got 
  * Look at 6.6 ps and 28 mV.  Expect  (CPU @ 2M)
    * got 
  * Look at 5.6 ps and 23 mV.  Expect  (CPU @ 2M)
    * got 
  * Look at 47 mV (no jitter).  Expect 1.648650e-02 (CPU @ 2M)
    * got 2.025764e-01
  * Look at 39 mV (no jitter).  Expect 3.297000e-03 (CPU @ 2M)
    * got 2.898693e-03
  * Look at 32 mV (no jitter).  Expect 3.215000e-04 (CPU @ 2M, may need more)
    * got 2.473714e-04
  * Look at 10 ps (no ADC noise).  Expect 1.225500e-03 (CPU @ 2M)
    * got 1.839753e-01
  * Look at 9 ps (no ADC noise).  Expect 3.840000e-04 (CPU @ 2M)
    * got 1.803612e-01
  * Look at 8 ps (no ADC noise).  Expect  7.800000e-05 (CPU @ 2M)
    * got 8.228506e-05 or 1.824274e-01
* Looks like one of the models is getting stuck -- if the jitter is set to "10ps" then returned to "0ps", the errors remain.
* What may be happening is that the jitter causes one or more delays to exceed the period of the 250ps oscillator, at which point the whole model locks up.
* To fix this I added back a more flexible clock delay model developed a few months ago and set it up to handle up to 1.5 periods.
* Rebuild with that model (plus a few ILA probes) took 38m31.408s

* Results with new clock delay model
  * Look at 8.2 ps and 36 mV.  Expect 1.437900e-02 (CPU @ 2M)
    * got 1.475821e-02
  * Look at 6.6 ps and 28 mV.  Expect 1.672000e-03 (CPU @ 2M)
    * got 1.651813e-03
  * Look at 5.6 ps and 23 mV.  Expect 1.785000e-04 (CPU @ 2M)
    * got 1.637477e-04
  * Look at 47 mV (no jitter).  Expect 1.648650e-02 (CPU @ 2M)
    * got 1.657856e-02
  * Look at 39 mV (no jitter).  Expect 3.297000e-03 (CPU @ 2M)
    * got 3.339682e-03
  * Look at 32 mV (no jitter).  Expect 3.215000e-04 (CPU @ 2M, may need more)
    * got 2.978066e-04
  * Look at 10 ps (no ADC noise).  Expect 1.225500e-03 (CPU @ 2M)
    * got 1.220498e-03
  * Look at 9 ps (no ADC noise).  Expect 3.840000e-04 (CPU @ 2M, may need more)
    * got 3.865024e-04
  * Look at 8 ps (no ADC noise).  Expect  7.800000e-05 (CPU @ 2M, may need more)
    * got 8.510833e-05
