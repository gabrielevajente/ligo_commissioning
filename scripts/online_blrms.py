#!/usr/bin/python 

# This script plot a real time chart of BLRMS
#
# You must run it within ipython --pylab
#
# Gabriele 2014-11-11

import cdsutils
from numpy import *
from pylab import *
from scipy.signal import *

def blockaver(x,n):
    return mean(reshape(x, [shape(x)[0]/n, n]),1)

######## list of photodiode channels ########################################
signal = ['H1:PSL-ISS_SECONDLOOP_SUM14_REL_OUT']

band = [200., 400.]
order = 2
fs = 32768

######## number of points for the strip chart (seconds) #####################
npts = 300

#############################################################################

# switch on interactive matplotlib
ion()

# start connection
conn = cdsutils.nds.get_connection()

# prepare the filter
b,a = butter(order, array(band)/(fs/2), btype='band')
zi = zeros(max(len(a),len(b))-1)

# start with empty traces
blrms = zeros(npts) * nan
first = True

# create new large figure
figure(figsize=(40,5))

# loop, default is one second data chunks
for bufs in conn.iterate(signal):
    # move back old data
    blrms[0:-1] = blrms[1:]
    # filter the signal
    bp, zi = lfilter(b, a, bufs[0].data, zi=zi)
    # square and average
    blrms[-1] = mean(bp**2)
    # throw away the first point
    if first:
        blrms[-1] = nan
        first = False

    # print out the number on terminal
    print blrms[-1]
    # update the plot, not very efficient way to do it, but working
    clf()
    plot(blrms, 'o-')
    #ylim([0, 3e-9])
    grid()
    show()
    draw()

