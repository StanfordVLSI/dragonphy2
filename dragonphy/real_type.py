import os

from svreal import RealType, DEF_HARD_FLOAT_WIDTH

from msdsl import MixedSignalModel
from msdsl.function import PlaceholderFunction

def get_dragonphy_real_type():
    t = os.environ.get('DRAGONPHY_REAL_TYPE', 'FIXED_POINT')
    if t == 'FIXED_POINT':
        return RealType.FixedPoint
    elif t == 'HARD_FLOAT':
        return RealType.HardFloat
    elif t == 'FLOAT_REAL':
        return RealType.FloatReal
    else:
        raise Exception('Unsupported DRAGONPHY_REAL_TYPE')

def add_placeholder_inputs(m: MixedSignalModel, f: PlaceholderFunction,
                           prefix: str=''):
    # determine the real-number type
    real_type = get_dragonphy_real_type()

    # data inputs (one for each order of the piecewise-polynomial spline)
    wdata = []
    for k in range(f.order + 1):
        # determine the formatting for the data input
        kwargs = {'name': f'{prefix}wdata{k}'}
        if real_type in {RealType.FixedPoint, RealType.FloatReal}:
            kwargs['signed'] = True
            kwargs['width'] = f.coeff_widths[k]
        elif real_type == RealType.HardFloat:
            kwargs['width'] = DEF_HARD_FLOAT_WIDTH
        else:
            raise Exception('Unsupported RealType.')

        # add the data
        wdata += [m.add_digital_input(**kwargs)]

    # address input
    waddr = m.add_digital_input(f'{prefix}waddr', width=f.addr_bits)

    # write enable input
    we = m.add_digital_input(f'{prefix}we')

    return wdata, waddr, we