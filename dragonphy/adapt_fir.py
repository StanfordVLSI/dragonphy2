from pathlib import Path

from dragonphy import Channel, Packager

class AdaptFir:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        ffe_config      = system_values['generic']['ffe']
        constant_config = system_values['generic']
        mlsd_config     = system_values['generic']['mlsd']
        comp_config     = system_values['generic']['comp']

        # create channel model
        kwargs = dict(
            channel_type='exponent',
            tau=25e-12,
            t_delay=31.25e-12,
            sampl_rate=160e9,
            resp_depth=500
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

        # Write the step response data to a YAML file
        chan.to_file(build_dir / 'chan.npy')
        print(build_dir / 'chan.npy')

        self.generated_files = list(build_dir.glob('*.*'))

    @staticmethod
    def required_values():
        return ['iterations', 'mu', 'length', 'weight_precision']
