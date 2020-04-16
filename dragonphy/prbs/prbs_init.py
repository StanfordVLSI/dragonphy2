class PRBS:
    def __init__(self, val):
        self.val = val

    def get_next(self):
        out = (self.val >> 6) & 1
        newbit = ((self.val >> 6) ^ (self.val >> 5)) & 1
        self.val = ((self.val << 1) | newbit) & 0x7f
        return out

    def get_seq(self, num):
        return [self.get_next() for _ in range(num)]

def bv2int(bv):
    # msb first, lsb last
    retval = 0
    for k, bit in enumerate(bv):
        retval |= bit << (len(bv) - 1 - k)
    return retval

n = 7
num_chan = 16

prbs_orig = PRBS(1)
seq_orig = prbs_orig.get_seq(((1<<n)-1)*num_chan+num_chan-1)

init_vals = [0] * num_chan
prbs_seqs = [[]] * num_chan
for k in range(num_chan):
    init_vals[k] = bv2int(seq_orig[k::num_chan][:n])
    prbs_seqs[k] = PRBS(init_vals[k]).get_seq((1<<n)-1)
    assert prbs_seqs[k] == seq_orig[k::num_chan][:((1<<n)-1)]

print(init_vals)
print('Success!')