import pytest

Nti = 18
Nadc = 8

@pytest.mark.skip(reason='still in the process of porting this test')
def test_sim():
    check_sram()

def check_sram():
    # read results
    # in_ = read_ti_adc('sram_in.txt')
    # out = read_ti_adc('sram_out.txt')
    in_ = None
    out = None

    # make sure that input is at least as long as output
    assert len(in_) >= len(out), 'Recorded SRAM input should be at least as long as SRAM output.'

    for k, (sram_in, sram_out) in enumerate(zip(in_[:len(out)], out)):
        assert sram_in == sram_out, f'Data mismatch on line {k//Nti}: {sram_in} != {sram_out}.'
