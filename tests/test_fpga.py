from dragonphy import run_sim

def test_fpga():
    srcs = [
        'src/signals/fpga/signals.sv',
        'stim/fpga_stim.sv'
    ] 

    libs = [
        'verif/BUFG/all/BUFG.sv',
        'verif/loopback/all/loopback.sv',
        'verif/tx/all/tx.sv',
        'verif/clk_gen/fpga/clk_gen.sv',
        'verif/prbs21/all/prbs21.sv',
        'verif/chan/all/chan.sv',
        'verif/gen_emu_clks/all/gen_emu_clks.sv',
        'verif/mmcm/beh/mmcm.sv',
        'verif/time_manager/all/time_manager.sv',
        'verif/vio/all/vio.sv',
        'src/rx_cmp/all/rx_cmp.sv',
        'src/rx/all/rx.sv',
        'verif/tb/all/tb.sv',
        'verif/fpga_top/all/fpga_top.sv'
    ]


    run_sim(srcs=srcs, libs=libs, cwd='tests/build_fpga',
            top='stim', inc_dirs=['src/signals/fpga'], 
            defs=['FPGA_VERIF'])

if __name__ == '__main__':
    test_fpga()
