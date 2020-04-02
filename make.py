from argparse import ArgumentParser

from dragonphy import BuildGraph, Directory

#commetn

def create_fpga_graph():
    graph = BuildGraph('fpga')

    #Default Input Parameters
    graph.add_config('chan', folders=['config', 'fpga'])
    graph.add_config('osc_model', folders=['config', 'fpga'])
    graph.add_config('rx_adc', folders=['config', 'fpga'])
    graph.add_config('tx', folders=['config', 'fpga'])
    graph.add_config('test_loopback_config', folders=['config'])

    #Add msdsl scripts to build list
    graph.add_python('adapt_fir',       'adapt_fir',        'AdaptFir',    view='all',  folders=['dragonphy'],                configs={'test_loopback_config'})
    graph.add_python('chan_core',       'chan_core',        'ChannelCore', view='fpga_models',  folders=['dragonphy', 'fpga_models'], sources={'adapt_fir'}, configs={'chan'})
    graph.add_python('osc_model_core',  'osc_model_core',   'OscModelCore', view='fpga_models',  folders=['dragonphy', 'fpga_models'], configs={'osc_model'})
    graph.add_python('rx_adc_core',     'rx_adc_core',      'RXAdcCore', view='fpga_models',   folders=['dragonphy', 'fpga_models'], configs={'rx_adc'})
    graph.add_python('tx_core',         'tx_core',          'TXCore',    view='fpga_models',   folders=['dragonphy', 'fpga_models'], configs={'tx'})

    return graph


def main():
    parser = ArgumentParser()

    parser.add_argument('-v', '--view', type=str, default=None)
    parser.add_argument('--visualize', type=str, default=None)
    
    cmd_inputs = parser.parse_args()

    if cmd_inputs.view == "fpga":
        graph = create_fpga_graph()
    elif cmd_inputs.view == "asic":
        graph = create_asic_graph()
    elif cmd_inputs.view == "cpu":
        graph = create_cpu_graph()
    else:
        print('Unknown View, View set to CPU')
        graph = create_cpu_graph()

    if cmd_inputs.visualize:
        graph.visualize(cmd_inputs.visualize)

    graph.build()


if __name__ == "__main__":
    main()
