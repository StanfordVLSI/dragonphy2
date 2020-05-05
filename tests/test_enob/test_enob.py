# general imports
import pytest
import numpy as np

# DragonPHY imports
from dragonphy import enob

Fs = 16e9
Fstim = 1.023e9
Nsamp = 2500

@pytest.mark.parametrize('Nbits', range(3, 16))
def test_enob(Nbits, enob_err=0.1):
    print(f'Testing ENOB function with Nbits={Nbits}')

    # generate test vector (with an intentional phase shift)
    t_vec = np.arange(Nsamp)/Fs + 0.5/Fs
    y_vec = np.sin(2*np.pi*Fstim*t_vec)

    # quantize
    q_vec = (y_vec+1)/2
    q_vec *= (2**Nbits)-1
    q_vec = np.round(q_vec)
    q_vec = np.clip(q_vec, 0, (2**Nbits)-1)

    # calculate enob
    enob_result = enob(q_vec, Fs=Fs, Fstim=Fstim)
    print(f'ENOB: {enob_result}')

    # check result
    assert (Nbits-enob_err) <= enob_result <= (Nbits+enob_err)