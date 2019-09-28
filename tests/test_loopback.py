from dragonphy import run_sim

def test_loopback():
    srcs = [
        'src/signals/beh/signals.sv',
        'stim/loopback_stim.sv'
    ]

    libs = [
        'verif/loopback/all/loopback.sv',
        'verif/tx/all/tx.sv',
        'verif/clk_gen/beh/clk_gen.sv',
        'verif/prbs21/all/prbs21.sv',
        'verif/chan/all/chan.sv',
        'verif/tb/all/tb.sv',
        'src/rx/all/rx.sv',
        'src/rx_cmp/all/rx_cmp.sv'
    ]

    run_sim(srcs=srcs, libs=libs, cwd='tests/build_loopback',
            top='stim', inc_dirs=['src/signals/beh/'])

if __name__ == '__main__':
    test_loopback()
