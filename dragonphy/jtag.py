import sys
import os
import subprocess
from pathlib import Path
from dragonphy.files import get_file, get_dir
from dragonphy.git_util import *
from justag import jtag_directory


class JTAG:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        id_code = self.calc_id_code()
        print(f'JTAG ID Code: 0x{id_code:08x}')

        justag_inputs = []
        justag_inputs += [str(id_code)]
        justag_inputs += list(get_dir('md').glob('*.md'))
        justag_inputs += [get_file('vlog/new_pack/const_pack.sv')]
        print(justag_inputs)

        # call JusTAG
        self.justag(*justag_inputs, cwd=build_dir)

        # generate JTAG for the chip source

        TOP_NAME='raw_jtag'
        JUSTAG_DIR = jtag_directory()

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

        # generate the JTAG test harness

        self.genesis('JTAGDriver', f'{VERF_DIR}/JTAGDriver.svp', cwd=build_dir)

        # move the package containing register numbers

        new_cpu_models = get_dir('build/new_cpu_models/jtag')
        new_cpu_models.mkdir(exist_ok=True, parents=True)
        (build_dir / 'jtag_reg_pack.sv').replace(new_cpu_models / 'jtag_reg_pack.sv')

        # move the test harness and place inside a package

        new_tb = get_dir('build/new_tb')
        new_tb.mkdir(exist_ok=True, parents=True)
        with open(build_dir / 'genesis_verif' / 'JTAGDriver.sv', 'r') as orig:
            with open(new_tb / 'jtag_drv_pack.sv', 'w') as new:
                new.write('package jtag_drv_pack;\n')
                new.write(orig.read())
                new.write('endpackage\n')

        # move the generated source code for the JTAG implementation

        new_chip_src = get_dir('build/new_chip_src/jtag')
        new_chip_src.mkdir(exist_ok=True, parents=True)
        for file in (build_dir / 'genesis_verif').glob('*.sv'):
            file.replace(new_chip_src / file.name)

        # specify the generated files
        self.generated_files = []
        self.generated_files += [get_file('build/new_tb/jtag_drv_pack.sv')]
        self.generated_files += [get_file('build/new_cpu_models/jtag/jtag_reg_pack.sv')]
        self.generated_files += list(get_dir('build/new_chip_src/jtag').glob('*.sv'))

    @staticmethod
    def justag(*inputs, cwd=None):
        args = []
        args += [f'justag']
        args += list(inputs)
        subprocess.call(args, cwd=cwd)

    @staticmethod
    def genesis(top, *inputs, cwd=None):
        args = []
        args += ['Genesis2.pl']
        args += ['-parse']
        args += ['-generate']
        args += ['-top', top]
        args += ['-input'] + list(inputs)
        subprocess.call(args, cwd=cwd)

    @staticmethod
    def required_values():
        return []

    @staticmethod
    def calc_id_code():
        # get short git hash as an int
        git_hash_short = get_git_hash_short()

        # find out if the git repo is clean/dirty
        git_is_clean = get_git_is_clean()
        print(git_is_clean)
        raise Exception()

        # build up ID code
        id_code = 0

        # add 7-character git hash
        id_code |= git_hash_short << 4

        # add bit to indicate clean/dirty status
        if git_is_clean:
            id_code |= 1 << 1

        # lowest bit is always "1"
        id_code |= 1

        # return the ID code
        return id_code
