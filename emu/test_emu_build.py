from pathlib import Path
from dragonphy import vivado_batch

def test_emu_build():
    print('Attemping to build bitstream for emulator.')
    this_dir = Path(__file__).parent
    script = Path(this_dir, 'build.tcl')
    vivado_batch(script=script, cwd=this_dir)

if __name__ == '__main__':
    test_emu_build()
