package const_pack;

    // parameters related to circuit configuration
    localparam integer Nti = 16;
    localparam integer Nadc = 8;        // ADC bits
    localparam integer Nti_rep = 2;     // # of Replicas
    localparam integer Nout = 4;        // number of PI output clock phases
    localparam integer Nv2t = 5;        // number of V2T current control
    localparam integer Nrange = 4;      // params used in adc unfolding ops
    localparam integer Nbrc = 4;        // number of branches per each PI clock
    localparam integer N_mem_addr = 10; // number of bits in SRAM address
    localparam integer Nbias = 4;
    localparam integer Npi = 9;         // PI control bits / UI
    localparam integer Nblender = 4;    // number of phaes blender control bits in a PI
    localparam integer Nunit_pi = 32;   // number of delay units in each delay chain of a PI
    localparam integer Nmax = 3;
    localparam integer Ndepth = 20;
    localparam integer Ndiv = 4;        // samples are accumulated for 2**Ndiv cycles
    localparam integer Ncdr_avg = 128;
    localparam integer Nprbs = 7;       // length of LFSR used in PRBS checker

endpackage
