import numpy as np
import yaml
from pathlib import Path

from .config import Configuration
from .channel import Channel
from .adaptation import Wiener
from .quantizer import Quantizer
from .packager import Packager

def adapt_fir(build_dir ='.', config='system'):
    # convert build_dir to a path if it is not already
    build_dir = Path(build_dir)

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

    chan = Channel(
        channel_type=chan_type,
        normal='area',
        tau=chan_tau,
        sampl_rate=chan_sampl_rate,
        resp_depth=chan_resp_depth,
        cursor_pos=pos
    )
    chan_out = chan(ideal_codes) / chan_sampl_rate

    # Adapt to the channel
    adapt = Wiener(
        step_size = ffe_config['adaptation']['args']['mu'],
        num_taps = ffe_config['parameters']['length'],
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
    # TODO: why isn't "quantized_weights" used?
    qw = Quantizer(width=ffe_config['parameters']['weight_precision'], signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)

    # create constants package
    Packager(
        package_name='constant_gpack',
        parameters=system_config['generic']['parameters'],
        dir=build_dir
    ).create_package()

    # Create ffe package
    Packager(
        package_name='ffe_gpack',
        parameters=ffe_config['parameters'],
        dir=build_dir
    ).create_package()

    # Write impulse response to package
    Packager(
        package_name='impulse_pack',
        parameters={
            'impulse_length': len(chan.impulse_response),
            'impulse_values': chan.impulse_response / chan_sampl_rate
        },
        dir=build_dir
    ).create_package()

    # Write weights to package
    # TODO: why is "weights" used here instead of "quantized_weights"?
    Packager(
        package_name='weights_pack',
        parameters={
            'read_weights': [int(elem) for elem in weights]
        },
        dir=build_dir
    ).create_package()

    # Write the impulse response to a YAML file
    with open(build_dir / 'impulse.yml', 'w') as f:
        yaml.dump({'impulse': [float(elem / chan_sampl_rate) for elem in chan.impulse_response]}, f)

    # Return a list of all packages created
    return list(build_dir.glob('*.sv'))