from dragonphy import *

def test_fpga():
    srcs = []
    srcs += get_views(signals='fpga')
    srcs += get_files('stim/fpga_stim.sv')

    libs = get_views(
        BUFG='all',
        loopback='all',
        tx='all',
        clk_gen='fpga',
        prbs21='all',
        chan='all',
        gen_emu_clks='all',
        mmcm='beh',
        time_manager='all',
        vio='all',
        rx_cmp='all',
        rx='all',
        tb='all',
        fpga_top='all'
    )

    run_sim(srcs=srcs, libs=libs, cwd=get_dir('tests/build_fpga'),
            top='stim', inc_dirs=get_dirs('src/signals/fpga'),
            defs=['FPGA_VERIF'])

if __name__ == '__main__':
    test_fpga()
