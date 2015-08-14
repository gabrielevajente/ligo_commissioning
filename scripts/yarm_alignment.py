#!/usr/bin/env python

import ezca
import cdsutils
import time
from threading import Thread
import argparse
import sys
import numpy

#from alignFull_parameters import *

e = ezca.Ezca()

# average ezca data over multiple reads, this function is used to check the WFS centering
def ezcaAverageMultiple(signals, dt=2, rate=0.05):
    # signals = list of signals
    # dt = total average time
    # rate = time beteween each subsequent sampling
    N = int(dt / rate)
    sig = numpy.zeros(len(signals))
    for i in range(N):
        for j in range(len(signals)):
            sig[j] = sig[j] + e[signals[j]]
        time.sleep(rate)
    sig = sig/N
    return sig

if __name__ == '__main__':

    ###### PARAMETERS ######

    # list of the error signals
    errors = ('ASC-REFL_A_RF9_I_PIT_OUTMON', 'ASC-REFL_A_RF9_I_YAW_OUTMON', 'ASC-REFL_B_RF9_I_PIT_OUTMON', 'ASC-REFL_B_RF9_I_YAW_OUTMON')
    # list of corresponding actuation points
    actuators = ('SUS-ITMY_M0_OPTICALIGN_P_OFFSET', 'SUS-ITMY_M0_OPTICALIGN_Y_OFFSET', 'SUS-ETMY_M0_OPTICALIGN_P_OFFSET', 'SUS-ETMY_M0_OPTICALIGN_Y_OFFSET')
    # loop gains 
    gains = [-0.001, -0.001, -0.001, 0.001]
    # power signal used to trigger
    powersig = 'LSC-Y_TR_A_LF_OUTMON'

    # define thresholds
    yarm_threshold_dc = 0.1 # threshold on the WFS centering
    yarm_threshold = 5000   # do something only if power is larger than this
    yarm_err_threshold = 5  # stop when all error signals are below this value

    # time constant for the running average of the error signals
    T = 2*numpy.pi*10 
   
    #######################

    # set ramp times
    e['SUS-ETMY_M0_OPTICALIGN_P_TRAMP'] = 1
    e['SUS-ETMY_M0_OPTICALIGN_Y_TRAMP'] = 1
    e['SUS-ITMY_M0_OPTICALIGN_P_TRAMP'] = 1
    e['SUS-ITMY_M0_OPTICALIGN_Y_TRAMP'] = 1

    # Activate WFS centering
    print 'Switching on REFL WFS centering...'
    e.switch('ASC-DC1_P', 'INPUT', 'ON')
    e.switch('ASC-DC1_Y', 'INPUT', 'ON')
    e.switch('ASC-DC2_P', 'INPUT', 'ON')
    e.switch('ASC-DC2_Y', 'INPUT', 'ON')
        
    # wait for centering to reach a reasonable value
    err = ezcaAverageMultiple(('ASC-DC1_P_INMON', 'ASC-DC1_Y_INMON', 'ASC-DC2_P_INMON', 'ASC-DC2_Y_INMON'))
    while max(abs(err)) > yarm_threshold_dc:
        print 'Waiting for WFS centering...'
        time.sleep(1)
        err = ezcaAverageMultiple(('ASC-DC1_P_INMON', 'ASC-DC1_Y_INMON', 'ASC-DC2_P_INMON', 'ASC-DC2_Y_INMON'))

    t0 = time.time()
    # initial error values (used for termination condition)
    average_err = numpy.zeros(len(errors))
    for i in range(len(errors)):
        average_err[i] = e[errors[i]]
    # compute the maximum of error signal absolute values
    max_err = max(average_err)

    # Main loop, continue until error signals are all smaller than threshold. Stop if power drops below threshold
    while max_err > yarm_err_threshold and e[powersig] > yarm_threshold:
        # compute the time since the last actuation, to maintain uniform gain
        dt = time.time() - t0
        # loop over all error signals
        for i in range(len(errors)):
            # get error signal value
            errsig = e[errors[i]]
            # compute new position and apply it
            e[actuators[i]] = e[actuators[i]] + gains[i] * dt * errsig
            # running average on error signal value
            average_err[i] = (1 - 1./T) * average_err[i] + 1./T * e[errors[i]]*errsig
        t0 = time.time()
        # compute new maximum value of error signal
        max_err = max(abs(average_err))
        # wait a little bit
        time.sleep(0.01)

  
    # Turn off centering
    print 'Switching off REFL WFS centering...'
      
    e.switch('ASC-DC1_P', 'INPUT', 'OFF')
    e.switch('ASC-DC1_Y', 'INPUT', 'OFF')
    e.switch('ASC-DC2_P', 'INPUT', 'OFF')
    e.switch('ASC-DC2_Y', 'INPUT', 'OFF')
  
