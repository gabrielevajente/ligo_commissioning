#!/usr/bin/env python
# above is a python "shebang" line needed for the script to be executed directly form the command line

import ezca
from numpy import *
from time import sleep
import time

e= ezca.Ezca()

#Here are the user-variable parameters
threshold= 2                    #max tolerabale value (avg) for the second loop output to initiate loop close.
loop_closed_threshold = .2      #max instantaneous value for second loop output to actually close the loop.
n = 5                           #number of seconds to average the seconfd loop output signal.
fs = 10                         #frequeny in hz at which the data is obtained from second loop output.

#this function will calculate the average of the second loop output for defined period.
def s_loop_out():
    s_loop_out=0
    for i in range(0,n*fs):
        s_loop_out=s_loop_out+e['PSL-ISS_SECONDLOOP_SIGNAL_OUTMON']
        sleep(1./fs)
    return s_loop_out/(n*fs)




#make sure the loop is open     
e['PSL-ISS_SECONDLOOP_CLOSED'] = 0
e['PSL-ISS_SECONDLOOP_BOOST_ON'] = -32000
e['PSL-ISS_SECONDLOOP_INT_ON'] = -32000


#select the photodiodes
e['PSL-ISS_SECONDLOOP_PD_SW'] = +32000


#switch additional gain to the loop
e['PSL-ISS_SECONDLOOP_ADD_GAIN'] = +32000


#move the loop gain to 0dB and turn servo on
e['PSL-ISS_SECONDLOOP_GAIN'] = 0 #loop_gain
e['PSL-ISS_SECONDLOOP_SERVO_ON'] = +32000  #serv_on

#calculates the in loop pd average for period defined in parameters
def in_loop_pd():
    in_loop_pd = 0
    for i in range(0,n*fs):
        in_loop_pd = in_loop_pd+e['PSL-ISS_SECONDLOOP_PD_14_SUM_INMON']
        sleep(1./fs)
    return in_loop_pd

avg = in_loop_pd()/(n*fs)


#sets the ref. signal value so that it is not too far away from the nominal value.  
e['PSL-ISS_SECONDLOOP_REF_SIGNAL_ANA'] = (avg*2.29*.0006103515625)+0.101
sleep(5)

#tune the ref level to move sec loop output signal to zero

second_loop = s_loop_out()

while abs(second_loop)> threshold:
    e['PSL-ISS_SECONDLOOP_REF_SIGNAL_ANA'] = e['PSL-ISS_SECONDLOOP_REF_SIGNAL_ANA']+ .002*second_loop
    sleep(6)
    second_loop = s_loop_out()

timeout = time.time()+.2*60

while abs(e['PSL-ISS_SECONDLOOP_SIGNAL_OUTMON'])> 0.5 and time.time()<timeout:
    sleep(1./16)
    pass

#close the second loop and wait 1 second
e['PSL-ISS_SECONDLOOP_CLOSED'] = 32000
sleep(1)

# recheck if the ref signal is tuned
if abs(e['PSL-ISS_SECONDLOOP_SIGNAL_OUTMON'])< loop_closed_threshold:

    #increase the gain to a maximum of +40dB
    e['PSL-ISS_SECONDLOOP_GAIN'] = 40

    #engage boost and integrator
    e['PSL-ISS_SECONDLOOP_BOOST_ON'] = +32000
    e['PSL-ISS_SECONDLOOP_INT_ON'] = +32000

# if the threshold is not met the loop will open.
else:
    e['PSL-ISS_SECONDLOOP_CLOSED'] = 0
