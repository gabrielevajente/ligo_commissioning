#!/usr/bin/python

##### Generic sensing matrix measurement script ######################################################################
# 2015-03-06 Gabriele Vajente (vajente@caltech.edu)
#
# Calling the script without any argument will start a new measurement. The GPS times will be saved to a logfile
# Calling the script passing the logfile as first argumetn will only process the data, without performing any injection

import subprocess
import os
import cdsutils
import nds2
from numpy import *
from pylab import *
from scipy.signal import *
import time
import markup
import sys

######## Parameters ###################################################################################################

# prefix of the output file names (logfile and html file)
filename = "asc_sensing_matrix_fulllock_yaw"

# where are you?
ifo = "H1" 

# list of excitation channels
excitations = ["ASC-INP1_Y_EXC", "ASC-PRC1_Y_EXC", "ASC-PRC2_Y_EXC", "ASC-MICH_Y_EXC", "ASC-SRC1_Y_EXC", "ASC-SRC2_Y_EXC", "ASC-DHARD_Y_EXC", "ASC-CHARD_Y_EXC"]
# sampling frequency of the excitation channels
fsample = 2048
# list of corresponding excitation frequencies
freqs = [8, 8, 8, 8, 8, 8, 8, 8]
# and of amplitudes
ampls =  [1000000, 100, 10000000, 1, 10000000, 1, 10, 100]

# list of channels used to monitor the real motion of the dofs (in calibrated and comparable units if possible)
# those are the channels used in the denominator of the transfer functions
#monitors = ["SUS-IM4_M1_DAMP_Y_IN1_DQ", "SUS-PRM_M3_WIT_Y_DQ", "SUS-PR2_M3_WIT_Y_DQ", 
#            "SUS-BS_M3_OPLEV_YAW_OUT_DQ", "SUS-SRM_M3_WIT_Y_DQ", "SUS-SR2_M3_WIT_Y_DQ",
#            "SUS-ETMX_L3_OPLEV_YAW_OUT_DQ", "SUS-ETMY_L3_OPLEV_YAW_OUT_DQ"]
monitors = ["ASC-INP1_Y_OUT_DQ", "ASC-PRC1_Y_OUT_DQ", "ASC-PRC2_Y_OUT_DQ", "ASC-MICH_Y_OUT_DQ", 
               "ASC-SRC1_Y_OUT_DQ", "ASC-SRC2_Y_OUT_DQ", "ASC-DHARD_Y_OUT_DQ", "ASC-CHARD_Y_OUT_DQ"]

# list of the error signal channels
readout = ["ASC-AS_A_DC_YAW_OUT_DQ", "ASC-AS_A_RF36_I_YAW_OUT_DQ", "ASC-AS_A_RF36_Q_YAW_OUT_DQ", "ASC-AS_A_RF45_I_YAW_OUT_DQ", "ASC-AS_A_RF45_Q_YAW_OUT_DQ",
           "ASC-AS_B_DC_YAW_OUT_DQ", "ASC-AS_B_RF36_I_YAW_OUT_DQ", "ASC-AS_B_RF36_Q_YAW_OUT_DQ", "ASC-AS_B_RF45_I_YAW_OUT_DQ", "ASC-AS_B_RF45_Q_YAW_OUT_DQ",
           "ASC-REFL_A_DC_YAW_OUT_DQ", "ASC-REFL_A_RF9_I_YAW_OUT_DQ", "ASC-REFL_A_RF9_Q_YAW_OUT_DQ", "ASC-REFL_A_RF45_I_YAW_OUT_DQ", "ASC-REFL_A_RF45_Q_YAW_OUT_DQ",
           "ASC-REFL_B_DC_YAW_OUT_DQ", "ASC-REFL_B_RF9_I_YAW_OUT_DQ", "ASC-REFL_B_RF9_Q_YAW_OUT_DQ", "ASC-REFL_B_RF45_I_YAW_OUT_DQ", "ASC-REFL_B_RF45_Q_YAW_OUT_DQ",
           "ASC-POP_A_YAW_OUT_DQ", "ASC-POP_B_YAW_OUT_DQ"]

# Measurement time for each excitation
T = 60;

# Ramp time to switch on and off excittion
Tramp = 5

# Frequency resolution for the FFT (the excitation line must fall into one of the FFT bins, otherwise my poor coding will fail)
df = 0.25;


# Coherence threshold
cth = 0.8

######## Auxiliary function definition  #################################################################################
def gpsnow():
    return int(subprocess.check_output(["tconvert", "now"]))

def excitation(channel, frequency, amplitude, T, Tramp):
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

def addifo(x):
    return ifo+":"+x

def adddq(x):
    return x+"_DQ"

def decimate(x, q, n=None, ftype='iir', axis=-1):
    """downsample the signal x by an integer factor q, using an order n filter
    
    By default, an order 8 Chebyshev type I filter is used or a 30 point FIR 
    filter with hamming window if ftype is 'fir'.

    (port to python of the GNU Octave function decimate.)

    Inputs:
        x -- the signal to be downsampled (N-dimensional array)
        q -- the downsampling factor
        n -- order of the filter (1 less than the length of the filter for a
             'fir' filter)
        ftype -- type of the filter; can be 'iir' or 'fir'
        axis -- the axis along which the filter should be applied
    
    Outputs:
        y -- the downsampled signal

    """

    if type(q) != type(1):
        raise Error, "q should be an integer"

    if n is None:
        if ftype == 'fir':
            n = 30
        else:
            n = 4
    if ftype == 'fir':
        b = firwin(n+1, 1./q, window='hamming')
        y = lfilter(b, 1., x, axis=axis)
    else:
        (b, a) = cheby1(n, 0.05, 0.8/q)

        y = lfilter(b, a, x, axis=axis)

    return y.swapaxes(0,axis)[::q].swapaxes(0,axis)

######## Main loop for noise injection ########################################################################################################

# # add IFO prefix to all channels
readout = map(addifo, readout)
excitations = map(addifo, excitations)
monitors = map(addifo, monitors)

# if you pass no command line argument, perform injection, otherwise load GPS times from file
if len(sys.argv) == 1:
    ### loop over all excitation channels
    logfile = []
    for exc,i,frequency,amplitude in zip(excitations, range(len(excitations)), freqs, ampls): 
        ### switch on excitation (with automatic timeout)
        sys.stdout.write("[%d] start excitation for channel %s\n" % (gpsnow(), exc))
        excitation(exc, frequency, amplitude, T, Tramp)
        ### wait for the excitation to start
        time.sleep(11 + Tramp)
        start_gps = gpsnow()
        print "  GPS start: %d " % start_gps
        ### wait the desired time
        time.sleep(T)
        stop_gps = gpsnow()
        print "  GPS stop: %d " % stop_gps
        time.sleep(Tramp)
        ### append times to the log file
        logfile.append([start_gps, stop_gps, exc])
	
    ### Save the logfile 	
    f = open(filename+".log", 'w')
    for l in logfile:
        f.write("%d %d %s\n" % (l[0], l[1], l[2]))
    f.close()
    print "Saved GPS times in logfile: %s" % filename+".log"
else:
    ### load logfile
    f = open(sys.argv[1])
    lines = f.readlines()
    logfile = []
    for line in lines:
        tok = line.split()
        logfile.append([int(tok[0]), int(tok[1]), tok[2]])
    f.close()

######## Main loop for data processing ########################################################################################################

# open NDS connection
conn = nds2.connection('nds.ligo-wa.caltech.edu', 31200)
# preallocate the sensing matrix and the coherence matrix
matrix = zeros([len(readout), len(excitations)], dtype='complex128')
cohe   = zeros([len(readout), len(excitations)])

# loop over all excitation channels
for exc,mon,log,i,frequency in zip(excitations, monitors, logfile, range(len(excitations)), freqs): 
    print "Analyzing excitation %s, monitored with %s, data from %d to %d" % (exc, mon, log[0], log[1])
    ### read data (trying more times if the data is not yet on disk)
    waitfordata = True
    while waitfordata:
        try:
            channels = readout[:]
            channels.append(mon)
            bufs = conn.fetch(log[0], log[1], channels)   
            waitfordata = False
        except:
            print "  Waiting for data..."
            waitfordata = True
            time.sleep(10)

    ### get the sampling frequencies
    fs_sig = bufs[0].length / (log[1] - log[0])
    fs_mon = bufs[-1].length / (log[1] - log[0])

    ### decimate monitoring channel to lower fs if needed
    fs = min(fs_sig, fs_mon)
    if fs_mon > fs:
        datamon = decimate(bufs[-1].data, fs_mon / fs)
    else:
        datamon = bufs[-1].data

    ### compute transfer function and coherence at the frequency of the excitation
    # length of each FFT
    nfft = int(fs / df) 
    # PSD of the monitor channel
    pm,fr = psd(datamon, NFFT=nfft, Fs=fs, noverlap=nfft/2)
    # find the correct bin index
    fridx = find(fr == frequency)

    ### loop over all the readout channels
    for j in range(len(readout)):
        # decimate if needed
        if fs_sig > fs:
            data = decimate(bufs[j].data, fs_sig / fs)
        else:
            data = bufs[j].data

        # compute spectrum and cross spectrum
        py,fr = psd(data, NFFT=nfft, Fs=fs, noverlap=nfft/2)
        cmy,fr = csd(datamon, data, NFFT=nfft, Fs=fs, noverlap=nfft/2)
        # compute TF and coherence at the bin
        matrix[j,i] = cmy[fridx[0]] / pm[fridx[0]]
        cohe[j,i] = abs(cmy[fridx[0]])**2 / pm[fridx[0]] / py[fridx[0]]
        # Print some results
        print "   %s: coherence = %f  tf = %e + %ei" % (readout[j], cohe[j,i], real(matrix[j,i]), imag(matrix[j,i]))


######## Save result to a HTML file #####################################################################################

# Start page and add the sensing matrix table
page = markup.page( )
page.init( title="Sensing matrix measurement", \
           footer="(2015)  <a href=mailto:vajente@caltech.edu>vajente@caltech.edu</a>" )

page.h1('Sensing matrix (abs)')
page.table(border=1)
# First row, list of excitations and monitors
page.tr()
page.td("Excitation:")
page.td.close()
for i in range(len(excitations)):
    page.td(align="center")
    page.add("<b>"+excitations[i]+"</b>")
    page.td.close()
page.tr.close()
page.tr()
page.td("Monitor channel:")
page.td.close()
for i in range(len(excitations)):
    page.td(align="center")
    page.add("<b>"+monitors[i]+"</b>")
    page.td.close()
page.tr.close()
# write all sensing matrix elements
for j in range(len(readout)):
    page.tr()
    page.td()
    page.add("<b>"+readout[j]+"</b>")
    page.td.close()
    idxmax = argmax(abs(matrix[j,:]))
    for i in range(len(excitations)):
        page.td(align="center")
        if cohe[j,i] > cth:
            if i == idxmax:
                page.add("<b><font color=#ff0000>%e</font></b>" % abs(matrix[j,i]))
            else:
                page.add("%e" % abs(matrix[j,i]))
        else:
            page.add("<font color=#999999>%e</font>" % abs(matrix[j,i]))
        page.td.close()
    page.tr.close()
# close table
page.table.close()

# Coherence table
page.h1('Coherence matrix')
page.table(border=1)
# First row, list of excitations and monitors
page.tr()
page.td("Excitation:")
page.td.close()
for i in range(len(excitations)):
    page.td(align="center")
    page.add("<b>"+excitations[i]+"</b>")
    page.td.close()
page.tr.close()
page.tr()
page.td("Monitor channel:")
page.td.close()
for i in range(len(excitations)):
    page.td(align="center")
    page.add("<b>"+monitors[i]+"</b>")
    page.td.close()
page.tr.close()
# write all sensing matrix elements
for j in range(len(readout)):
    page.tr()
    page.td()
    page.add("<b>"+readout[j]+"</b>")
    page.td.close()
    for i in range(len(excitations)):
        page.td(align="center")
        page.add("%f" % cohe[j,i])
        page.td.close()
    page.tr.close()
# close table
page.table.close()


page.h1('Sensing matrix (complex)')
page.table(border=1)
# First row, list of excitations and monitors
page.tr()
page.td("Excitation:")
page.td.close()
for i in range(len(excitations)):
    page.td(align="center")
    page.add("<b>"+excitations[i]+"</b>")
    page.td.close()
page.tr.close()
page.tr()
page.td("Monitor channel:")
page.td.close()
for i in range(len(excitations)):
    page.td(align="center")
    page.add("<b>"+monitors[i]+"</b>")
    page.td.close()
page.tr.close()
# write all sensing matrix elements
for j in range(len(readout)):
    page.tr()
    page.td()
    page.add("<b>"+readout[j]+"</b>")
    page.td.close()
    for i in range(len(excitations)):
        page.td(align="center")
        if cohe[j,i] > cth:
            page.add("%e + %ei" % (real(matrix[j,i]), imag(matrix[j,i])))
        else:
            page.add("<font color=#999999>%e + %ei</font>" % (real(matrix[j,i]), imag(matrix[j,i])))
        page.td.close()
    page.tr.close()
# close table
page.table.close()

# save page
page.savehtml(filename+".html")

print "Create summary table in file: %s" % filename+".html"
subprocess.call(["firefox", filename+".html"])
