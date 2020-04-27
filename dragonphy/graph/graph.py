from dragonphy import Directory

import yaml, os
import kratos
import matplotlib.pyplot as plt
import matplotlib.image  as mpimg
import importlib.util

from pathlib import Path

class Node:
    def __init__(self, sources, sinks):
        self._edges = {}

        self._edges['sources'] = sources
        self._edges['sinks']  = sinks

    def __getitem__(self, key):
        return self._edges[key]

    def __setitem__(self, key, value):
        self._edges[key] = value

    @property
    def sources(self):
        return self._edges['sources']

    @property
    def sinks(self):
        return self._edges['sinks']



class DependencyNode(Node, Directory):
    def __init__(self, name, src_path=None, snk_path=None, rank=0, view=None, sources=None, sinks=None):
        sinks = set() if sinks is None else sinks
        sources = set() if sources is None else sources
        view    = 'all' if view is None else view

        super().__init__(sources, sinks)
        self.rank = rank
        self.name = name
        self.view = view
        self.src_path = src_path
        self.snk_path = snk_path

    def __lt__(self, other):
        return self.rank < other

    def __le__(self, other):
        return self.rank <= other

    def __gt__(self, other):
        return self.rank > other

    def __ge__(self, other):
        return self.rank >= other

    def __eq__(self, other):
        return self.rank == other

    def __ne__(self, other):
        return self.rank != other

    def build(self, src_nodes, view):
        pass

class DependencyGraph:
    def __init__(self):
        self.graph = {}
        self.rank_order = [set()]

    def __add__(self, node):
        node.rank = 0
        for inp_node_name in node['sources']:
            if self.graph[inp_node_name] >= node:
                node.rank = self.graph[inp_node_name].rank + 1
            self.graph[inp_node_name]['sinks'] = self.graph[inp_node_name]['sinks'] | {node.name}

        self.graph[node.name] = node

        if node >= len(self.rank_order):
            self.rank_order += [{node.name}]
        else:
            self.rank_order[node.rank] = self.rank_order[node.rank] | {node.name}
        return self

    def __iadd__(self, node):
        return self.__add__(node)

    def __getitem__(self, node_name):
        return self.graph[node_name]

    def __setitem__(self, node_name, node):
        self.graph[node_name] = node

    def __iter__(self):
        for node_name_list in self.rank_order:
            yield node_name_list


class BuildStatus(Directory):
    def __init__(self, status_file):
        self.status_file = Path(self.path() + f'/build/' + status_file + '.yml').resolve()
        self.state_dict = {'inputs' : None, 'outputs' : None}

    def load(self):
        try:
            with open(Path(self.status_file).resolve(), 'r') as f:
                self.state_dict = yaml.load(f, Loader = yaml.FullLoader)
        except FileNotFoundError:
            #print(f'ERROR: {self.status_file} does not exist')
            raise FileNotFoundError

    def save(self):
        if self.state_dict:
             with open(Path(self.status_file).resolve(), 'w') as f:
                yaml.dump(self.state_dict, f)
        else:
            print(f'ERROR: {status_file}.yml cannot be saved with no tracked files')

    def check_graph_state(self, graph):
        def check_node( src_path, src_name, src_view='all', node_type='inputs'):
            time_stamp = Path(src_path).stat().st_mtime

            if not src_name in self.state_dict[node_type]:
                return True, { 'time_stamp' : time_stamp, 'loc' : src_path, 'view' : src_view }

            else:
                old_time_stamp = self.state_dict[node_type][src_name]['time_stamp']
                old_view       = self.state_dict[node_type][src_name]['view']
                return ((old_time_stamp - time_stamp) != 0.0) | (old_view != src_view), { 'time_stamp' : time_stamp, 'loc' : src_path, 'view' : src_view}

        self.state_dict['inputs'] = {} if self.state_dict['inputs'] is None else self.state_dict['inputs']
        self.state_dict['outputs'] = {} if self.state_dict['outputs'] is None else self.state_dict['outputs']

        update_set = set()

        if len(list(graph)) == 1:
            print('Improperly Formed Graph: Only 1 Layer')
            exit()

        input_node_names = list(graph)[0]
        inter_graph = list(graph)[1:]

        #missing input files
        mifs = set()

        #Validate Input File Existence, Check Time Stamps
        for input_node_name in input_node_names:
            src_path = graph[input_node_name].src_path
            src_view = graph[input_node_name].view
            src_name = input_node_name
            file_exists = Path(src_path).is_file()
            if file_exists:
                node_changed, node_state = check_node(src_path, src_name, src_view=src_view, node_type='inputs')
                if node_changed:
                    self.state_dict['inputs'][src_name] = node_state
                    update_set = update_set | {src_name}
            else:
                mifs = mifs | {src_name}

        if len(mifs):
            print(f'Missing Input Files: {mifs}') 
            exit()

        #Check for Intermediate/Output File Existence -- I think in the future, I will add a .done file to the top (like timestamps) that 
        #contains what was built during the build process.
        for node_layer in inter_graph:
            for node_name in node_layer:
                src_path = graph[node_name].src_path
                src_view = graph[node_name].view
                #src_file_exists = Path(src_path).is_file() if not src_path is None else False

                files_built = False
                view_match  = False

                if not node_name in self.state_dict['outputs']:
                    update_set = update_set | {node_name}
                else:
                    built_items = self.state_dict['outputs'][node_name]['loc']
                    old_view    = self.state_dict['outputs'][node_name]['view']
                    if not built_items is None:
                        files_built = all([Path(item).is_file() for item in built_items])
                    view_match = (src_view == old_view)

                if not (files_built and view_match):
                    update_set = update_set | {node_name}

        return update_set

    def update_graph_state(self, new_outputs=None):
        for src_name in self.state_dict['inputs']:
            src_path = self.state_dict['inputs'][src_name]['loc']
            actual_ts  = Path(src_path).stat().st_mtime
            self.state_dict['inputs'][src_name]['time_stamp'] = actual_ts

        if not new_outputs is None:
            for src_name in new_outputs:
                src_paths, view = new_outputs[src_name]
                if src_paths is None:
                    continue
                time_stamps = [Path(src_path).stat().st_mtime for src_path in src_paths]
                src_paths = [str(src_path) for src_path in src_paths]
                self.state_dict['outputs'][src_name] = {'loc' : src_paths, 'time_stamp' : time_stamps, 'view' : view}


class InputNode(DependencyNode):
    def __init__(self, source_file, ext=None, view=None, folders=None):
        ext = "" if ext is None else ext
        folders = ['src'] if folders is None else folders

        file_ = "/".join([self.path(), *folders, source_file])
        file_ = ".".join([file_, ext]) if not ext == "" else file_

        super().__init__(source_file, src_path=file_, snk_path=file_, view=view)


    def output(self):
        return self.source_file

class ConfigNode(InputNode):
    def __init__(self, source_file, folders=None, view=None):
        folders = ['config'] if folders is None else folders
        super().__init__(source_file, ext='yml', view=view, folders=folders)

        try:
            with open(Path(self.src_path).resolve(), 'r') as f:
                self.config_dict = yaml.load(f, Loader = yaml.FullLoader)
        except FileNotFoundError:
            print(f'ERROR: {self.src_path} does not exist')
            exit()

    def output(self):
        return self.config_dict

class ConcatNode(DependencyNode):
    def __init__(self, name, sources, ext=None, view=None, folders=None):
        ext = "" if ext is None else ext
        folders = [] if folders is None else folders

        super().__init__(name, sources=sources, view=view)

        #Make Directory if it doesnt exist
        directory_path = "/".join([self.path(), 'build', self.view, *folders])
        Path(directory_path).mkdir(parents=True, exist_ok=True)

        file_ = directory_path + "/" + name
        file_ = ".".join([file_, ext]) if not ext == "" else file_

        self.src_path = None
        self.snk_path = file_

    def build(self, src_nodes, view):
        input_paths = [src_node.snk_path for src_node in src_nodes]
        os.system(f'cat {" ".join(input_paths)} > {self.snk_path}')
        return self.snk_path

    def output(self):
        pass #Location Of Merged Verilog File?

class KratosNode(DependencyNode):
    def __init__(self, name, source_file, generator_name, view=None, configs=None, folders=None):
        configs = set() if configs is None else configs
        folders = [] if folders is None else folders
        super().__init__(name, sources=configs, view=view)

        #Make Directory if it doesnt exist
        directory_path = "/".join([self.path(), 'build', self.view, name])
        Path(directory_path).mkdir(parents=True, exist_ok=True)

        self.src_path = "/".join([self.path(), *folders, source_file]) + '.py'
        self.snk_path = directory_path + '/' + f'{self.name}.sv'
        self.gen_name = generator_name

    def build(self, src_nodes, view):        

        gen_spec = importlib.util.spec_from_file_location(self.gen_name, self.src_path)
        gen_mod  = importlib.util.module_from_spec(gen_spec)
        gen_spec.loader.exec_module(gen_mod)
        vlog_gen = getattr(gen_mod, self.gen_name)

        if len(src_nodes) > 1:
            config = {}
            for src_node in src_nodes:
                config[src_node.name] = src_node.config_dict
        else:
            config = src_nodes[0].config_dict

        kratos.verilog(vlog_gen(**config), filename=self.snk_path)
        return self.snk_path

    def output(self):
        pass #Location of Verilog File?

class PythonNode(DependencyNode):
    def __init__(self, name, source_file, generator_name, view=None, sources=None, configs=None, folders=None):
        configs = set() if configs is None else configs
        sources = set() if sources is None else sources
        folders = [] if folders is None else folders
        super().__init__(name, sources= configs | sources, view=view)

        #Make Directory if it doesnt exist
        directory_path = "/".join([self.path(), 'build', self.view, name])
        Path(directory_path).mkdir(parents=True, exist_ok=True)

        self.src_path = "/".join([self.path(), *folders, source_file]) + '.py'
        self.snk_path = directory_path + '/' + f'{self.name}.sv'
        self.gen_name = generator_name
        self.configs  = configs

    def build(self, src_nodes, view):

        gen_spec = importlib.util.spec_from_file_location(self.gen_name, self.src_path)
        gen_mod  = importlib.util.module_from_spec(gen_spec)
        gen_spec.loader.exec_module(gen_mod)
        vlog_gen = getattr(gen_mod, self.gen_name)

        # I know this is an awkward way of doing this :( but the output of adapt_fir isn't in a config file format and is not received...
        config = {}
        if len(self.configs) > 1:
            for src_node in src_nodes:
                if src_node.name in self.configs:
                    config[src_node.name] = src_node.config_dict

        else:
            for src_node in src_nodes:
                if src_node.name in self.configs:
                    config = src_node.config_dict
        
        config['view'] = view

        return vlog_gen(**config, filename=self.snk_path).generated_files


    def output(self):
        pass #


class BuildGraph(Directory):
    def __init__(self, view):
        self.depend_graph = DependencyGraph()
        self.build_status = BuildStatus('timestamps')

    def insert_node(self, node):
        self.depend_graph += node

    def insert_nodes(self, nodes):
        for node in nodes:
            self.depend_graph += node

    def add_input(self, name, ext=None, folders=None):
        self.depend_graph += InputNode(name, ext=ext, folders=folders)

    def add_kratos(self, build_name, script, generator_name, folders=None, view=None, configs=None):
        self.depend_graph += KratosNode(build_name, script, generator_name, folders=folders, view=view, configs=configs)

    def add_python(self, build_name, script, generator_name, folders=None, sources=None, view=None, configs=None):
        self.depend_graph += PythonNode(build_name, script, generator_name, folders=folders, view=view, sources=sources, configs=configs)

    def add_config(self, name, folders=None):
        self.depend_graph += ConfigNode(name, folders)

    def merge_results(self, name, sources, ext=None, folders=None):
        self.depend_graph += ConcatNode(name, sources, ext=ext, folders=folders)

    def build(self, view=None):

        #Check If Build Directory Exists
        cwd = Path(self.path() + '/build').resolve()
        if not cwd.is_dir():
            cwd.mkdir(exist_ok=True)
            cwd = cwd / view
            cwd.mkdir(exist_ok=True)

        build_status = self.build_status

        track_list = set()
        try:
            build_status.load()
            print(f'BUILD STATE DETECTED')

        except FileNotFoundError:
            print(f'NO BUILD STATE DETECTED')

        target_node_list = build_status.check_graph_state(self.depend_graph)
        
        if not len(target_node_list):
            print(f'NOTHING TO BUILD')
            return

        new_outputs = {}

        for node_name_list in self.depend_graph:
            for node_name in node_name_list & target_node_list:
                node = self.depend_graph[node_name]
                src_nodes = [self.depend_graph[src_name] for src_name in node.sources]
                print(f'BUILDING: {node_name}')
                new_outputs[node_name] = (node.build(src_nodes, node.view), node.view)
                built_list, view = new_outputs[node_name]
                if not built_list is None:
                    for item in built_list:
                        print(f'BUILT: {item}')
                target_node_list = target_node_list | node['sinks']

        build_status.update_graph_state(new_outputs=new_outputs)
        build_status.save()


    def visualize(self, view):
        import pygraphviz as pgv
        graph_render = pgv.AGraph(directed=True)

        for node_name_list in self.depend_graph:
            for node_name in node_name_list:
                graph_render.add_node(node_name)
                for source_node in self.depend_graph[node_name]['sources']:
                    graph_render.add_edge(source_node, node_name)

        graph_render.layout('dot')
        graph_render.draw(f'{view}.svg')


def test_build_graph_properties():
    build_graph = BuildGraph('View 1')

    build_graph.add_input('a', ext='v', folders=['src', 'a'])
    build_graph.add_input('c', ext='v', folders=['src', 'b'])
    build_graph.add_config('test')
    build_graph.merge_results('d', {'a','c'}, folders=['h'])
    build_graph.merge_results('e', {'a','d'}, folders=['g'])
    build_graph.add_kratos('passthru', 'async_reg', 'PassThrough', folders=['c'], configs={'test'})

    build_graph.build()
    build_graph.visualize()


if __name__ == "__main__":
    test_build_graph_properties()
