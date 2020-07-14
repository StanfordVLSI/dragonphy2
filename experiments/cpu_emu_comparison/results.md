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

