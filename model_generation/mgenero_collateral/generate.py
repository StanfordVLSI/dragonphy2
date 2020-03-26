from dave.mgenero.mgenero import ModelCreator
from dave.mgenero import mgenero

input_params = '../comparator/comparator_params.yaml'
output_folder = '../../src/rx_cmp/beh/'

configuration_file = 'circuit.cfg'
#configuration_file = '/home/dstanley/research/DaVE/mGenero/examples/ctle/lab1/circuit.cfg'
interface_template = 'interface_template.cfg'
#template = 'template.sv'
#intermediate_template = 'template.intermediate.sv'
intermediate_template = 'template.sv'
#params = '../comparator_params.yaml'
output = output_folder + 'comparator_model.sv'

m = ModelCreator(configuration_file, interface_template)
#m.generate_model(template, intermediate_template)
m.backannotate_model(intermediate_template, output, input_params)

