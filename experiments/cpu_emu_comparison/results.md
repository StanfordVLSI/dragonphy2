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
* All failing endpoints for WNS are from clk\_pl\_0 to emu\_clk, which shouldn't even be considered as a source\_clk.
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
