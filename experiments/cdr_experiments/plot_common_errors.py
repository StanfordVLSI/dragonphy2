import matplotlib.pyplot as plt

p_err = [1,0,0,0,0]
pn_err = [1,-1,0,0,0]
pnp_err = [1,-1,1,0,0]
p1n_err = [1,0,-1,0,0]
pnpn_err = [1,-1,1,-1,0]
pnp1p_err = [1,-1,1,0,1]
p2n_err = [1,0,0,-1,0]
pn1n_err = [1,-1,0,-1,0]

error_patterns = [p_err, pn_err, pnp_err, p1n_err, p2n_err, pnp1p_err, [1,-1,1,-1,1], pnpn_err, pn1n_err]

height = 3

fig = plt.figure()

for ii, error_pattern in enumerate(error_patterns):
	plt.subplot(3,3,ii+1)
	plt.stem(error_pattern)

plt.show()

