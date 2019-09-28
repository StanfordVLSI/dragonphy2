from dragonphy import run_sim

def test_fpga():
    srcs = [
        'src/signals/fpga/signals.sv',
        'stim/fpga_stim.sv'
    ] 

    libs = [
        'verif/BUFG/BUFG.sv',
        'verif/loopback/loopback.sv',
        'verif/tx/tx.sv',
        'verif/clk_gen/fpga/clk_gen.sv',
        'verif/prbs21/prbs21.sv',
        'verif/chan/chan.sv',
        'verif/gen_emu_clks/gen_emu_clks.sv',
        'verif/mmcm/beh/mmcm.sv',
        'verif/time_manager/time_manager.sv',
        'verif/vio/vio.sv',
        'src/rx_cmp/rx_cmp.sv',
        'src/rx/rx.sv',
        'verif/tb/tb.sv',
        'verif/fpga_top/fpga_top.sv'
    ]


    run_sim(srcs=srcs, libs=libs, cwd='tests/build_fpga',
            top='stim', inc_dirs=['src/signals/fpga'], 
            defs=['FPGA_VERIF'])

if __name__ == '__main__':
    test_fpga()
