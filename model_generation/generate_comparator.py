import fixture
from fixture.real_types import LinearBitKind
import fault
import magma
from pathlib import Path


spice_file = './comparator/comparator.sp'
output_params_file = './comparator/comparator_params.yaml'

def model_comparator():
    print('\nTop of model_comparator')

    # this interface can be used for spice sims as well as verilog models
    class ComparatorInterface(fixture.templates.ContinuousComparatorTemplate):
        name = 'comparator_interface'
        IO = [
            'my_in', fixture.RealIn((0.0, 1.2)),
            'my_out', magma.BitOut,
            'vdd', fixture.RealIn(1.2),
            'vss', fixture.RealIn(0.0)
        ]
        def mapping(self):
            self.in_ = self.my_in
            self.out = self.my_out

    # The name and IO here match the spice model in spice/myamp.sp
    # Since we include that file in compile_and_run, they get linked
    class MyAmp(ComparatorInterface):
        name = 'simple_comparator'

    print('Creating test bench')
    # auto-create vectors for 1 analog dimension
    vectors = fixture.Sampler.get_samples_for_circuit(MyAmp, 50)

    tester = fault.Tester(MyAmp)
    testbench = fixture.Testbench(tester)
    testbench.set_test_vectors(vectors)
    testbench.create_test_bench()

    print(f'Running sim, {len(vectors[0])} test vectors')
    tester.compile_and_run('spice',
        simulator='ngspice',
        model_paths = [Path(spice_file).resolve()],
        vsup=1.2,
        vil_rel=0.5,
        vih_rel=0.5
    )

    print('Analyzing results')
    results = testbench.get_results()
    ins, outs = results
    results_reformatted = [ins[0], outs[0]]

    my_ins  = [x[0] for x in results_reformatted[0]]
    my_outs = [x[0] for x in results_reformatted[1]]
    trip = fixture.templates.ContinuousComparatorTemplate.get_tripping_point((my_ins, my_outs))
    print('Measured trip point is', trip)

    trip_expression = {'coef':{'offset':trip}}
    params = {'slice_point':[trip_expression]}
    filename = output_params_file
    fixture.dummy_dump(params, filename)

if __name__ == '__main__':
    model_comparator()

