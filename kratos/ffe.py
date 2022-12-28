from kratos import *

class InterleavedFFEMod(Generator):
    def __init__(self, code_bitwidth, weight_bitwidth, output_bitwidth, depth, N):
        super().__init__("InterleavedFFE", False)
        self.codes = self.input("codes", code_bitwidth, is_signed=True, size=(N + depth))
        self.weights = self.input("weights", weight_bitwidth, is_signed=True, size=(depth, N))
        self.equalized_codes = self.output("eq_codes", output_bitwidth, is_signed=True, size=N)
        self.N = N
        self.depth = depth

        self.slices = []
        self.weight_transpose = self.var(f'weights_transpose', weight_bitwidth, is_signed=True, size=(N,depth))
        for ii in range(N):
            self.slices += [FeedForwardEqualizerSliceMod(code_bitwidth, weight_bitwidth, output_bitwidth, depth)] 
            self.add_child(f'ffe_slice_{ii}_i', self.slices[ii])
            
            self.wire(self.codes[depth-1+ii,ii], self.slices[ii].codes)
            self.wire(self.slices[ii].weights, self.weight_transpose[ii])
            self.wire(self.equalized_codes[ii], self.slices[ii].equalized_code)


        self.add_always(self.slice_weights)
    
    @always_comb
    def slice_weights(self):
        for ii in range(self.depth):
            for jj in range(self.N):
                self.weight_transpose[jj][ii] = self.weights[ii][jj]

class FeedForwardEqualizerSliceMod(Generator):
    def __init__(self, code_bitwidth, weight_bitwidth, output_bitwidth, depth):
        super().__init__("FeedForwardEqualizerSlice",False)
        self.codes = self.input("codes", code_bitwidth, is_signed=True, size=(depth))
        self.weights = self.input("weights", weight_bitwidth, is_signed=True, size=(depth))
        self.equalized_code = self.output("eq_code", output_bitwidth, is_signed=True)
        self.depth = depth
        self.const_depth = const(depth, 4)
        self.add_always(self.multiply_and_sum)

    @always_comb
    def multiply_and_sum(self):
        self.equalized_code = 0
        for ii in range(self.depth):
            self.equalized_code += self.codes[self.const_depth - ii] * self.weights[ii] 


ffe = InterleavedFFEMod(4,4,8,15,16)
verilog(ffe, filename='ffe.sv', check_combinational_loop=False)
