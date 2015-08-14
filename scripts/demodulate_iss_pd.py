# This script demodulates the ISS second loop photodiodes using the 
# excitation sent to IM3. The demodulated signal is averaged over periods
# of one second and plotted in a strip-tool like chart
#
# You must run it within ipython --pylab
#
# Gabriele 2014-09-29

import cdsutils
from numpy import *
from pylab import *

def blockaver(x,n):
    return mean(reshape(x, [shape(x)[0]/n, n]),1)

######## list of photodiode channels ########################################
# pd = ['H1:PSL-ISS_SECONDLOOP_PD5_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD6_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD7_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD8_OUT']

pd = ['H1:PSL-ISS_SECONDLOOP_SUM14_AC_OUT',
      'H1:PSL-ISS_SECONDLOOP_SUM58_AC_OUT']

# pd = ['H1:PSL-ISS_SECONDLOOP_PD1_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD2_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD3_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD4_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD5_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD6_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD7_OUT',
#       'H1:PSL-ISS_SECONDLOOP_PD8_OUT']

######## excitation channels (exactly 2) ####################################
exc = ['H1:SUS-IM3_M1_OPTICALIGN_P_EXC',
       'H1:SUS-IM3_M1_OPTICALIGN_Y_EXC']

######## number of points for the strip chart (seconds) #####################
npts = 300

#############################################################################


# start connection
conn = cdsutils.nds.get_connection()

# prepare some stuff
npd = len(pd)
channels = concatenate([pd, exc])

# start with empty traces
demod_p = zeros([npd, npts])
demod_y = zeros([npd, npts])

# create new large figure
figure(figsize=(40,10))

# loop, default is one second data chunks
for bufs in conn.iterate(channels):
    # move back old data
    demod_p[:,0:-1] = demod_p[:,1:]
    demod_y[:,0:-1] = demod_y[:,1:]
    # compute the new data points for each PD
    for i in range(npd):
        # get the data, downsample PDs, multiply with excitation and average
        demod_p[i,-1] = mean(blockaver(bufs[i].data,2) * bufs[npd].data)
        demod_y[i,-1] = mean(blockaver(bufs[i].data,2) * bufs[npd+1].data)
    # print out the number on terminal
    print demod_p[:,-1]
    print demod_y[:,-1]
    # update the plot, not very efficient way to do it, but working
    clf()
    subplot(211)
    plot(transpose(demod_p))
    ylim([-0.3, 0.3])
    grid()
    legend(channels[0:-2], bbox_to_anchor=(0,1.02, 1., .102), loc=3, ncol=4)
    ylabel('PITCH')
    subplot(212)
    plot(transpose(demod_y))
    ylim([-0.3, 0.3])
    ylabel('YAW')
    xlabel('Time [s]')
    grid()
    show()
    draw()

