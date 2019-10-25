import fixture
from fixture.real_types import LinearBitKind
import fault
import magma
from pathlib import Path

#def reformat(results):
#    ivs = []
#    dvs = []
#    for result in results:
#        iv, dv = result
#        ivs.append(iv)
#        #dvs.append([float(dv_component) for dv_component in dv])
#        dvs.append(dv)
#    return ivs, dvs
#
#def reformat2(results):
#    # was for [in,out]: for mode: for vec: for pin: x
#    # we swap the first two axes
#    return list(zip(*list(results)))
#
#def get_tf(stats, ivs):
#    def tf(x):
#        y = 0
#        for iv in ivs:
#            coefs = list(stats['coef_gain'][iv])
#            for order, coef in enumerate(coefs):
#                y += coef * x**order
#            return y
#    return tf
#
#def plot_errors(x, y1, y2):
#    import matplotlib.pyplot as plt
#    for a,b,c in zip(x, y1, y2):
#        d = '-g' if c > b else '-r'
#        plt.plot([a, a], [b, c], d)
#    plt.grid()
#    plt.show()
#
#def plot2(results, statsmodels, in_dim=0):
#    if __name__ != '__main__':
#        return
#    xs, ys = results
#    xs = [x[in_dim] for x in xs]
#    ys = [y[0] for y in ys]
#    estimated = statsmodels.fittedvalues
#    plot_errors(xs, ys, estimated)
#
#    
#
#def plot(results, tf):
#    if __name__ != '__main__':
#        return
#    import matplotlib.pyplot as plt
#    #xs, ys = zip(*results)
#    #xs = [x[0] for x in xs]
#    #ys = [y[0] for y in ys]
#    xs, ys = results
#    plt.plot(xs, ys, '*')
#    xs.sort()
#    plt.plot(xs, [tf(x[0]) for x in xs], '--')
#    plt.grid()
#    plt.show()

spice_file = './comparator.sp'
output_params_file = 'comparator_params.yaml'

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

