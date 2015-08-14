#!/usr/bin/python 

# Plot a real time strip of the ratio of two signals at a given frequency.
# This is useful for example to tune the demodulation phase of a signal
# Just add the I and Q signals, then the plot will show Q/I, which is 
# typically what you want to minimize
#
# Gabriele Vajente vajente@caltech.edu 2015-03-05

import cdsutils
from numpy import *
from pylab import *
from scipy.signal import *

######## list of photodiode channels ########################################
signal = ['IMC-PZT_PIT_EXC', 'LSC-DARM_IN1_DQ']

######## line frequency #####################################################
fline = 412.

######## time constant for running exponential average #####################
a = 0.1

######## number of points for the strip chart (seconds) #####################
npts = 300


#############################################################################

# switch on interactive matplotlib
ion()

# start connection
conn = cdsutils.nds.get_connection()

# start with empty traces
sig1 = zeros(npts, dtype=cfloat)
sig2 = zeros(npts, dtype=cfloat)
demodr1 = zeros(npts) 
demodi1 = zeros(npts) 

# create new large figure
figure(figsize=(40,10))

# loop, default is one second data chunks
for bufs in conn.iterate(signal):
    # move back old data
    demodr1[0:-1] = demodr1[1:]
    demodi1[0:-1] = demodi1[1:]
    sig1[0:-1] = sig1[1:]
    sig2[0:-1] = sig2[1:]
    
    # demodulate at line frequency
    s1 = bufs[0].data * exp(2j*pi*fline*arange(0,len(bufs[0].data))/len(bufs[0].data))
    s2 = bufs[1].data * exp(2j*pi*fline*arange(0,len(bufs[1].data))/len(bufs[1].data))
    # average signals
    s2 = s2[:8:]
    sig1[-1] = (1-a)*sig1[-2] + a*mean(s1)
    sig2[-1] = (1-a)*sig2[-2] + a*mean(s2)
    # compute complex TF
    demodr1[-1] = real(sig2[-1]/sig1[-1])
    demodi1[-1] = imag(sig2[-1]/sig1[-1])
    
    # print out the number on terminal
    print demodr1[-1],demodi1[-1]
    # update the plot, not very efficient way to do it, but it's working
    clf()
    plot(range(len(demodr1)), demodr1, 'o-', range(len(demodi1)), demodi1, 'x-', )
    title("%d Hz" % (fline))
    legend(("Real %s/%s @ %d Hz" % (signal[1], signal[0], fline), "Imag %s/%s" % (signal[1], signal[0])), loc="lower left")
    grid()
    show()
    draw()

