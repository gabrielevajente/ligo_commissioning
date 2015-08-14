#!/usr/bin/python 
import cdsutils
from numpy import *
from pylab import *
from scipy.signal import *
import ezca
import time
import atexit
e = ezca.Ezca()

######## list of channels ####################################################
# first four are the excitation channels, the last one is the recycling gain readout channel
signal = ['SUS-ITMX_LKIN_P_LO', 'SUS-ITMX_LKIN_Y_LO', 'SUS-ITMY_LKIN_P_LO', 'SUS-ITMY_LKIN_Y_LO', 'LSC-TR_X_NORM_OUT']
# signal = ['SUS-ITMX_L2_LOCK_P_EXC', 'SUS-ITMX_L2_LOCK_Y_EXC', 'SUS-ITMY_L2_LOCK_P_EXC', 'SUS-ITMY_L2_LOCK_Y_EXC', 'LSC-TR_X_NORM_OUT']
# here are the two offset we are going to change
offsets = ['SUS-ITMX_M0_OPTICALIGN_P_OFFSET', 'SUS-ITMX_M0_OPTICALIGN_Y_OFFSET', 'SUS-ITMY_M0_OPTICALIGN_P_OFFSET', 'SUS-ITMY_M0_OPTICALIGN_Y_OFFSET']

####### signal frequencies (angular PZT motions)
fline_xp = 10    # frequency and amplitude for ITMX pitch excitation
ampl_xp = 0
fline_xy = 15    # frequency and amplitude for ITMX yaw excitation
ampl_xy = 0
fline_yp = 20    # frequency and amplitude for ITMY pitch excitation
ampl_yp = 0
fline_yy = 25    # frequency and amplitude for ITMY yaw  excitation
ampl_yy = 0

######## time constant for running exponential average ######################
a = 0.2

######## number of points for the strip chart (seconds) #####################
npts = 600

####### wait this number of seconds before starting servoing ################
initial_wait = 10

####### offset loop gains ###################################################
gain_xp = 0
gain_xy = 0
gain_yp = 0
gain_yy = 0


#############################################################################

def addifo(x):
    return ifo+":"+x

# register a function to switch excitation off when exiting the script
def switch_everything_off():
    e['SUS-ITMX_LKIN_P_OSC_CLKGAIN'] = 0
    e['SUS-ITMX_LKIN_Y_OSC_CLKGAIN'] = 0
    e['SUS-ITMX_L2_LKIN_EXC_SW'] = 0
    e['SUS-ITMY_LKIN_P_OSC_CLKGAIN'] = 0
    e['SUS-ITMY_LKIN_Y_OSC_CLKGAIN'] = 0
    e['SUS-ITMY_L2_LKIN_EXC_SW'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_1_1'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_2_1'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_3_1'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_4_1'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_1_2'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_2_2'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_3_2'] = 0
    e['SUS-ITMX_L2_LKIN2OSEM_4_2'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_1_1'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_2_1'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_3_1'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_4_1'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_1_2'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_2_2'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_3_2'] = 0
    e['SUS-ITMY_L2_LKIN2OSEM_4_2'] = 0

atexit.register(switch_everything_off)

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
figure(figsize=(35,12))

# send excitation to the right degrees of freedom
e['SUS-ITMX_L2_LKIN2OSEM_1_1'] = e['SUS-ITMX_L2_EUL2OSEM_1_2']
e['SUS-ITMX_L2_LKIN2OSEM_2_1'] = e['SUS-ITMX_L2_EUL2OSEM_2_2']
e['SUS-ITMX_L2_LKIN2OSEM_3_1'] = e['SUS-ITMX_L2_EUL2OSEM_3_2']
e['SUS-ITMX_L2_LKIN2OSEM_4_1'] = e['SUS-ITMX_L2_EUL2OSEM_4_2']
e['SUS-ITMX_L2_LKIN2OSEM_1_2'] = e['SUS-ITMX_L2_EUL2OSEM_1_3']
e['SUS-ITMX_L2_LKIN2OSEM_2_2'] = e['SUS-ITMX_L2_EUL2OSEM_2_3']
e['SUS-ITMX_L2_LKIN2OSEM_3_2'] = e['SUS-ITMX_L2_EUL2OSEM_3_3']
e['SUS-ITMX_L2_LKIN2OSEM_4_2'] = e['SUS-ITMX_L2_EUL2OSEM_4_3']
e['SUS-ITMY_L2_LKIN2OSEM_1_1'] = e['SUS-ITMY_L2_EUL2OSEM_1_2']
e['SUS-ITMY_L2_LKIN2OSEM_2_1'] = e['SUS-ITMY_L2_EUL2OSEM_2_2']
e['SUS-ITMY_L2_LKIN2OSEM_3_1'] = e['SUS-ITMY_L2_EUL2OSEM_3_2']
e['SUS-ITMY_L2_LKIN2OSEM_4_1'] = e['SUS-ITMY_L2_EUL2OSEM_4_2']
e['SUS-ITMY_L2_LKIN2OSEM_1_2'] = e['SUS-ITMY_L2_EUL2OSEM_1_3']
e['SUS-ITMY_L2_LKIN2OSEM_2_2'] = e['SUS-ITMY_L2_EUL2OSEM_2_3']
e['SUS-ITMY_L2_LKIN2OSEM_3_2'] = e['SUS-ITMY_L2_EUL2OSEM_3_3']
e['SUS-ITMY_L2_LKIN2OSEM_4_2'] = e['SUS-ITMY_L2_EUL2OSEM_4_3']

# switch on excitations on L2
e['SUS-ITMX_LKIN_P_OSC_FREQ'] = fline_xp
e['SUS-ITMX_LKIN_P_OSC_CLKGAIN'] = ampl_xp
e['SUS-ITMX_LKIN_Y_OSC_FREQ'] = fline_xy
e['SUS-ITMX_LKIN_Y_OSC_CLKGAIN'] = ampl_xy
e['SUS-ITMX_L2_LKIN_EXC_SW'] = 1

e['SUS-ITMY_LKIN_P_OSC_FREQ'] = fline_yp
e['SUS-ITMY_LKIN_P_OSC_CLKGAIN'] = ampl_yp
e['SUS-ITMY_LKIN_Y_OSC_FREQ'] = fline_yy
e['SUS-ITMY_LKIN_Y_OSC_CLKGAIN'] = ampl_yy
e['SUS-ITMY_L2_LKIN_EXC_SW'] = 1

# loop, default is one second data chunks
t0 = time.time()
ct = 0
for bufs in conn.iterate(signal):
    # move back old data
    demod_xp[0:-1] = demod_xp[1:]
    demod_xy[0:-1] = demod_xy[1:]
    demod_yp[0:-1] = demod_yp[1:]
    demod_yy[0:-1] = demod_yy[1:]
    offs_xp[0:-1] = offs_xp[1:]
    offs_xy[0:-1] = offs_xy[1:]
    offs_yp[0:-1] = offs_yp[1:]
    offs_yy[0:-1] = offs_yy[1:]
    exc_xp[0:-1] = exc_xp[1:]
    exc_xy[0:-1] = exc_xy[1:]
    exc_yp[0:-1] = exc_yp[1:]
    exc_yy[0:-1] = exc_yy[1:]
    sig_xp[0:-1] = sig_xp[1:]
    sig_xy[0:-1] = sig_xy[1:]
    sig_yp[0:-1] = sig_yp[1:]
    sig_yy[0:-1] = sig_yy[1:]

    # demodulate at line frequency
    e_xp = bufs[0].data * exp(2j*pi*fline_xp*arange(0,len(bufs[0].data))/len(bufs[0].data))
    e_xy = bufs[1].data * exp(2j*pi*fline_xy*arange(0,len(bufs[1].data))/len(bufs[1].data))
    e_yp = bufs[2].data * exp(2j*pi*fline_yp*arange(0,len(bufs[2].data))/len(bufs[2].data))
    e_yy = bufs[3].data * exp(2j*pi*fline_yy*arange(0,len(bufs[3].data))/len(bufs[3].data))

    s_xp = bufs[4].data * exp(2j*pi*fline_xp*arange(0,len(bufs[4].data))/len(bufs[4].data))
    s_xy = bufs[4].data * exp(2j*pi*fline_xy*arange(0,len(bufs[4].data))/len(bufs[4].data))
    s_yp = bufs[4].data * exp(2j*pi*fline_yp*arange(0,len(bufs[4].data))/len(bufs[4].data))
    s_yy = bufs[4].data * exp(2j*pi*fline_yy*arange(0,len(bufs[4].data))/len(bufs[4].data))

    # average signals
    exc_xp[-1] = (1-a)*exc_xp[-2] + a*mean(e_xp)
    exc_xy[-1] = (1-a)*exc_xy[-2] + a*mean(e_xy)
    exc_yp[-1] = (1-a)*exc_yp[-2] + a*mean(e_yp)
    exc_yy[-1] = (1-a)*exc_yy[-2] + a*mean(e_yy)
    sig_xp[-1] = (1-a)*sig_xp[-2] + a*mean(s_xp)
    sig_xy[-1] = (1-a)*sig_xy[-2] + a*mean(s_xy)
    sig_yp[-1] = (1-a)*sig_yp[-2] + a*mean(s_yp)
    sig_yy[-1] = (1-a)*sig_yy[-2] + a*mean(s_yy)

    # compute complex TF
    demod_xp[-1] = real(sig_xp[-1]/exc_xp[-1])
    demod_xy[-1] = real(sig_xy[-1]/exc_xy[-1])
    demod_yp[-1] = real(sig_yp[-1]/exc_yp[-1])
    demod_yy[-1] = real(sig_yy[-1]/exc_yy[-1])
    
    # get offset values
    offs_xp[-1] = e[offsets[0]]
    offs_xy[-1] = e[offsets[1]]
    offs_yp[-1] = e[offsets[2]]
    offs_yy[-1] = e[offsets[3]]

    # servo offsets
    ct = ct + 1
    if ct>=initial_wait:
        dt = time.time() - t0
        e[offsets[0]] = offs_xp[-1] + gain_xp * dt * demod_xp[-1]
        e[offsets[1]] = offs_xy[-1] + gain_xy * dt * demod_xy[-1]
        e[offsets[2]] = offs_yp[-1] + gain_yp * dt * demod_yp[-1]
        e[offsets[3]] = offs_yy[-1] + gain_yy * dt * demod_yy[-1]
    t0 = time.time()

    # print out the numbers on terminal
    print demod_xp[-1],demod_xy[-1], demod_yp[-1],demod_yy[-1]
    
    # update the plot, not very efficient way to do it, but it's working
    clf()
    subplot(211)
    plot(range(len(demod_xp)), demod_xp, 'ro-', range(len(demod_xy)), demod_xy, 'rx-', range(len(demod_yp)), demod_yp, 'go-', range(len(demod_yy)), demod_yy, 'gx-')
    ylim(-2,2)
    legend(('%s/%s @ %d Hz' % (signal[4], signal[0], fline_xp), '%s/%s @ %d Hz' % (signal[4], signal[1], fline_xy), 
            '%s/%s @ %d Hz' % (signal[4], signal[2], fline_yp), '%s/%s @ %d Hz' % (signal[4], signal[3], fline_yy)))
    grid()
    subplot(212)
    plot(range(len(offs_xp)), offs_xp, 'ro-', range(len(offs_xy)), offs_xy, 'ro-', range(len(offs_yp)), offs_yp, 'go-', range(len(offs_yy)), offs_yy, 'go-')
    legend(offsets)
    grid()
    show()
    draw()
