import ezca
from numpy import *
from pylab import *
from time import sleep

e = ezca.Ezca()


def zero_qpd():
    cont = True
    while cont:
        sleep_time = 2
        gain = 500
        threshold = 0.1
        qpd_pow = 1500
        cont = False
        e['SYS-MOTION_C_PICO_B_SELECTEDMOTOR'] = 1
        sleep(sleep_time)
        x = e['PSL-ISS_SECONDLOOP_QPD_PIT_INMON']
        p = e['PSL-ISS_SECONDLOOP_QPD_SUM_OUTMON']
        if x > threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_B_CURRENT_STEPSIZE'] = int(abs(x)*gain)
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 4
            cont = True
        if x < -threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_B_CURRENT_STEPSIZE'] = int(abs(x)*gain)
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 3
            cont = True
        sleep(sleep_time)

        y = e['PSL-ISS_SECONDLOOP_QPD_YAW_INMON']
        p = e['PSL-ISS_SECONDLOOP_QPD_SUM_OUTMON']
        if y > threshold  and p > qpd_pow:
            e['SYS-MOTION_C_PICO_B_CURRENT_STEPSIZE'] = int(abs(y)*gain)
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 2
            cont = True
        if y < -threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_B_CURRENT_STEPSIZE'] = int(abs(y)*gain)
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 1
            cont = True
        sleep(sleep_time)
