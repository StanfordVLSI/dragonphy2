import numpy as np
from pathlib import Path

from dragonphy import Channel, Wiener, Quantizer, Packager

class AdaptFir:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        ffe_config      = system_values['generic']['ffe']
        constant_config = system_values['generic']
        mlsd_config     = system_values['generic']['mlsd']
        comp_config      = system_values['generic']['comp']
        # create channel model
        kwargs = dict(
            channel_type='arctan',
            tau=0.25e-9,
            t_delay=4e-9,
            sampl_rate=10e9,
            resp_depth=500
        )
        chan = Channel(**kwargs)

        # create a channel model delayed such that the optimal
        # cursor position is an integer
        # TODO: clean this up
        kwargs_d = kwargs.copy()
        kwargs_d['t_delay'] += 0.5e-9
        chan_d = Channel(**kwargs_d)

        # compute response of channel to codes
        iterations = 200000
        ideal_codes = np.random.randint(2, size=iterations) * 2 - 1
        chan_out = chan_d.compute_output(ideal_codes)

        # Adapt to the channel
        cursor_pos = 5
        adapt = Wiener(
            step_size=ffe_config['adaptation']['args']['mu'],
            num_taps=ffe_config['parameters']['length'],
            cursor_pos=cursor_pos
        )
        for i in range(iterations - cursor_pos):
            adapt.find_weights_pulse(ideal_codes[i - cursor_pos], chan_out[i])
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
            parameters=constant_config['parameters'],
            dir=build_dir
        ).create_package()

        # Create ffe package
        Packager(
            package_name='ffe_gpack',
            parameters=ffe_config['parameters'],
            dir=build_dir
        ).create_package()

        # Create MLSD package
        Packager(
            package_name='mlsd_gpack',
            parameters=mlsd_config['parameters'],
            dir=build_dir
        ).create_package()

        # Create Comp package
        Packager(
            package_name='cmp_gpack',
            parameters=comp_config['parameters'],
            dir=build_dir
        ).create_package()

        # Write impulse response to package
        step_dt = 0.1e-9
        _, v_step = chan.get_step_resp(f_sig=1 / step_dt, resp_depth=500)
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
        print(build_dir / 'chan.npy')

        self.generated_files = list(build_dir.glob('*.*'))

    @staticmethod
    def required_values():
        return ['iterations', 'mu', 'length', 'weight_precision']
