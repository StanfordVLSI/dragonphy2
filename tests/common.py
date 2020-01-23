from dragonphy import *
import numpy as np

def adapt_fir(pack_dir = ".", config="system"):

    system_config = Configuration(config)
    ffe_config = system_config['generic']['ffe']

    # Number of iterations of Wiener Steepest Descent
    iterations  = 200000
    depth = 1000

    # Channel parameters
    chan_type = 'exponent'
    chan_tau = 2.0
    chan_sampl_rate = 5
    chan_resp_depth = 50
    pos = 2

    ideal_codes = np.random.randint(2, size=iterations)*2 - 1

    chan = Channel(channel_type=chan_type,
                   normal='area',
                   tau=chan_tau,
                   sampl_rate=chan_sampl_rate,
                   resp_depth=chan_resp_depth,
                   cursor_pos=pos)
    chan_out = chan(ideal_codes) / chan_sampl_rate
    # print(chan.impulse_response)

    # Adapt to the channel
    adapt = Wiener(step_size = ffe_config["adaptation"]["args"]["mu"], num_taps = ffe_config['parameters']["length"], cursor_pos=pos)
    for i in range(iterations-pos):
        adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])    
    weights = adapt.weights

    # Uncomment this line for debugging purposes to
    # use weights corresponding to a perfect channel
    # weights = np.array([1.0, 0, 0])

    # Normalize weights
    weights = weights * (100.0 / np.sum(np.abs(weights)))
    # print(weights)

    # Quantize the weights
    qw = Quantizer(width=ffe_config["parameters"]["weight_precision"], signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)

    # Create Package Generator Object 
    generic_packager   = Packager(package_name='constant', parameter_dict=system_config['generic']['parameters'], path=pack_dir)
    ffe_packager       = Packager(package_name='ffe',      parameter_dict=ffe_config['parameters'], path=pack_dir)

    #Create package file from parameters specified in system.yaml under generic
    generic_packager.create_package()
    ffe_packager.create_package()

    # Write impulse response to package
    impulse_length = len(chan.impulse_response)
    impulse_values = ', '.join(f'{elem / chan_sampl_rate}'
                               for elem in chan.impulse_response)
    impulse_pack = pack_dir + '/' + 'impulse_pack.sv' 
    with open(impulse_pack, "w+") as f:
        f.write(f'''\
package impulse_pack;
    parameter integer impulse_length = {impulse_length};
    parameter real impulse_values [{impulse_length}] = '{{{impulse_values}}};
endpackage\
''')

    # Write weights to package
    weights_pack = pack_dir + '/' + 'weights_pack.sv'
    with open(weights_pack, "w+") as f:
        f.write('package weights_pack;\n')
        f.write('logic signed [' + str(ffe_config["parameters"]["weight_precision"]) + '-1:0]  read_weights   [0:' + str(len(quantized_weights)) + '-1] = ')
        f.write('{' + ",".join([str(int(w)) for w in weights]) + '};\n')
        f.write('endpackage')

    # Return packages  
    packages  = [generic_packager.path, ffe_packager.path, impulse_pack, weights_pack]
    return packages

