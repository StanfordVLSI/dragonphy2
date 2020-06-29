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
* Simulation with 16x channels:
  * PRBS test took 42.509094 seconds.
  * Total_bits: 608192
  * Throughput: 14.3 kb/s
  * r7cad-generic processor, CentOS Linux release 7.7.1908 (Core), 128 GB RAM
    * /proc/cpuinfo did not display the real CPU information since r7cad-generic is a VM
