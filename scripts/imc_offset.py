#!/usr/bin/python

import ezca
import time

e = ezca.Ezca()

for off in range(-10,11):
    e['IMC-REFL_SERVO_COMOFS'] = off
    time.sleep(30)
