from dragonphy import *

def test_emu_build():
    print('Attemping to build bitstream for emulator.')
    script = get_file('emu/build.tcl')
    vivado_batch(script=script, cwd=get_dir('emu'))

if __name__ == '__main__':
    test_emu_build()
