from pathlib import Path
import yaml

class AnasymodProjectConfig:
    def __init__(self, fpga_sim_ctrl='UART_ZYNQ'):
        self.config = {
            'PROJECT': {
                'dt': 50e-9,
                'board_name': 'ZC702',
                'plugins': ['msdsl'],
                'emu_clk_freq': 10e6,
                'cpu_debug_mode': 0,
                'cpu_debug_hierarchies': []
            },
            'FPGA_TARGET': {
                'fpga': {
                    'fpga_sim_ctrl': fpga_sim_ctrl
                }
            }
        }

    def set_cpu_debug_mode(self, value):
        self.config['PROJECT']['cpu_debug_mode'] = value

    def add_debug_probe(self, depth, path):
        self.config['PROJECT']['cpu_debug_hierarchies'].append([depth, path])

    def set_board_name(self, value):
        self.config['PROJECT']['board_name'] = value

    def set_dt(self, value):
        self.config['PROJECT']['dt'] = value

    def add_plugin(self, arg):
        self.config['PROJECT']['plugins'].append(arg)

    def set_emu_clk_freq(self, value):
        self.config['PROJECT']['emu_clk_freq'] = value

    def write_to_file(self, fname):
        with open(fname, 'w') as f:
            yaml.dump(self.config, f, sort_keys=False)

class AnasymodSourceConfig:
    def __init__(self):
        self.sources = {}

    def add_generic_sources(self, kind, file_list, fileset=None):
        if kind not in self.sources:
            self.sources[kind] = {}
        for file_ in file_list:
            # determine a unique name for this file
            key = Path(file_).stem
            suffix = Path(file_).suffix
            if (suffix is not None) and (len(suffix) > 1) and (suffix[0] == '.'):
                key = f'{key}_{suffix[1:]}'
            if fileset is not None:
                key = f'{key}_{fileset}'
            # create entry for this file
            if key in self.sources[kind]:
                raise Exception(f'Source "{key}" already defined.')
            else:
                self.sources[kind][key] = {}
            self.sources[kind][key]['files'] = str(file_)
            if fileset is not None:
                self.sources[kind][key]['fileset'] = fileset

    def add_edif_files(self, file_list, fileset=None):
        self.add_generic_sources('edif_files', file_list, fileset)

    def add_verilog_sources(self, file_list, fileset=None):
        self.add_generic_sources('verilog_sources', file_list, fileset)

    def add_verilog_headers(self, header_list, fileset=None):
        self.add_generic_sources('verilog_headers', header_list, fileset)

    def add_firmware_files(self, file_list, fileset=None):
        self.add_generic_sources('firmware_files', file_list, fileset)

    def add_defines(self, defines, fileset=None):
        if 'defines' not in self.sources:
            self.sources['defines'] = {}
        for mname, mval in defines.items():
            # determine a unique name for this definition
            key = mname
            if fileset is not None:
                key = f'{key}_{fileset}'
            # create entry for this definition
            if key in self.sources['defines']:
                raise Exception(f'Definition "{key}" already specified.')
            else:
                self.sources['defines'][key] = {}
            self.sources['defines'][key]['name'] = mname
            self.sources['defines'][key]['value'] = mval
            if fileset is not None:
                self.sources['defines'][key]['fileset'] = fileset

    def write_to_file(self, fname):
        with open(fname, 'w') as f:
            yaml.dump(self.sources, f, sort_keys=False)
