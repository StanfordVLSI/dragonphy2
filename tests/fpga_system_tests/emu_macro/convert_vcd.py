from pyDigitalWaveTools.vcd.parser import VcdParser, VcdVarParsingInfo
import matplotlib.pyplot as plt

import numpy as np
from copy import deepcopy
import json
vcd = VcdParser()

def insert_probe(probe_data, data, time_offset):
    probe_time = np.array([probe_datum[0] for probe_datum in probe_data])
    data_time  = np.array([datum[0] + time_offset for datum in data])


    idxs = np.searchsorted(probe_time, data_time, side='left')

    for datum, idx in zip(data[::-1], idxs[::-1]):
        probe_data.insert(idx, (datum[0] + time_offset, datum[1]))

def convert_to_time_sval_arrays(probe, width):

    def signed(val):
        return  val - 2**width if val > 2**(width-1) else val

    times = np.array([probe_datum[0] for probe_datum in probe])
    svals = np.array([signed(int(probe_datum[1].split('b')[1],2)) for probe_datum in probe])

    return times, svals

probes = ['stage2_res_errors_out', 'stage3_sd_flags_ener', 'stage3_sd_flags', 
          'stage4_res_errors_out', 'stage5_sd_flags_ener', 'stage5_sd_flags',
          'stage6_res_errors_out', 'stage7_sd_flags_ener', 'stage7_sd_flags', 
          'stage8_res_errors_out']

aligned_probes = {}
probe_meta_data = {}

for probe in probes:
    aligned_probes[probe] = []

with open('./build/sim/raw_results/top_sim.vcd') as f:
    vcd.parse(f)
    time_base = int((vcd.scope.children['top'].children['trace_port_gen_i'].children['clk_adc'].data[12][0] - vcd.scope.children['top'].children['trace_port_gen_i'].children['clk_adc'].data[10][0])/16.0)

    for probe in ['stage2_res_errors_out', 'stage4_res_errors_out', 'stage3_sd_flags_ener', 'stage3_sd_flags']:
        aligned_probes[probe] = deepcopy(vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{0}'].data)
        
        vcdId = vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{0}'].vcdId
        name = vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{0}'].name
        width = vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{0}'].width
        sigType = vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{0}'].sigType
        parent = vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{0}'].parent

        probe_meta_data[probe] = (vcdId, name, width, sigType, parent)

        print(vcdId, name, width, sigType, parent)
        for ii in range(1, 16):
            insert_probe(aligned_probes[probe], vcd.scope.children['top'].children['trace_port_gen_i'].children[f'{probe}_{ii}'].data, ii*time_base)

fig, axs = plt.subplots(4)

for ii, probe in enumerate(['stage2_res_errors_out', 'stage4_res_errors_out', 'stage3_sd_flags_ener', 'stage3_sd_flags']):
    pt, pd = convert_to_time_sval_arrays(aligned_probes[probe], probe_meta_data[probe][2])
    axs[ii].plot(pt, pd, label=probe)
    axs[ii].set_xlim([8.354e12, 8.3571e12])
plt.show()
