import numpy as np

dt = 1/16e9
tau = dt

def ch_resp(n):
    return (1-np.exp(-(n+1)*dt/tau))*np.heaviside(n+1, 0.5) \
           - (1-np.exp(-n*dt/tau))*np.heaviside(n, 0.5)

depth = 5
eqn = np.zeros((depth, depth), dtype=float)
for k in range(depth):
    eqn[k, :] = ch_resp(np.array(range(k, k-depth, -1)))

vec = np.zeros(depth, dtype=float)
vec[0] = 1.0

x = np.linalg.solve(eqn, vec)
print(x)

print(1.0/(1-np.exp(-dt/tau)))
print(-np.exp(-dt/tau)/(1-np.exp(-dt/tau)))