#!/usr/bin/env python
# above is a python "shebang" line needed for the script to be executed directly form the command line

import ezca
from numpy import *
from time import sleep

e= ezca.Ezca()

# switch off the boost and the integrator
e['PSL-ISS_SECONDLOOP_BOOST_ON'] = -32000
e['PSL-ISS_SECONDLOOP_INT_ON'] = -32000


#move the loop gain to 0dB
e['PSL-ISS_SECONDLOOP_GAIN'] = 0 #loop_gain

#close the second loop input to the first loop     
e['PSL-ISS_SECONDLOOP_CLOSED'] = 0
