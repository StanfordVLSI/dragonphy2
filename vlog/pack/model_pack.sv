package model_pack;
    // error tolerance for filters in sample and hold circuit
    // set to be at least 10x more precise than the ADC resolution
    localparam real ETOL_SNH = 0.0003;

    ////////////////////
    // Some general class
    ////////////////////


    class Delay; // Inverter delay
        integer seed;    // seed initialized randomly
        real td;         // delay

        function new(input real td_nom, input real td_std);
            seed = $urandom();
            this.td = td_nom + td_std*$dist_normal(seed, 0, 1000)/1000.0;
        endfunction

        function real get_rj(input real rj_rms);
            return rj_rms*$dist_normal(seed, 0, 1000)/1000.0;
        endfunction
    endclass: Delay

    ////////////////////
    // design parameters
    ////////////////////

    parameter real VSupl = 0.8;

    class SnHParameter; // S&H circuit params
        // static parameters
        //const real FP1 = 6.8e9*0.7 ;    // 1st pole in Hz
        //const real FP2 = 31.840e9 ;     // 2nd pole in Hz
        const real FP1 = 50e9 ;    // 1st pole in Hz
        const real FP2 = 55e9 ;     // 2nd pole in Hz
        const real TD  = 5e-12;         // input delay (must be non-negative)

        // constraints on random params
        real skew;
        const real skew_min = (TD < 5e-12) ? -TD : -5e-12;
        const real skew_max = (TD < 5e-12) ? +TD : +5e-12;

        integer seed;

        function new();
            seed = $urandom();
            skew = skew_min + (($dist_uniform(seed, 0, 1000)/1000.0) *
                               (skew_max - skew_min));
        endfunction
    endclass: SnHParameter

    class TDCParameter;    // TDC circuit params
        integer seed;
        Delay invd_obj;

        // static parameters

        const real td_ff_ck_q = 40e-12;    // clk to q delay of a f/f in TDC delay chain
        const real td_inv_nom = 15e-12;    // nominal delay of an inverter in TDC delay chain
        const real td_inv_std = 0.1e-12;   // nominal delay of an inverter in TDC delay chain
        const real rj_rms = 0.1e-12 ;      // rms of random jitter

        // variables

        real td_inv;                       // nominal delay of an inverter

        function new();
            this.invd_obj = new(td_inv_nom, td_inv_std);
            this.td_inv = invd_obj.td;
        endfunction

        function real get_rj();
            return this.invd_obj.get_rj(rj_rms);
        endfunction
    endclass : TDCParameter

    class PFDParameter; // PFD parameters including an arbiter in it
        // static parameters
        const real td_rst=100e-12;  // reset path delay of a PFD
        const real arb_off_nom = 0e-12;
        const real arb_off_std= 0.0;
        const real arb_del_nom = 20e-12;
        const real arb_del_std = 0.0;
        const real arb_jit_rms = 0.0;

        integer seed;
        real off;
        real del;

        function new();
            seed = $urandom();
            this.off = arb_off_nom + arb_off_std*$dist_normal(seed, 0, 1000)/1000.0;
            this.del = arb_del_nom + arb_del_std*$dist_normal(seed, 0, 1000)/1000.0;
        endfunction

        function real get_arb_jitter();
            return this.arb_jit_rms*$dist_normal(seed,0,1000)/1.0/1000;
        endfunction
    endclass: PFDParameter

    class V2TParameter; // V2T parameters
        // static parameters (Clock gen)
        const real Td_e = 10e-12;   // time difference between main clock and early clock
        const real Td_l = 20e-12;   // time difference between main clock and late clock
        const real Td_ff = 50e-12;  // F/F ck-q delay
        const real Td_buf = 50e-12; // buffer delay
        const real Tpw_clk_prstb = 50e-12;  // pulse width of F/F present signal
        const real Td_comp = 200e-12;   // time delay of the comparator + post buffer in V2T

        // static parameters (S&H + Ramp Gen)
        const real Gm_nom = 100e-6;     // nominal value of ramp current source TR transconductance
        const real Gm_std = 0e-6;       // standard deviation of Gm
        const real Vt_nom = 0.1;        // nominal value of threshold voltage of a ramp source source TR
        const real Vt_std = 0.0;     // standard deviation of Vt
        const real Vlth_nom = 0.38;     // nominal logic threshold of an inverter
        const real Vlth_std = 0.0;    // standard deviation of Vlth
        const real Cs = 100e-15;        // sampling capacitance
        const real Vgain = 0.75;        // voltage gain of sampling ops due to parasitic cap.
        const real Vcm_AC_max = 0.05;   // input common mode voltage variation

        // V2T pulse output jitter
        const real Td_std = 0.0;        // std deviation of V2T pulse output jitter

        // static parameters (bisagen)
        const real Iunit = 13.0e-6;       // target ramp current of a unit cell

        // Td_V2T_offset
        real Td_V2T_offset;
        const real Td_V2T_offset_min = -10e-12;
        const real Td_V2T_offset_max = +10e-12;

        integer seed;
        real Gm;
        real Vt;
        real Vlth;

        function new();
            seed = $urandom();
            this.Gm = Gm_nom + Gm_std*$dist_normal(seed, 0, 1000)/1000.0;
            this.Vt = Vt_nom + Vt_std*$dist_normal(seed, 0, 1000)/1000.0;
            this.Vlth = Vlth_nom + Vlth_std*$dist_normal(seed, 0, 1000)/1000.0;
            this.Td_V2T_offset = Td_V2T_offset_min +
                                 (($dist_uniform(seed, 0, 1000)/1000.0) *
                                  (Td_V2T_offset_max - Td_V2T_offset_min));
        endfunction

        function real get_current(input real Vg); // get current for given gate voltage
            get_current = this.Gm*(Vg-this.Vt);
            if (get_current < 0.0) begin
                get_current = 0.0;
            end
        endfunction

        function real get_voltage(input real Id); // get gate voltage for given current
            if (Id < 0.0) return 0/0;  // Invalid Id input
            else return this.Vt + Id/this.Gm;
        endfunction

        function real get_V2T_jitter;
            return Td_std*$dist_normal(seed, 0, 1000)/1000.0;
        endfunction
    endclass: V2TParameter

    class PIParameter; // PI circuit params
        integer seed;
        Delay chain_unit_obj;
        Delay mixer1b_obj;
        Delay mixermb_obj;

        // static parameters

        // PI delay chain
        const real td_chain_unit_nom = 15e-12;     // nominal delay of a unit delay cell
        const real td_chain_unit_std = 0.3e-12;    // std dev delay of a unit delay cell
        const real rj_chain_unit_rms = 0e-12;      // rms jitter of a unit delay cell
        const real td_chain_unit_gain = 1.5;       // td gain if del_inc is high

        // 1bit blender
        const real td_mixer1b_nom = 15e-12;     // nominal delay of an 1-bit mixer
        const real td_mixer1b_std = 0.3e-12;    // std dev delay of an 1-bit mixer
        const real rj_mixer1b_rms = 0e-12;      // rms jitter of an 1-bit mixer

        // multi-bit blender
        const real td_mixermb_nom = 100e-12;    // nominal delay of an multi-bit mixer
        const real td_mixermb_std = 0e-12;      // std dev delay of an multi-bit mixer
        const real rj_mixermb_rms = 0e-12;      // rms jitter of an multi-bit mixer

        // variables
        real td_chain_unit;    // unit delay of a delay chain
        real td_mixer1b;       // unit delay of a delay chain
        real td_mixermb;       // unit delay of a delay chain

        function new();
            this.chain_unit_obj = new(td_chain_unit_nom, td_chain_unit_std);
            this.mixer1b_obj = new(td_mixer1b_nom, td_mixer1b_std);
            this.mixermb_obj = new(td_mixermb_nom, td_mixermb_std);
            this.td_chain_unit = chain_unit_obj.td;
            this.td_mixer1b = mixer1b_obj.td;
            this.td_mixermb = mixermb_obj.td;
        endfunction

        function real get_rj_chain_unit();
            return this.chain_unit_obj.get_rj(rj_chain_unit_rms);
        endfunction

        function real get_rj_mixer1b();
            return this.mixer1b_obj.get_rj(rj_mixer1b_rms);
        endfunction

        function real get_rj_mixermb();
            return this.mixermb_obj.get_rj(rj_mixermb_rms);
        endfunction
    endclass: PIParameter
endpackage