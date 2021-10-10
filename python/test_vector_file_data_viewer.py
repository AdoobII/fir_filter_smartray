import numpy as np
import matplotlib.pyplot as plt
from bitstring import BitArray

data = []

with open("VHDL/test_vectors/o_top_testout.txt", 'r') as f:
    for line in f.readlines():
        data.append(BitArray(bin=line).int)

plt.plot(data)
plt.show()
