import ezca
from numpy import *
from pylab import *
from time import sleep

e = ezca.Ezca()


def center_imc_wfs():
    cont = True
    while cont:
        sleep_time = 2
        again = 200
        bgain = 200
        threshold = 0.05
        im4_pow = 1500
        cont = False

        e['SYS-MOTION_C_PICO_D_SELECTEDMOTOR'] = 5
        sleep(sleep_time)
        x = e['IMC-WFS_A_DC_YAW_OUTMON']
        p = e['IMC-IM4_TRANS_SUM_OUTMON']
        if x > threshold and p > imc_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(x)*again)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 4
            cont = True
        if x < -threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(x)*again)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 3
            cont = True
        sleep(sleep_time)

        y = e['IMC-WFS_A_DC_PIT_OUTMON']
        p = e['IMC-IM4_TRANS_SUM_OUTMON']
        if y > threshold  and p > imc_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(y)*again)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 2
            cont = True
        if y < -threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(y)*again)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 1
            cont = True
        sleep(sleep_time)

        e['SYS-MOTION_C_PICO_D_SELECTEDMOTOR'] = 6
        sleep(sleep_time)
        x = e['IMC-WFS_B_DC_YAW_OUTMON']
        p = e['IMC-IM4_TRANS_SUM_OUTMON']
        if x > threshold and p > imc_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(x)*bgain)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 4
            cont = True
        if x < -threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(x)*bgain)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 3
            cont = True
        sleep(sleep_time)

        y = e['IMC-WFS_B_DC_PIT_OUTMON']
        p = e['IMC-IM4_TRANS_SUM_OUTMON']
        if y > threshold  and p > imc_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(y)*bgain)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 2
            cont = True
        if y < -threshold and p > qpd_pow:
            e['SYS-MOTION_C_PICO_D_CURRENT_STEPSIZE'] = int(abs(y)*bgain)
            e['SYS-MOTION_C_PICO_D_MOTOR_1_DRIVE'] = 1
            cont = True
        sleep(sleep_time)
