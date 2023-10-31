from pathlib import Path

from dragonphy import Channel, Packager

class AdaptFir:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        ffe_config          = system_values['generic']['ffe']
        constant_config     = system_values['generic']
        comp_config         = system_values['generic']['comp']
        chan_config         = system_values['generic']['channel']
        error_config        = system_values['generic']['error']
        detector_config     = system_values['generic']['detector']


        # create channel model
        chan_resp_depth = 2048
        chan_samp_step = 1e-9/(chan_resp_depth-1)
        kwargs = dict(
            channel_type='exponent',
            tau=100e-12,
            t_delay=10*chan_samp_step,
            sampl_rate=1/chan_samp_step,
            resp_depth=chan_resp_depth
        )
        chan = Channel(**kwargs)

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

        # Create Comp package
        Packager(
            package_name='cmp_gpack',
            parameters=comp_config['parameters'],
            dir=build_dir
        ).create_package()

        # Create Channel package
        Packager(
            package_name='channel_gpack',
            parameters=chan_config['parameters'],
            dir=build_dir
        ).create_package()


        # Create Error package
        Packager(
            package_name='error_gpack',
            parameters=error_config['parameters'],
            dir=build_dir
        ).create_package()

        # Create Detector package
        Packager(
            package_name='detector_gpack',
            parameters=detector_config['parameters'],
            dir=build_dir
        ).create_package()

        # Write the step response data to a YAML file
        chan.to_file(build_dir / 'chan.npy')
        print(build_dir / 'chan.npy')

        self.generated_files = list(build_dir.glob('*.*'))

    @staticmethod
    def required_values():
        return ['iterations', 'mu', 'length', 'weight_precision']
