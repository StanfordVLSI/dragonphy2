import magma, fault

def run_sim(top_module, *args, ext_test_bench=True, disp_type='realtime', **kwargs):
    tester = fault.Tester(magma.DeclareCircuit(top_module))
    tester.compile_and_run(
        *args,
        target='system-verilog',
        top_module=top_module,
        ext_test_bench=ext_test_bench,
        disp_type=disp_type,
        **kwargs
    )