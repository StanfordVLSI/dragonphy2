from dragonphy import run_sim

def test_loopback():
    srcs = [
        'src/signals/beh/signals.sv',
        'stim/loopback_stim.sv'
    ]

    libs = [
        'verif/loopback/loopback.sv',
        'verif/tx/tx.sv',
        'verif/clk_gen/beh/clk_gen.sv',
        'verif/prbs21/prbs21.sv',
        'verif/chan/chan.sv',
        'verif/tb/tb.sv',
        'src/rx/rx.sv',
        'src/rx_cmp/rx_cmp.sv'
    ]

    run_sim(srcs=srcs, libs=libs, cwd='tests/build_loopback',
            top='stim', inc_dirs=['src/signals/beh/'])

if __name__ == '__main__':
    test_loopback()
