import sys
import numpy as np

def read_array(f):
    arr_text = ""

    while True:
        line = f.readline()
        if line == '':
            return 1, []

        arr_text += " " + line.strip()
        if ']' in line:
            break

    arr = np.array([int(val) for val in arr_text[2:-1].split('.')[:-1]])
    return 0, arr

def test_vector_sv(test_vectors, chan=[11, 72, 83, 62, 43, 31, 23, 17]):
    def stringify(vec):
        return [str(vv) for vv in vec]

    out_str = "package test_vectors;\n"
    out_str += f'\tlocalparam integer num_of_vects = {len(test_vectors)};\n'
    out_str += f'\tlogic signed [8:0] chan_vals [7:0] = \'{{{",".join(stringify(chan[::-1]))}}};\n'

    errs_str = f'\tlogic signed [8:0] errs_test_vectors[num_of_vects-1:0][3:0] = \'{{\n'
    bits_str = f'\tlogic bits_test_vectors[num_of_vects-1:0][3:0] = \'{{\n'

    for (err_vec, bit_vec) in test_vectors[:-1]:
        errs_str += f'\t\t\'{{' + ",".join(stringify(err_vec)[::-1]) + f'}},\n'
        bits_str += f'\t\t\'{{' + ",".join(stringify(bit_vec)[::-1]) + f'}},\n'

    errs_str += f'\t\t\'{{' + ",".join(stringify(test_vectors[-1][0])[::-1]) + f'}}\n\t}};\n'
    bits_str += f'\t\t\'{{' + ",".join(stringify(test_vectors[-1][1])[::-1]) + f'}}\n\t}};\n'

    out_str += errs_str
    out_str += bits_str

    out_str += 'endpackage\n'

    return out_str


data_sets = []
for filename in sys.argv[1:]:
    print(filename)
    with open(filename, 'r') as f:
        done = False
        while not done:
            arr = [0,0,0,0]

            for ii in range(4):
                status, arr[ii] = read_array(f)
                if status:
                    done = True
                    break

            data_sets += [arr]
        data_sets = data_sets[:-1]

test_vectors = []

for data_set in data_sets:
    errs = data_set[0][2:]
    bits = data_set[2][:-2]

    num_of_test_vectors = len(errs) - 5
    for ii in range(num_of_test_vectors):
        test_vectors += [(errs[ii:ii+5], bits[ii:ii+5])]

with open('test_vec_gpack.sv', 'w') as f:
    print(test_vector_sv(test_vectors), file=f)