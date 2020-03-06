import matplotlib.pyplot as plt


conv_data = []
bit_data  = [] 
seq0_data = []
seq1_data = []
seq_data  = []

with open('conv_codes.txt', 'r') as f:
    for line in f:
        conv_data.append(int(line.strip()))

with open('conv_bits.txt', 'r') as f:
    for line in f:
        bit_data.append(int(line.strip()))

with open('mlsd_seq.txt', 'r') as f:
    for line in f:
        values = line.strip().split()
        seq0 = [int(val) for val in  values[0:10]]
        seq1 = [int(val) for val in values[10:20]]
        seq0_data.append(seq0)
        seq1_data.append(seq1)            

seq_data = [seq1 if bit > 0 else seq0 for (seq0, seq1, bit) in zip(seq0_data, seq1_data, bit_data)]

num_l = list(range(len(conv_data)))

fig = plt.figure()
plt.plot(num_l, conv_data, '-k', alpha=0.2)

for (ii, seq) in enumerate(seq0_data):
    seq_l = list(range(ii, ii+10, 1))
    plt.plot(seq_l[0], seq[0], 'xr', alpha=0.5)

for (ii, seq) in enumerate(seq1_data):
    seq_l = list(range(ii, ii+10, 1))
    plt.plot(seq_l[0], seq[0], 'xb',alpha=0.5)

for (ii, seq) in enumerate(seq_data):
    seq_l = list(range(ii, ii+10, 1))
    plt.plot(seq_l[0], seq[0], 'ok', alpha=0.2)

plt.show()
