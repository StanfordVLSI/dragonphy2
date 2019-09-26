import subprocess
from pathlib import Path

def test_loopback():
    # testbench location
    tb = 'verif/tb/beh/tb.sv'

    # library locations
    libs = []
    libs.append('verif/loopback/beh/loopback.sv')
    libs.append('verif/tx/beh/tx.sv')
    libs.append('verif/chan/beh/chan.sv')
    libs.append('src/rx/beh/rx.sv')
    libs.append('src/rx_clk/beh/rx_clk.sv')
    libs.append('src/rx_cmp/beh/rx_cmp.sv')

    # resolve paths
    tb = Path(tb).resolve()
    libs = [Path(lib).resolve() for lib in libs]

    # construct the command
    args = []
    args += ['xrun']
    args += [f'{tb}']
    for lib in libs:
        args += ['-v', f'{lib}']

    # set up build dir     
    cwd = Path('tests/build_loopback')
    cwd.mkdir(exist_ok=True)

    # run the simulation
    result = subprocess.run(args, cwd=cwd)
    assert result.returncode == 0

if __name__ == '__main__':
    test_loopback()
