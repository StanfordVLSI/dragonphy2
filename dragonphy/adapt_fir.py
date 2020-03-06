import numpy as np
from .config import Configuration
from .channel import Channel
from .adaptation import Wiener
from .quantizer import Quantizer
from .packager import Packager


def adapt_fir(pack_dir = ".", config="system"):

    system_config = Configuration(config)
    ffe_config = system_config['generic']['ffe']

    # Number of iterations of Wiener Steepest Descent
    iterations = 200000

    # Channel parameters
    chan_type = 'exponent'
    chan_tau = 0.5
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

    # Adapt to the channel
    adapt = Wiener(
        step_size = ffe_config["adaptation"]["args"]["mu"],
        num_taps = ffe_config['parameters']["length"],
        cursor_pos=pos
    )
    for i in range(iterations-pos):
        adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])    
    weights = adapt.weights

    # Uncomment this line for debugging purposes to
    # use weights corresponding to a perfect channel
    # weights = np.array([1.0, 0, 0])

    # Normalize weights
    weights = weights * (100.0 / np.sum(np.abs(weights)))

    # Quantize the weights
    qw = Quantizer(width=ffe_config["parameters"]["weight_precision"], signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)

    # Create Package Generator Object 
    generic_packager = Packager(
        package_name='constant',
        parameter_dict=system_config['generic']['parameters'],
        path=pack_dir
    )
    ffe_packager = Packager(
        package_name='ffe',
        parameter_dict=ffe_config['parameters'],
        path=pack_dir
    )

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
    localparam integer impulse_length = {impulse_length};
    localparam real impulse_values [{impulse_length}] = '{{{impulse_values}}};
endpackage\
''')

    # Write weights to package
    # TODO: why is "weights" used here instead of quantized_weights?
    weights_pack = pack_dir + '/' + 'weights_pack.sv'
    weight_width = ffe_config["parameters"]["weight_precision"]
    weight_count = len(quantized_weights)
    weight_values = ', '.join(f'{int(w)}' for w in weights)
    with open(weights_pack, "w+") as f:
        f.write(f'''\
package weights_pack;
    localparam signed [{weight_width-1}:0] read_weights [0:{weight_count-1}] = '{{{weight_values}}};
endpackage\
''')

    # Return packages  
    packages  = [generic_packager.path, ffe_packager.path, impulse_pack, weights_pack]
    return packages
