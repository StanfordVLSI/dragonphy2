from random import randint

class PRBS:
    def __init__(self, val):
        self.val = val

    def get_next(self):
        out = (self.val >> 6) & 1
        newbit = ((self.val >> 6) ^ (self.val >> 5)) & 1
        self.val = ((self.val << 1) | newbit) & 0x7f
        return out

n = 7
shift_amt = 0

prbs1_init = randint(1, (1<<n)-1)
prbs1 = PRBS(prbs1_init)
seq1 = [prbs1.get_next() for _ in range(((1<<n)-1)+shift_amt)]
prbs1_shift = seq1[shift_amt:]

prbs2_init = 0
for k, bit in enumerate(prbs1_shift[:n]):
    prbs2_init |= bit << (n-1-k)
prbs2 = PRBS(prbs2_init)
seq2 = [prbs2.get_next() for _ in range((1<<n)-1)]

print(prbs1_init)
print(prbs2_init)
print(seq2 == prbs1_shift)