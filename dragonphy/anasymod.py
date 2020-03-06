from pathlib import Path
import yaml

class AnasymodProjectConfig:
    def __init__(self):
        self.config = {
            'PROJECT': {
                'dt': 50e-9,
                'board_name': 'ZC702',
                'plugins': ['msdsl'],
                'emu_clk_freq': 20e6
            }
        }

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

    def add_verilog_sources(self, file_list, fileset=None):
        if 'verilog_sources' not in self.sources:
            self.sources['verilog_sources'] = {}
        for file_ in file_list:
            key = Path(file_).stem
            if key in self.sources['verilog_sources']:
                raise Exception(f'Source "{key}" already defined.')
            else:
                self.sources['verilog_sources'][key] = {}
            self.sources['verilog_sources'][key]['files'] = str(file_)
            if fileset is not None:
                self.sources['verilog_sources'][key]['fileset'] = fileset

    def add_verilog_headers(self, header_list, fileset=None):
        if 'verilog_headers' not in self.sources:
            self.sources['verilog_headers'] = {}
        for file_ in header_list:
            key = Path(file_).stem
            if key in self.sources['verilog_headers']:
                raise Exception(f'Header "{key}" already defined.')
            else:
                self.sources['verilog_headers'][key] = {}
            self.sources['verilog_headers'][key]['files'] = str(file_)
            if fileset is not None:
                self.sources['verilog_headers'][key]['fileset'] = fileset

    def add_defines(self, defines, fileset=None):
        if 'defines' not in self.sources:
            self.sources['defines'] = {}
        for k, v in defines.items():
            self.sources['defines'][k]['name'] = k
            self.sources['defines'][k]['value'] = v
            if fileset is not None:
                self.sources['defines'][k]['fileset'] = fileset

    def write_to_file(self, fname):
        with open(fname, 'w') as f:
            yaml.dump(self.sources, f, sort_keys=False)
