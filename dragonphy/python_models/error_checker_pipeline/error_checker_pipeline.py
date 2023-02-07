import numpy as np
from dragonphy import TrellisNeighborChecker, Buffer, ErrorInjectionEngine
from copy import deepcopy

class ErrorCheckerPipeline: 
    def __init__(self, num_of_channels, seq_length, num_of_trellis_patterns, trellis_pattern_depth, output_pipeline_depth, cp=2):
    
        self.total_depth = output_pipeline_depth
        self.sym_pipeline_depth = output_pipeline_depth
        self.sym_pipeline_end   = output_pipeline_depth

        self.error_pipeline_depth = max(1, output_pipeline_depth)
        self.error_pipeline_end   = output_pipeline_depth

        def sym_buff_i():
            return Buffer(num_of_channels, self.sym_pipeline_depth)
        
        def flatten_res_err_buff_i(self):
            return self.flatten_buffer(1, 0)

        def res_err_buff_i():
            return Buffer(num_of_channels, self.error_pipeline_depth)

        def tnc_i(est_errors, channel, channel_shift, nrz_mode, trellis_patterns):
            return TrellisNeighborChecker(num_of_channels, seq_length, num_of_trellis_patterns, channel, trellis_patterns, nrz_mode, est_errors, cp=cp)
        
        def mmse_reg_i():
            return Buffer(num_of_channels, output_pipeline_depth)

        def argmin_reg_i():
            return Buffer(num_of_channels, output_pipeline_depth)

        self.sym_buff_i = sym_buff_i()
        self.res_err_buff_i = res_err_buff_i()

        self.flatten_res_err_buff_i = flatten_res_err_buff_i
        self.tnc_i = tnc_i

        self.mmse_reg_i = mmse_reg_i()
        self.argmin_reg_i = argmin_reg_i()



    def at_posedge_clock(self, syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns):
  
       # print(self.res_err_buff_i.mem)
       # input()
     


        self.sym_buff_i.at_posedge_clock()
        self.res_err_buff_i.at_posedge_clock()
        self.mmse_reg_i.at_posedge_clock() 
        self.argmin_reg_i.at_posedge_clock()

        self.sym_buff_i.set_input(syms_in)
        self.res_err_buff_i.set_input(res_errors_in)

        flat_re_in = self.flatten_res_err_buff_i(self.res_err_buff_i)
        flags, flag_eners  = self.tnc_i(flat_re_in, channel_est, channel_shift, 0, trellis_patterns)

        self.mmse_reg_i.set_input(flag_eners)
        self.argmin_reg_i.set_input(flags)
        


        ret_val =  (deepcopy( self.argmin_reg_i.mem[:, self.total_depth]), 
               deepcopy(self.res_err_buff_i.mem[:, self.error_pipeline_end]), 
               deepcopy(self.sym_buff_i.mem[:, self.sym_pipeline_depth]), 
               deepcopy(self.mmse_reg_i.mem[:,self.total_depth]))




        return ret_val

    def at_negedge_reset(self):
        self.sym_buff_i.at_negedge_reset()
        self.res_err_buff_i.at_negedge_reset()
        self.mmse_reg_i.at_negedge_reset()
        self.argmin_reg_i.at_negedge_reset()


if __name__ == "__main__":
    seq_length = 3
    num_of_trellis_patterns = 4
    trellis_pattern_depth = 4

    error_checker_i = ErrorCheckerPipeline(16, seq_length, num_of_trellis_patterns, trellis_pattern_depth, 0)

    channel_est   = [25, 125, 250, 125, 65, 32]
    channel_shift = 3
    trellis_patterns = [
                        [+1,  0,  0,  0],
                        [+1, -1,  0,  0],
                        [+1,  0,  0, -1],
                        [+1, -1, +1, -1]
    ]

    injection_error_seqs = ErrorInjectionEngine(seq_length, 4, channel_shift, 0, channel_est, trellis_patterns)

    syms_in = np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])

    res_errors_in = np.random.randint(-5, 5, size=16)
    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)

    syms_in = np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])
    res_errors_in = np.random.randint(-5, 5, size=16)
    res_errors_in[3:3+seq_length] += injection_error_seqs[0]

    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)

    syms_in = np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])
    res_errors_in = np.random.randint(-5, 5, size=16)

    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)

    syms_in = np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])
    res_errors_in = np.random.randint(-5, 5, size=16)

    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)