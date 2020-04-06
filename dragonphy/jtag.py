import sys
import os
from subprocess import call
from pathlib import Path
from dragonphy.files import get_file, get_dir

class JTAG:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        justag_input = []
        justag_input += list(get_dir('md/reg').glob('*.md'))
        justag_input += [get_file('vlog/old_pack/all/const_pack.sv')]

        # call JusTAG
        JUSTAG_DIR = os.environ['JUSTAG_DIR']
        call([sys.executable, f'{JUSTAG_DIR}/JusTAG.py'] + justag_input, cwd=build_dir)

        TOP_NAME='raw_jtag'
        PRIM_DIR=f'{JUSTAG_DIR}/rtl/primitives'
        DIGT_DIR=f'{JUSTAG_DIR}/rtl/digital'
        VERF_DIR=f'{JUSTAG_DIR}/verif'

        SVP_FILES = [
            f'{DIGT_DIR}/{TOP_NAME}.svp',
            f'{PRIM_DIR}/cfg_ifc.svp',
            f'{DIGT_DIR}/{TOP_NAME}_ifc.svp',
            f'{PRIM_DIR}/flop.svp',
            f'{DIGT_DIR}/tap.svp',
            f'{DIGT_DIR}/cfg_and_dbg.svp',
            f'{PRIM_DIR}/reg_file.svp'
        ]

        self.genesis(TOP_NAME, *SVP_FILES, cwd=build_dir)
        self.genesis('JTAGDriver', f'{VERF_DIR}/JTAGDriver.svp', cwd=build_dir)

        old_cpu_models = get_dir('build/old_cpu_models/jtag')
        old_cpu_models.mkdir(exist_ok=True, parents=True)
        (build_dir / 'jtag_reg_pack.sv').replace(old_cpu_models / 'jtag_reg_pack.sv')

        old_tb = get_dir('build/old_tb')
        old_tb.mkdir(exist_ok=True, parents=True)
        with open(build_dir / 'genesis_verif' / 'JTAGDriver.sv', 'r') as orig:
            with open(old_tb / 'jtag_drv_pack.sv', 'w') as new:
                new.write('package jtag_drv_pack;\n')
                new.write(orig.read())
                new.write('endpackage\n')

        old_chip_src = get_dir('build/old_chip_src/jtag')
        old_chip_src.mkdir(exist_ok=True, parents=True)
        for file in (build_dir / 'genesis_verif').glob('*.sv'):
            file.replace(old_chip_src / file.name)

        # specify the generated files
        self.generated_files = []
        self.generated_files += [get_file('build/old_tb/jtag_drv_pack.sv')]
        self.generated_files += [get_file('build/old_cpu_models/jtag/jtag_reg_pack.sv')]
        self.generated_files += list(get_dir('build/old_chip_src/jtag').glob('*.sv'))

    def genesis(self, top, *inputs, cwd=None):
        args = []
        args += ['-parse']
        args += ['-generate']
        args += ['-top', top]
        args += ['-input'] + list(inputs)
        call(['Genesis2.pl'] + args, cwd=cwd)

    @staticmethod
    def required_values():
        return []
