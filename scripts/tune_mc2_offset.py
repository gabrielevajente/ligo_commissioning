#!/usr/bin/python 
import cdsutils
from numpy import *
from pylab import *
from scipy.signal import *
import ezca
import time
e = ezca.Ezca()

# Function to switch on excitation, with ramping
def excitation(channel, frequency, amplitude, T, Tramp, fsample):
    # generate excitation file
    t = arange((T+2*Tramp)*fsample)/double(fsample)
    s = sin(2*pi*frequency*t)
    e = ones(shape(t))
    e[t<Tramp] = t[t<Tramp]/Tramp
    e[t>T+Tramp] = (T+2*Tramp - t[t>T+Tramp])/Tramp
    se = s * e
    ff = open('excitation.txt', 'w')
    for x in se:
        ff.write('%.10f '% x)
    ff.close()
    # start it
    with open(os.devnull, 'w') as fp:
        subprocess.Popen(["awgstream", channel, str(fsample), 'excitation.txt', str(amplitude)])

######## list of channels ####################################################
ifo = "H1" 
# first two are the excitation, the last one is the intensity noise readout
signal = ['IMC-PZT_PIT_EXC', 'IMC-PZT_YAW_EXC', 'PSL-ISS_SECONDLOOP_SUM14_REL_OUT_DQ']
# here are the two offset we are going to change
offsets = ['IMC-DOF_2_P_OFFSET', 'IMC-DOF_1_Y_OFFSET']

####### signal frequencies (angular PZT motions)
fline1 = 80      # frequency and amplitude for pitch excitation
ampl1 = 3

fline2 = 110     # frequency and amplitude for yaw excitation
ampl2 = 3

fsample = 2048   # excitation sampling rate

T = 300          # duration of the excitation in seconds
Tramp = 1        # ramp time for the excitation

######## time constant for running exponential average ######################
a = 0.2

######## number of points for the strip chart (seconds) #####################
npts = 300

####### wait this number of seconds before starting servoing ################
initial_wait = 10

####### offset loop gains ###################################################
gain1 = -5000000
gain2 = -500000

#############################################################################

def addifo(x):
    return ifo+":"+x

# switch on interactive matplotlib
ion()

# start connection
conn = cdsutils.nds.get_connection()

# start with empty traces
sig1 = zeros(npts, dtype=cfloat)
sig2 = zeros(npts, dtype=cfloat)
sig3 = zeros(npts, dtype=cfloat)
sig4 = zeros(npts, dtype=cfloat)
demod1 = zeros(npts) 
demod2 = zeros(npts) 
offs1 = zeros(npts) 
offs2 = zeros(npts) 

# create new large figure
figure(figsize=(40,15))

# start excitations
excitation(addifo(signal[0]), fline1, ampl1, T, Tramp, fsample)
excitation(addifo(signal[1]), fline2, ampl2, T, Tramp, fsample)
time.sleep(12)

# loop, default is one second data chunks
t0 = time.time()
ct = 0
for bufs in conn.iterate(signal):
    # move back old data
    demod1[0:-1] = demod1[1:]
    demod2[0:-1] = demod2[1:]
    offs1[0:-1] = offs1[1:]
    offs2[0:-1] = offs2[1:]
    sig1[0:-1] = sig1[1:]
    sig2[0:-1] = sig2[1:]
    sig3[0:-1] = sig3[1:]
    sig4[0:-1] = sig4[1:]

    # demodulate at line frequency
    s1 = bufs[0].data * exp(2j*pi*fline1*arange(0,len(bufs[0].data))/len(bufs[0].data))
    s2 = bufs[1].data * exp(2j*pi*fline2*arange(0,len(bufs[1].data))/len(bufs[1].data))
    s3 = bufs[2].data * exp(2j*pi*fline1*arange(0,len(bufs[2].data))/len(bufs[2].data))
    s4 = bufs[2].data * exp(2j*pi*fline2*arange(0,len(bufs[2].data))/len(bufs[2].data))
    # average signals
    sig1[-1] = (1-a)*sig1[-2] + a*mean(s1)
    sig2[-1] = (1-a)*sig2[-2] + a*mean(s2)
    sig3[-1] = (1-a)*sig3[-2] + a*mean(s3)
    sig4[-1] = (1-a)*sig4[-2] + a*mean(s4)
    # compute complex TF
    demod1[-1] = real(sig3[-1]/sig1[-1])
    demod2[-1] = real(sig4[-1]/sig2[-1])
    
    # get offset values
    offs1[-1] = e[offsets[0]]
    offs2[-1] = e[offsets[1]]

    # change offsets
    ct = ct + 1
    if ct>=initial_wait:
        dt = time.time() - t0
        e[offsets[0]] = offs1[-1] + gain1 * dt * demod1[-1]
        e[offsets[1]] = offs2[-1] + gain2 * dt * demod2[-1]
    t0 = time.time()

    # print out the number on terminal
    print demod1[-1],demod2[-1]
    # update the plot, not very efficient way to do it, but it's working
    clf()
    subplot(211)
    plot(range(len(demod1)), 1e6*demod1, 'o-', range(len(demod2)), 1e6*demod2, 'x-')
    ylim(-2,2)
    legend(('%s/%s @ %d Hz' % (signal[2], signal[0], fline1), '%s/%s @ %d Hz' % (signal[2], signal[1], fline2)))
    grid()
    subplot(212)
    plot(range(len(offs1)), offs1, 'o-', range(len(offs2)), offs2, 'o-')
    legend(offsets)
    grid()
    show()
    draw()

    # exit when the excitation gets switched off
    if ct>T:
        break

