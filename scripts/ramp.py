import ezca
import numpy
import time

e = ezca.Ezca()

g0 = e['SUS-ITMX_LKIN_P_OSC_CLKGAIN']
g1 = 00

sleep = 0.1
T = 5
N = numpy.round(T/sleep)

for g in numpy.linspace(g0, g1, N):
    e['SUS-ITMX_LKIN_P_OSC_CLKGAIN'] = g
    time.sleep(sleep)
