from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
SIMULATOR = 'ncsim'

def test_sim():
    def qwrap(s):
        return f'"{s}"'
    defines = {
        'W_INP_TXT': qwrap(BUILD_DIR / 'w_inp.txt'),
        'W_OUT_TXT': qwrap(BUILD_DIR / 'w_out.txt'),
        'W_INC_TXT': qwrap(BUILD_DIR / 'w_inc.txt'),
        'W_PLS_TXT': qwrap(BUILD_DIR / 'w_pls.txt'),
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/cpu')],
        defines=defines,
        simulator=SIMULATOR,
        flags=['-unbuffered']
    ).run()

    iw     = read_into_dictionary(BUILD_DIR / 'w_inp.txt')
    ow     = read_into_dictionary(BUILD_DIR / 'w_out.txt')
    inc    = read_into_dictionary(BUILD_DIR / 'w_inc.txt')
    ow_pls = read_into_dictionary(BUILD_DIR / 'w_pls.txt')

    assert check_weights(iw, ow, inc, ow_pls) == 0 

def read_into_dictionary(filename):
    new_dict = {}
    with open(filename) as f:
        for line in f:
            x, y, value = line.strip().split(',')
            if not x in new_dict:
                new_dict[x] = {}
            new_dict[x][y] = int(value)
    return new_dict


def check_weights(iw, ow, inc, ow_pls):
    diff = 0

    for x in iw.keys():
        for y in iw[x].keys():
            diff += (iw[x][y] - ow[x][y])
            
            calc_ow_pls = (ow[x][y] + inc[x][y])
            if calc_ow_pls >= 128:
                calc_ow_pls = -128
            elif calc_ow_pls <= -129:
                calc_ow_plus = 127
            diff += (ow_pls[x][y] - calc_ow_pls)
    return diff 

if __name__ == "__main__":
    test_sim()
