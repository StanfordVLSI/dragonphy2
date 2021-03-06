# general imports
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim():
    def qwrap(s):
        return f'"{s}"'
    defines = {
        'SRAM_IN_TXT': qwrap(BUILD_DIR / 'sram_in.txt'),
        'SRAM_OUT_TXT': qwrap(BUILD_DIR / 'sram_out.txt')
    }

    # determine the config
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    # run the test
    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines
    ).run()

    # check the results
    check_sram()

def check_sram(Nti=18):
    # read results
    in_ = read_int_array(BUILD_DIR / 'sram_in.txt')
    out = read_int_array(BUILD_DIR / 'sram_out.txt')

    # make sure that input is at least as long as output
    assert len(in_) >= len(out), 'Recorded SRAM input should be at least as long as SRAM output.'
    print(len(in_))
    print(len(out))
    for k, (sram_in, sram_out) in enumerate(zip(in_[:len(out)], out)):
        assert sram_in == sram_out, f'Data mismatch on line {k//Nti}: {sram_in} != {sram_out}.'

def read_int_array(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()

    retval = []
    for line in lines:
        tokens = [elem.strip() for elem in line.split(',')]
        tokens = [int(token) for token in tokens]
        retval += tokens

    return retval

if __name__ == "__main__":
    test_sim()
