from os.path import dirname
from os import chdir, getcwd
from butterphy import make, abspath, read_ti_adc, CmdLineParser

Nti = 18
Nadc = 8

def test_sim(nosim=False):
    # save current directory and change to this one

    cwd = getcwd()
    chdir(dirname(abspath(__file__)))

    # run the simulation
    if not nosim:
        make('profile')

    # run the tests

    check_sram()

    # change back to the original directory

    chdir(cwd)

def check_sram():
    # read results

    in_ = read_ti_adc('sram_in.txt')
    out = read_ti_adc('sram_out.txt')

    # make sure that input is at least as long as output

    assert len(in_) >= len(out), 'Recorded SRAM input should be at least as long as SRAM output.'

    for k, (sram_in, sram_out) in enumerate(zip(in_[:len(out)], out)):
        assert sram_in == sram_out, f'Data mismatch on line {k//Nti}: {sram_in} != {sram_out}.'

if __name__ == '__main__':
    cmd = CmdLineParser()
    cmd.call_with_args(test_sim)
