from pathlib import Path

import os
import msdsl, svreal
from svinst import get_defs

from .files import get_dir, get_mlingua_dir

def remove_dup(seq):
    # fast method to remove duplicates from a list while preserving order
    # source: Raymond Hettinger (https://twitter.com/raymondh/status/944125570534621185)
    return list(dict.fromkeys(seq))

def find_preferred_impl(cell_name, view_order, override):
    # if there is a specific view desired for this cell, use it instead of the view order
    if cell_name in override:
        if isinstance(override[cell_name], Path):
            return override[cell_name]
        else:
            view_order = [override[cell_name]]

    # walk through the view names in order, checking to see if there are any matches in each
    for view_name in view_order:
        matches = []
        if view_name == 'dw_tap':
            if 'DW_TAP' in os.environ:
                folder = Path(os.environ['DW_TAP']).parent
                matches += list(folder.rglob(f'{cell_name}.*v'))
        elif view_name == 'mlingua':
            for dir_name in ['meas', 'misc', 'prim', 'stim']:
                view_folder = Path(os.environ['mLINGUA_DIR']) / 'samples' / dir_name
                matches += list(view_folder.rglob(f'{cell_name}.*v'))
        else:
            for dir_name in ['vlog', 'build']:
                view_folder = get_dir(dir_name) / view_name
                matches += list(view_folder.rglob(f'{cell_name}.*v'))
        if len(matches) == 0:
            continue
        elif len(matches) == 1:
            return matches[0]
        else:
            print(f'Found multiple matches for cell_name={cell_name}:')
            for match in matches:
                print(f'{match}')
            raise Exception('Build failed due to ambiguity.')

    # fail if we get to this point because no matches were found
    print(f'Found no matches for cell_name={cell_name}:')
    print(f'using view_order={view_order}')
    print(f'using override={override}')
    raise Exception('Build failed due to a missing cell definition.')

def find_def(cell_name, impl_file, includes, defines):
    defs = get_defs(impl_file, includes=includes, defines=defines)
    matches = [def_ for def_ in defs if def_.name == cell_name]
    if len(matches) == 0:
        print(f'Found no matches for cell_name={cell_name}:')
        print(f'using impl_file={impl_file}')
        print(f'using includes={includes}')
        print(f'using defines={defines}')
        raise Exception('Build failed due to a missing module definition.')
    elif len(matches) > 1:
        print(f'Found multiple matches for cell_name={cell_name}:')
        print(f'using impl_file={impl_file}')
        print(f'using includes={includes}')
        print(f'using defines={defines}')
        raise Exception('Build failed due to an unexpected module redefinition.')
    else:
        return matches[0]

def get_deps(cell_name=None, view_order=None, override=None,
             skip=None, includes=None, defines=None, impl_file=None,
             no_descend=None, visited=None):
    # set defaults
    if view_order is None:
        view_order = []
    if override is None:
        override = {}
    if skip is None:
        skip = set()
    if cell_name is None:
        if impl_file is not None:
            cell_name = Path(impl_file).stem
        else:
            raise Exception('Must provide either cell_name or impl_file.')
    if no_descend is None:
        no_descend = set()
    if visited is None:
        visited = set()

    # skip if we have already visited this cell
    if cell_name in visited:
        return []

    # otherwise add the cell to the list of visited cells
    print(f'Visiting cell_name={cell_name}')
    visited.add(cell_name)

    # find the most preferred implementation of this cell given
    # (unless the user has already provided an implementation file)
    if impl_file is None:
        impl_file = find_preferred_impl(
            cell_name=cell_name,
            view_order=view_order,
            override=override
        )

    # if we should not descend into this block, just return a list with
    # the implementation file for this block
    if cell_name in no_descend:
        return [impl_file]

    # otherwise, find out what cells are instantiated by
    # this module and descend into them
    def_ = find_def(
        cell_name=cell_name, impl_file=impl_file, includes=includes, defines=defines
    )

    # get a list of unique modules instantiated, preserving order
    submods = [inst.name for inst in def_.insts]
    submods = remove_dup(submods)
    print(f'Found the following dependencies: {submods}')

    # recurse into dependencies
    deps = []
    for submod in submods:
        if submod in skip:
            continue
        deps += get_deps(cell_name=submod, view_order=view_order, override=override,
                         skip=skip, includes=includes, defines=defines,
                         no_descend=no_descend, visited=visited)

    # add the current file to the end of the list
    deps += [impl_file]

    # remove duplicates preserving order
    deps = remove_dup(deps)

    return deps

def get_deps_asic(cell_name=None, impl_file=None, process='tsmc16'):
    # Set of views to skip (since a *.db will be provided)
    skip = {
        'analog_core',
        'phase_interpolator',  # used in TX
        'input_divider',  # used in TX
        'termination',  # used in TX
        'input_buffer',
        'output_buffer',
        'mdll_r1_top',
        'DW_tap'
    }

    # Process-dependent stubs
    override = {}
    if process == 'freepdk-45nm':
        # Large SRAM
        override['sram'] = 'chip_src_freepdk45'
        skip.add('sram_144_1024_freepdk45')
        
        # Small SRAM
        override['sram_small'] = 'chip_src_freepdk45'
        skip.add('sram_64_256_freepdk45')
        
        # TX tristate buffer
        override['tx_tri_buf'] = 'chip_src_freepdk45'
        skip.add('TBUF_X4')

        # qr_mux_fixed is just synthesizable RTL,
        # so there is no "skip" for a cell coming
        # from *.lib
        override['qr_mux_fixed'] = 'chip_src_freepdk45'
        
        # TX inverter
        override['tx_inv'] = 'chip_src_freepdk45'
        skip.add('INV_X4')
    elif process == 'tsmc16':
        # Large SRAM
        override['sram'] = 'chip_src_tsmc16'
        skip.add('TS1N16FFCLLSBLVTC1024X144M4SW')
        
        # Small SRAM
        override['sram_small'] = 'chip_src_tsmc16'
        skip.add('TS1N16FFCLLSBLVTC256X64M4SW')
        
        # TX tristate buffer
        override['tx_tri_buf'] = 'chip_src_tsmc16'
        skip.add('BUFTD4BWP16P90')
        
        # 4-input mux
        override['qr_mux_fixed'] = 'chip_src_tsmc16'
        skip.add('MUX4ND4BWP16P90ULVT')
        
        # TX inverter
        override['tx_inv'] = 'chip_src_tsmc16'
        skip.add('INVD4BWP16P90ULVT')

        override['mdll_inv'] = 'chip_src_tsmc16'
        skip.add('BUFFD2BWP16P90ULVT')
    else:
        raise Exception(f'Unknown process: {process}')

    # Build up the dependency list
    deps = []
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['pack', 'chip_src'],
        includes=[
            get_dir('inc/asic')
        ],
        override=override,
        skip=skip
    )

    # Return the dependencies
    return deps

def get_deps_cpu_sim(cell_name=None, impl_file=None, override=None):
    # set defaults
    if override is None:
        override = {}

    deps = []
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['dw_tap', 'mlingua', 'pack', 'tb', 'cpu_models', 'chip_src'],
        includes=[
            get_dir('inc/cpu'),
            get_mlingua_dir() / 'samples'
        ],
        defines={
            'DAVE_TIMEUNIT': '1fs',
            'NCVLOG': None,
            'SIMULATION': None  # for MDLL simulation
        },
        override=override
    )

    return deps

def get_deps_fpga_emu(cell_name=None, impl_file=None, override=None):
    # set defaults
    if override is None:
        override = {}

    deps = []
    deps += get_deps(
        cell_name=cell_name,
        impl_file=impl_file,
        view_order=['fpga_models', 'pack', 'chip_src'],
        includes=[
            get_dir('inc/fpga'),
            svreal.get_svreal_header().parent,
            msdsl.get_msdsl_header().parent
        ],
        defines={'DT_WIDTH': 25, 'DT_EXPONENT': -46, 'VIVADO': None},
        skip={'svreal', 'assign_real', 'comp_real', 'add_sub_real', 'ite_real',
              'dff_real', 'mul_real', 'mem_digital', 'sync_rom_real', 'DW_tap'},
        no_descend={'chan_core', 'tx_core', 'osc_model_core', 'clk_delay_core',
                    'rx_adc_core', 'analog_slice'},
        override=override
    )

    return deps
