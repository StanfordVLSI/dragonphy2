import numpy as np
import matplotlib.pyplot as plt
from .channel import Channel

class Wiener():
    def __init__(self, step_size=2, num_taps=5, debug=False, cursor_pos=1):
        self.step_size      		= step_size
        self.num_taps       		= num_taps
        self.filter_in      		= np.zeros(num_taps)
        self.weights        		= np.random.randn(num_taps)
        self.weights[cursor_pos] 	= 1
        self.error          		= np.inf
        self.total_error    		= []
        self.debug          		= debug

    def update_initial_weights(self, new_weights):
        self.weights = new_weights

    def find_weights(self, ideal_in, curr_filter_in):
        # update filter inputs
        append_in = np.append(self.filter_in, curr_filter_in)
        self.filter_in = append_in[1:self.num_taps + 1] 

        if self.debug:
            print(f'Filter input: {self.filter_in}')

        # R = E[u(n)u^H(n)]
        R = np.outer(self.filter_in, np.conj(self.filter_in))
        if self.debug:
            print(f'R: {R}')    
        
        # p = E[u(n)d*(n)] 
        p = np.conj(ideal_in)*self.filter_in
        if self.debug:
            print(f'p: {p}')

        next_weights = self.weights +  self.step_size*(p - np.multiply(R, self.weights))
        self.weights = next_weights

        return next_weights

    def find_weights_error(self, ideal_in, curr_filter_in):
        # update filter inputs
        self.filter_in  = np.insert(self.filter_in[0:-1], 0, curr_filter_in)
        if self.debug:
            print(f'Input: {self.filter_in}')   

        self.error = ideal_in - np.dot(self.weights, self.filter_in)
        self.total_error.append(self.error)
        if self.debug:
            print(f'Error: {self.error}')
            print(f'W[n]: {self.weights}')

        next_weights = self.weights + self.step_size*np.multiply(self.error,self.filter_in)
        self.weights = next_weights
        if self.debug:
            print(f'W[n+1]: {next_weights}')

        return next_weights
    
    def find_weights_pulse(self, ideal_in, curr_filter_in):

        self.filter_in  = np.insert(self.filter_in[0:-1], 0, curr_filter_in)
        est_input  = np.dot(self.weights, self.filter_in)
        self.error = ideal_in - est_input
        self.total_error.append(self.error)

        ue_prod = np.multiply(self.filter_in, self.error)
        normal_coeff = 1.0 #/(1e-5 + np.dot(curr_samples, curr_samples))
        next_weights = self.weights + normal_coeff*self.step_size*ue_prod
        self.weights = next_weights
        return next_weights

    def plot_total_error(self):
        plt.plot(self.total_error)
        plt.show()

    def clear_total_error(self):
        self.total_error = []

    def find_weights_pulse2(self): 
        N_iter = 200000
        N_taps = 11
        mew0    = 0.1

        ch = Channel(channel_type='skineffect', normal='area', tau=2, sampl_rate=5, resp_depth=125)

        inp_data = 2*np.random.randint(0, 2, size=(N_iter,))-1 
        out_data = ch(inp_data)

        #The convolution needs to be centered better...
        cursor_pos = ch.cursor_pos


        ww_lms = np.zeros((N_iter, N_taps)) #np.random.randn(N_iter,N_taps)/2.0 #np.zeros((N_iter, 10))
        error  = np.zeros((N_iter, 1))
        est_data = np.zeros((N_iter,1))
        ave_J_e2 = np.ones((N_iter,1))*10

        ww_lms[0] = np.random.randn(N_taps)
        ww_lms[0][cursor_pos] = 1

        curr_samples = np.zeros((N_taps,))

        for ii in range(1, N_iter):
            curr_samples = np.insert(curr_samples[0:-1], 0, out_data[ii])
            est_input  = np.dot(ww_lms[ii-1], curr_samples)
            #error[ii]  = inp_data[ii-cursor_pos]  - est_input
            est_data[ii] = 2.0*(est_input>0)-1
            error[ii]  = est_data[ii] - est_input
            ave_J_e2[ii] = error[ii]*error[ii]*0.01 + ave_J_e2[ii-1]*0.99
            ue_prod = np.multiply(curr_samples, error[ii])
            normal_coeff = 1.0/(1e-5 + np.dot(curr_samples, curr_samples))
            mew = mew0
            ww_lms[ii] = ww_lms[ii-1] + normal_coeff*mew*ue_prod
        return ww_lms

# Used for testing 
if __name__ == "__main__":
    w = Wiener()
        
