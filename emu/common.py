from dragonphy import *
import numpy as np

def adapt_fir(pack_dir = ".", config="system"):

    system_config = Configuration(config)
    ffe_config = system_config['generic']['ffe']

    # Number of iterations of Wiener Steepest Descent
    iterations  = 200000
    depth = 1000

    # Cursor position with the most energy 
    pos = 2
    resp_len = 125

    ideal_codes = np.random.randint(2, size=iterations)*2 - 1

    chan = Channel(channel_type='perfect', normal='area', sampl_rate=5, cursor_pos=pos, resp_depth=resp_len)
    chan_out = chan(ideal_codes)

    # Adapt to the channel
    adapt = Wiener(step_size = ffe_config["adaptation"]["args"]["mu"], num_taps = ffe_config['parameters']["length"], cursor_pos=pos)
    for i in range(iterations-pos):
        adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])    
    weights = adapt.weights

    # Quantize the weights
    qw = Quantizer(width=ffe_config["parameters"]["weight_precision"], signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)

    # Create Package Generator Object 
    generic_packager   = Packager(package_name='constant', parameter_dict=system_config['generic']['parameters'], path=pack_dir)
    ffe_packager       = Packager(package_name='ffe',      parameter_dict=ffe_config['parameters'], path=pack_dir)

    #Create package file from parameters specified in system.yaml under generic
    generic_packager.create_package()
    ffe_packager.create_package()

    # Write weights to package
    with open(pack_dir + '/' + 'weights_pack.sv', "w+") as f:
        f.write('package weights_pack;\n')
        f.write('logic signed [' + str(ffe_config["parameters"]["weight_precision"]) + '-1:0]  read_weights   [0:' + str(len(quantized_weights)) + '-1] = ')
        f.write('{' + ",".join([str(int(w)) for w in weights]) + '};\n')
        f.write('endpackage')

    # Return packages  
    packages  = [generic_packager.path, ffe_packager.path, pack_dir + '/weights_pack.sv']
    return packages

