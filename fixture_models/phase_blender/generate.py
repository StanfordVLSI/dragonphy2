from dave.mgenero.mgenero import ModelCreator
config = 'circuit.cfg'
interface = 'interface.yaml'
template = 'phase_blender.template.sv'
params = 'params.yaml'
intermediate = 'template.intermediate.sv'
output = 'final.sv'

m = ModelCreator(config, interface)
m.generate_model(template, intermediate)
m.backannotate_model(intermediate, output, params)

