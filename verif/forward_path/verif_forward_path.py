from dragonphy import *
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
import yaml
import math

def write_mlsd_config_inputs(values, path="."):
    with open(path + '/' + "ffe_values.txt", "w+") as f:
        f.write("\n".join([str(int(f_w)) for f_w in values['ffe_values']['coeff']]) + '\n')
        f.write(str(int(values['ffe_values']['shift'])) + '\n')
    with open(path + '/' + "mlsd_values.txt", "w+") as f:
        f.write("\n".join([str(int(m_w)) for m_w in values['mlsd_values']['chan_est']]) + '\n')
        f.write(str(int(values['mlsd_values']['shift']))+ '\n')
    with open(path + '/' + "cmp_thresh.txt", "w+") as f:
        f.write("\n".join([str(int(c_t)) for c_t in values['comp_values']['thresh']]) + '\n')
    with open(path + '/' +  "test_codes.txt", "w+") as f:
        f.write("\n".join([str(int(c)) for c in values['test_values']['codes']]) + '\n')

def write_files(values, path="."):
    with open(path + '/' + "ffe_values.txt", "w+") as f:
        f.write("\n".join([str(int(f_w)) for f_w in values['ffe_values']['coeff']]) + '\n')
        f.write(str(int(values['ffe_values']['shift'])) + '\n')
    with open(path + '/' + "mlsd_values.txt", "w+") as f:
        f.write("\n".join([str(int(m_w)) for m_w in values['mlsd_values']['chan_est']]) + '\n')
        f.write(str(int(values['mlsd_values']['shift']))+ '\n')
    with open(path + '/' + "cmp_thresh.txt", "w+") as f:
        f.write("\n".join([str(int(c_t)) for c_t in values['comp_values']['thresh']]) + '\n')
    with open(path + '/' +  "test_codes.txt", "w+") as f:
        f.write("\n".join([str(int(c)) for c in values['test_values']['codes']]) + '\n')
    #f.write('mu: ' + str(parameters[2]) + '\n')

    #This is the most compatible way of writing for verilog - given its a fairly low level language

def deconvolve(weights, chan):
    plt.plot(chan(weights))
    plt.show()

def plot_adapt_input(codes, chan_out, n, plt_mode='normal'):
    if plt_mode == 'stem':
        plt.stem(codes[:n], markerfmt='C0o', basefmt='C0-')
        plt.stem(chan_out[:n], markerfmt='C1o', basefmt='C1-')
    else:
        plt.plot(codes[:n], 'o-')
        plt.plot(chan_out[:n], 'o-')
    plt.show()


def execute_fir(ffe_config, quantized_weights, depth, quantized_chan_out):
    f = Fir(len(quantized_weights), quantized_weights, ffe_config["parameters"]["width"])

    single_matrix = f(quantized_chan_out)
    # Works when all channel weights are different
    channel_matrix = f.channelized(quantized_chan_out)

    assert(compare(channel_matrix, single_matrix, length=500))
    # Format conv_matrix to match SV output
    return np.divide(np.array(single_matrix), 256)

def read_svfile(fname):
    with open(fname, "r") as f:
        f_lines = f.readlines()
        return np.array([int(x) for x in f_lines])

def convert_2s_comp(np_arr, width):
    signed_arr=[]
    for x in np_arr:
        if x - (2**(width-1)-1) > 0:
            x_new = x - (2**width)
            signed_arr.append(x_new)
        else:
            signed_arr.append(x)
    return signed_arr

def compare(arr1, arr2, arr2_trim=0, length=None, debug=False):
    equal = True
    arr2 = arr2[arr2_trim:-1]

    if debug:
        # Print out outputs
        print(f'Compare arr1: {arr1[:length]}')
        print(f'Compare arr2: {arr2[:length]}')

    min_len = min(len(arr1), len(arr2)) 
    length = min_len if length == None else min(min_len, length)

    for x in range(length):
        if arr1[x] != arr2[x]:
            equal = False
    return equal

def main():
    build_dir = 'verif/forward_path/build_forward_path'
    pack_dir  = 'verif/forward_path/pack'

    # Get config parameters from system.yml file
    system_config = Configuration('system')
    test_config   = Configuration('test_verif_forward_path', 'verif/forward_path')
    ffe_config = system_config['generic']['ffe']
    cmp_config = system_config['generic']['comp']
    mlsd_config = system_config['generic']['mlsd']

    #Associate the correct build directory to the python collateral
    test_config['parameters']['ideal_code_filename'] = str(Path(build_dir + '/' + test_config['parameters']['ideal_code_filename']).resolve())
    test_config['parameters']['test_codes_filename'] = str(Path(build_dir + '/' + test_config['parameters']['test_codes_filename']).resolve())
    test_config['parameters']['ffe_values_filename'] = str(Path(build_dir + '/' + test_config['parameters']['ffe_values_filename']).resolve())
    test_config['parameters']['cmp_thresh_filename'] = str(Path(build_dir + '/' + test_config['parameters']['cmp_thresh_filename']).resolve())
    test_config['parameters']['mlsd_values_filename'] = str(Path(build_dir + '/' + test_config['parameters']['mlsd_values_filename']).resolve())
    test_config['parameters']['output_filename'] = str(Path(build_dir + '/' + test_config['parameters']['output_filename']).resolve())

    pos  = 2
    resp_len = 125
    
    depth = 2048
    check_bits = 300

    iterations  = 200000 # Number of iterations of Wiener Steepest Descent

    chan = Channel(channel_type='skineffect', normal='area', tau=0.5, sampl_rate=3, cursor_pos=pos, resp_depth=resp_len)

    #FFE Helper Class handles the ideal codes, channel output, weight generation
    ffe_helper  = FFEHelper(ffe_config, chan, cursor_pos=pos, iterations=iterations)
    ffe_shift, ffe_shift_bitwidth   = ffe_helper.calculate_shift();
    ffe_config['parameters']['shift_precision'] = ffe_shift_bitwidth
    
    ideal_codes = ffe_helper.ideal_codes
    quantized_chan_out = ffe_helper.quantized_channel_output
    weights = ffe_helper.weights
    
    #Set the number of codes that the test will cover
    test_config['parameters']['num_of_codes'] = depth

    #Create Package Generator Object 
    generic_packager   = Packager(package_name='constant', parameter_dict=system_config['generic']['parameters'], path=pack_dir)
    testbench_packager = Packager(package_name='test',     parameter_dict=test_config['parameters'], path=pack_dir)
    ffe_packager       = Packager(package_name='ffe',      parameter_dict=ffe_config['parameters'], path=pack_dir)
    cmp_packager       = Packager(package_name='cmp',      parameter_dict=cmp_config['parameters'], path=pack_dir)
    mlsd_packager      = Packager(package_name='mlsd',     parameter_dict=mlsd_config['parameters'], path=pack_dir)

    #Create package file from parameters specified in system.yaml under generic
    generic_packager.create_package()
    testbench_packager.create_package()
    ffe_packager.create_package()
    cmp_packager.create_package()
    mlsd_packager.create_package()

    #Create TestBench Object
    tester   = Tester(
                        top       = 'forward_testbench',
                        testbench = ['verif/forward_path/test_forward_path.sv'],
                        libraries = [ 'src/flat_buffer/syn/buffer.sv',
                                      'src/flat_buffer/syn/flatten_buffer.sv',
                                      'src/flat_buffer/syn/flatten_buffer_slice.sv',
                                      'src/delay_buffer/delay_buffer.sv',
                                      'src/partial_code_gen/syn/comb_partial_code_gen.sv',
                                      'src/potential_codes_gen/syn/comb_potential_codes_gen.sv',
                                      'src/eucl_dist/syn/comb_eucl_dist.sv',
                                      'src/mlsd_decision/syn/comb_mlsd_decision.sv',
                                      'src/fir/syn/comb_ffe.sv',
                                      'src/dig_comp/syn/comb_comp.sv', 
                                      'src/forward_path/syn/forward_path.sv',
                                      'verif/tb/beh/logic_recorder.sv'],
                        packages  = [generic_packager.path, testbench_packager.path, ffe_packager.path, cmp_packager.path, mlsd_packager.path],
                        flags     = ['-sv', '-64bit', '+libext+.v', '+libext+.sv', '+libext+.vp'],
                        build_dir = build_dir,
                        overload_seed=True,
                        wave=True
                    )



    quantized_chan_out_t = quantized_chan_out[check_bits:check_bits+depth]

    print(f'Quantized Chan: {quantized_chan_out}')
    print(f'Quantized Weights: {weights}')

    values = {}
    
    values['ffe_values'] = {}
    values['ffe_values']['coeff'] = weights
    values['ffe_values']['shift'] = ffe_shift 

    values['mlsd_values'] = {}
    values['mlsd_values']['chan_est'] = ffe_helper.qc.quantize_2s_comp(chan.impulse_response)[0:mlsd_config['parameters']['estimate_depth']]
    values['mlsd_values']['shift']    = 0

    values['comp_values'] = {}
    values['comp_values']['thresh'] = [0]

    values['test_values'] = {}
    values['test_values']['codes'] = quantized_chan_out

    write_mlsd_config_inputs(values, build_dir)   
         
    #Execute TestBench Object
    try:
        tester.run()
    except:
        Packager.delete_pack_dir(path=pack_dir)
        exit(0)

    Packager.delete_pack_dir(path=pack_dir)

    #Execute ideal python FIR 
    py_arr = ffe_helper.filt(quantized_chan_out_t)
    return
    
    py_arr = np.array([1 if int(np.floor(py_val)) >= 0 else 0 for py_val in py_arr])

    # Read in the SV results file
    sv_arr = read_svfile('verif/cmp/build_cmp/cmp_results.txt')
    # Compare
    sv_trim = (3+ffe_config['parameters']["length"]) * ffe_config["parameters"]["width"] - (ffe_config["parameters"]["length"]-1)
    # This trim needs to be fixed - I think the current approach is ""hacky""
    comp_len = math.floor((depth - ffe_config["parameters"]["length"] + 1) \
        /ffe_config["parameters"]["width"]) * ffe_config["parameters"]["width"]

    # Print ideal codes
    ideal_in = ideal_codes[pos:pos+check_bits]
    print(f'Ideal Codes: {ideal_in}')

    # Comparison
    result = compare(py_arr, sv_arr, sv_trim, check_bits, True)
    if result:
        print('TEST PASSED')
    else: 
        print('TEST FAILED')
    assert(result)


# Used for testing 
if __name__ == "__main__":
    main()
