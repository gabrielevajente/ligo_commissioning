#!/usr/bin/python 

import cdsutils
from numpy import *
from pylab import *
from scipy.signal import *
import subprocess
import ezca
import atexit
import time

# switch off excitation when program terminates
def exit_function():
    subprocess.Popen(["tdssine", str(fpit), '0', signals[0], '1'])
    subprocess.Popen(["tdssine", str(fyaw), '0', signals[1], '1'])
atexit.register(exit_function)

######## channels and offsets ##############################################
signals = ['H1:IMC-PZT_PIT_EXC', 'H1:IMC-PZT_YAW_EXC', 'H1:PSL-ISS_SECONDLOOP_SUM14_REL_OUT']
offsets = ['IMC-DOF_2_P_OFFSET', 'IMC-DOF_1_Y_OFFSET']

# signal to check IMC is locked before acting on the offsets, and corresponding
# threshold
imc_power = 'IMC-MC2_TRANS_SUM_OUTMON'
imc_threshold = 100

######## line frequencies and amplitudes ####################################
fpit = 101.0
fyaw = 153.0
apit = 3
ayaw = 3

######## time constant for running exponential average #####################
a = 0.1

######## loop gains #########################################################
gain_pit = -3e5
gain_yaw = -1e5

######## number of points for the strip chart (seconds) #####################
npts = 600

# initial time to wait for filters to settle
initial_wait = 30
# stop after this time has passed
timeout = 600

######## BLRMS monitor ######################################################
# frequency band
band = [200., 400.]
# Butterworth filter order
order = 2
# sampling frequency of the ISS channel
fs = 32768

# switch on interactive matplotlib
ion()

######## start excitations #################################################
# default to stop after 1800 seconds, but they will be switched off when the 
# script exits
subprocess.Popen(["tdssine", str(fpit), str(apit), signals[0], str(timeout)])
subprocess.Popen(["tdssine", str(fyaw), str(ayaw), signals[1], str(timeout)])
time.sleep(10)

######## main demodulation and servo loop ##################################

# start connections
conn = cdsutils.nds.get_connection()
e = ezca.Ezca()

# start with empty traces
sig1 = zeros(npts, dtype=cfloat)
sig2 = zeros(npts, dtype=cfloat)
sig3 = zeros(npts, dtype=cfloat)
sig4 = zeros(npts, dtype=cfloat)
demodp = zeros(npts)
demody = zeros(npts) 
blrms = zeros(npts)
offsetp = zeros(npts) 
offsety = zeros(npts) 
# flat remove first point of BLRMS, to avid initial filter transients
first = True

# create new large figure
figure(figsize=(40,15))

# prepare the BLRMS filter
B,A = butter(order, array(band)/(fs/2), btype='band')
zi = zeros(max(len(A),len(B))-1)

# loop, default is one second data chunks
count = 0
for bufs in conn.iterate(signals):
    # move back old data
    demodp[0:-1] = demodp[1:]
    demody[0:-1] = demody[1:]
    sig1[0:-1] = sig1[1:]
    sig2[0:-1] = sig2[1:]
    sig3[0:-1] = sig3[1:]
    sig4[0:-1] = sig4[1:]
    blrms[0:-1] = blrms[1:]

    # demodulate at line frequency
    s1 = bufs[0].data * exp(2j*pi*fpit*arange(0,len(bufs[0].data))/len(bufs[0].data))
    s2 = bufs[1].data * exp(2j*pi*fyaw*arange(0,len(bufs[1].data))/len(bufs[1].data))
    s3 = bufs[2].data * exp(2j*pi*fpit*arange(0,len(bufs[2].data))/len(bufs[2].data))
    s4 = bufs[2].data * exp(2j*pi*fyaw*arange(0,len(bufs[2].data))/len(bufs[2].data))
    # average signals
    sig1[-1] = (1-a)*sig1[-2] + a*mean(s1)
    sig2[-1] = (1-a)*sig2[-2] + a*mean(s2)
    sig3[-1] = (1-a)*sig3[-2] + a*mean(s3)
    sig4[-1] = (1-a)*sig4[-2] + a*mean(s4)
    # compute real part of TF (error signals for the loop)
    demodp[-1] = real(sig3[-1]/sig1[-1])
    demody[-1] = real(sig4[-1]/sig2[-1])
    
    # compute BLRMS: band pass the signal
    bp, zi = lfilter(B, A, bufs[2].data, zi=zi)
    # square and average
    blrms[-1] = abs(mean(bp**2))
    # throw away the first point
    if first:
        blrms[-1] = nan
        first = False

    # read offsets
    offsetp[0:-1] = offsetp[1:]
    offsety[0:-1] = offsety[1:]
    offsetp[-1] = e[offsets[0]]
    offsety[-1] = e[offsets[1]]

    # servo offsets
    count = count + 1
    if count>timeout:
        break

#    if count > initial_wait and e[imc_power] > imc_threshold:
#        if not isnan(demodp[-1]):
#            e[offsets[0]] = e[offsets[0]] + gain_pit * demodp[-1]
#        if not isnan(demody[-1]):
#            e[offsets[1]] = e[offsets[1]] + gain_yaw * demody[-1]

    # update the plot, not the most efficient way to do it, but working for few points plot like this one
    clf()
    subplot(311)
    plot(range(len(demodp)), 1e5*demodp, 'o-', range(len(demody)), 1e5*demody, 'x-')
    title("Demodulated signals")
    legend(("%s / %s @ %d Hz" % (signals[2], signals[0], fpit), "%s / %s @ %d Hz" % (signals[2], signals[1], fyaw)), loc="lower left")
    grid()
    subplot(312)
    plot(range(len(blrms)), (1e9*blrms), 'o-')
    title("BLRMS of %s (%d-%d Hz)" % (signals[2], band[0], band[1]))
    grid()
    subplot(313)
    plot(range(len(offsetp)), offsetp, 'o-', range(len(offsety)), offsety, 'o-')
    legend(offsets, loc="lower left")
    grid()
    show()
    draw()



