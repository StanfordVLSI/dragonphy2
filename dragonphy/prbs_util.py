def verify_prbs(*args, **kwargs):
    assert count_prbs_err(*args, **kwargs) == 0

def count_prbs_err(prbs_vals, prbs_eqn, n_ti=1, n_prbs=32):
    # initialize values
    rx_mem = 0
    mem_count = 0
    err_count = 0

    # check bits one-by-one
    for prbs_val in prbs_vals:
        for j in range(n_ti):
            # get the new bits
            rx_bit = (prbs_val >> j) & 1

            # determine if an error occurred
            # this checking can only be done
            # if the bit memory has been filled,
            # which is why we keep track of mem_count
            if mem_count >= n_prbs:
                # select bits for the equation
                rx_mem_select = rx_mem & prbs_eqn

                # XOR reduction
                rx_mem_xor = 0
                for k in range(n_prbs):
                    rx_mem_xor ^= (rx_mem_select >> k) & 1

                if rx_mem_xor != rx_bit:
                    err_count += 1

            # load the bit into memory
            rx_mem = (rx_mem << 1) | rx_bit
            mem_count += 1

    # return number of error bits
    return err_count