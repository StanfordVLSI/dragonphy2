import numpy as np




class Buffer:
    def __init__(self, num_of_channels, buffer_depth):
        self.buffer_depth = buffer_depth
        self.num_of_channels = num_of_channels
        self.mem = np.zeros((num_of_channels, buffer_depth+1))
        self.values = np.zeros((num_of_channels,))

    def set_input(self, values):
        self.mem[:,0] = values

    def at_posedge_clock(self):
        print(self.mem.shape, self.buffer_depth)
        self.mem[:,1:] = self.mem[:,:-1]
        return self.mem
    
    def at_negedge_reset(self):
        self.mem = np.zeros((self.num_of_channels, self.buffer_depth+1))
        return self.mem
    
    def flatten_buffer(self, slice_depth, start):
        flat_arr = np.zeros((self.num_of_channels*(1+slice_depth),))

        for jj in range(self.num_of_channels):
            for ii in range(slice_depth+1):
                flat_arr[(slice_depth-ii)*self.num_of_channels + jj] = self.mem[jj,ii]
        return flat_arr #mem[:, start:slice_depth+1,].flatten(order='F')

if __name__ == "__main__":
    mem = np.zeros((5, 3))

    mem[:, 0] = np.arange(0,5,1)
    mem[:, 1] = np.arange(5,10,1)
    mem[:, 2] = np.arange(10,15,1)
    print(mem)
