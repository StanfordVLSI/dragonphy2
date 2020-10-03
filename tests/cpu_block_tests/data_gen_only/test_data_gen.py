# general imports
import shutil
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

RESET    = 0b000
UNIFORM  = 0b001
CONSTANT = 0b010
INCL     = 0b011
EXCL     = 0b100
ALT      = 0b101
HOLD     = 0b110

def test_sim(simulator_name, n=8):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # declare circuit
    class dut(m.Circuit):
        name = 'histogram_data_gen'
        io = m.IO(
            clk=m.ClockIn,
            mode=m.In(m.Bits[3]),
            in0=m.In(m.Bits[n]),
            in1=m.In(m.Bits[n]),
            out=m.Out(m.Bits[n])
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize with the right equation
    t.zero_inputs()

    # run a few cycles
    t.step(10)

    # test uniform mode
    t.poke(dut.mode, UNIFORM)
    t.step(4)
    unif_vec = []
    for _ in range(1<<n):
        unif_vec.append(t.get_value(dut.out))
        t.step(2)

    # test constant mode
    t.poke(dut.mode, CONSTANT)
    t.poke(dut.in0, 42)
    t.step(4)
    const_vec = []
    for _ in range(1<<n):
        const_vec.append(t.get_value(dut.out))
        t.step(2)

    # test "include" mode
    t.poke(dut.mode, INCL)
    t.poke(dut.in0, 34)
    t.poke(dut.in1, 56)
    t.step(4)
    incl_vec = []
    for _ in range(1<<n):
        incl_vec.append(t.get_value(dut.out))
        t.step(2)

    # test "exclude" mode
    t.poke(dut.mode, EXCL)
    t.poke(dut.in0, 12)
    t.poke(dut.in1, 243)
    t.step(4)
    excl_vec = []
    for _ in range(1 << n):
        excl_vec.append(t.get_value(dut.out))
        t.step(2)

    # test "alternate" mode
    t.poke(dut.mode, ALT)
    t.poke(dut.in0, 78)
    t.poke(dut.in1, 89)
    t.step(4)
    alt_vec = []
    for _ in range(1 << n):
        alt_vec.append(t.get_value(dut.out))
        t.step(2)

    ##################
    # run simulation #
    ##################

    t.compile_and_run(
        target='system-verilog',
        simulator=simulator_name,
        ext_srcs=get_deps_cpu_sim(cell_name='histogram_data_gen'),
        parameters={
            'n': n,
        },
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        directory=BUILD_DIR
    )

    ###################
    # convert results #
    ###################

    def conv(x):
        return [elem.value for elem in x]
    unif_vec = conv(unif_vec)
    const_vec = conv(const_vec)
    incl_vec = conv(incl_vec)
    excl_vec = conv(excl_vec)
    alt_vec = conv(alt_vec)

    #################
    # print results #
    #################

    print(f'unif_vec: {unif_vec}')
    print()
    print(f'const_vec: {const_vec}')
    print()
    print(f'incl_vec: {incl_vec}')
    print()
    print(f'excl_vec: {excl_vec}')
    print()
    print(f'alt_vec: {alt_vec}')
    print()

    #################
    # check results #
    #################

    # uniform
    assert list(sorted(unif_vec)) == list(range(1<<n)), 'Output of uniform data generator unexpected.'

    # constant
    assert const_vec == [42]*(1<<n), 'Output of constant data generator unexpected.'

    # include
    per = 56-34+1
    nper = len(incl_vec) // per
    expct = []
    for k in range(34, 57):
        expct += [k]*nper
    assert list(sorted(incl_vec[:nper*per])) == expct, 'Output of "include" pattern unexpected.'

    # exclude
    per = (11-0+1) + (255-244+1)
    nper = len(excl_vec) // per
    expct = []
    for k in range(0, 12):
        expct += [k]*nper
    for k in range(244, 256):
        expct += [k]*nper
    assert list(sorted(excl_vec[:nper*per])) == expct, 'Output of "exclude" pattern unexpected.'

    # alternating
    assert alt_vec[:2] == [78, 89] or alt_vec[:2] == [89, 78]
    assert alt_vec == alt_vec[:2]*(1<<(n-1)), 'Output of alternating data generator unexpected.'

    ###################
    # declare success #
    ###################

    print('Success!')
