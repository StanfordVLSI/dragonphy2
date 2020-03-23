import numpy as np
from pathlib import Path

from .config import Configuration
from .channel import Channel
from .adaptation import Wiener
from .quantizer import Quantizer
from .packager import Packager

def adapt_fir(build_dir ='.', config='system'):
    # convert build_dir to a path if it is not already
    build_dir = Path(build_dir)

    # read in configuration information
    system_config = Configuration(config)
    ffe_config = system_config['generic']['ffe']

    # create channel model
    chan = Channel(
        channel_type='arctan',
        tau=0.25e-9,
        t_delay=2e-9,
        sampl_rate=10e9,
        resp_depth=500
    )

    # compute response of channel to codes
    iterations = 200000
    ideal_codes = np.random.randint(2, size=iterations)*2 - 1
    chan_out = chan.compute_output(ideal_codes)

    # Adapt to the channel
    cursor_pos = 3
    adapt = Wiener(
        step_size = ffe_config['adaptation']['args']['mu'],
        num_taps = ffe_config['parameters']['length'],
        cursor_pos=cursor_pos
    )
    for i in range(iterations-cursor_pos):
        adapt.find_weights_pulse(ideal_codes[i-cursor_pos], chan_out[i])
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
    step_dt = 0.1e-9
    _, v_step = chan.get_step_resp(f_sig=1/step_dt, resp_depth=500)
    Packager(
        package_name='step_resp_pack',
        parameters={
            'step_len': len(v_step),
            'step_dt': step_dt,
            'v_step': v_step
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

    # Write the step response data to a YAML file
    chan.to_file(build_dir / 'chan.npy')

    # Return a list of all packages created
    return list(build_dir.glob('*.sv'))