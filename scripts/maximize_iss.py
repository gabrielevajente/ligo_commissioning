import ezca
from numpy import *
from pylab import *
from time import sleep

e = ezca.Ezca()


def total_pow():
    p = 0
    for i in range(8):
        p = p + e['IOP-PSL0_MADC1_EPICS_CH%d'%(24+i)]
    return -p

def average_power(N):
    p = 0
    for i in range(N):
        p = p + total_pow()
    return p/N

def find_maximum():

    npts = 200
    p = zeros(npts)
    e['SYS-MOTION_C_PICO_B_CURRENT_STEPSIZE'] = 100
    
    while True:
        
        #### pico 1, y
        p[0:-1] = p[1:]
        p0 = average_power(10000)
        print p0
        p[-1] = p0
        clf()
        plot(p)
        show()
        draw()
        # first move in +Y
        direction = 1
        e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = direction
        sleep(3)
        p[0:-1] = p[1:]
        p1 = average_power(10000)
        print p1
        p[-1] = p1
        clf()
        plot(p)
        show()
        draw()
        # if power is lower, reverse direction
        if p1 < p0:
            direction = 2
        # continue as long as power gets larger
        while p1 >= p0:
            p0 = p1
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = direction
            sleep(3)
            p[0:-1] = p[1:]
            p1 = average_power(10000)
            print p1
            p[-1] = p1
            clf()
            plot(p)
            show()
            draw()
        # the last step was always wrong, reverse it
        if direction == 1:
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 2
        else:
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 1
        sleep(3)


        #### pico 8, y
        p[0:-1] = p[1:]
        p0 = average_power(10000)
        print p0
        p[-1] = p0
        clf()
        plot(p)
        show()
        draw()
        # first move in +Y
        direction = 1
        e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = direction
        sleep(3)
        p[0:-1] = p[1:]
        p1 = average_power(10000)
        print p1
        p[-1] = p1
        clf()
        plot(p)
        show()
        draw()
        # if power is lower, reverse direction
        if p1 < p0:
            direction = 2
        # continue as long as power gets larger
        while p1 >= p0:
            p0 = p1
            e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = direction
            sleep(3)
            p[0:-1] = p[1:]
            p1 = average_power(10000)
            print p1
            p[-1] = p1
            clf()
            plot(p)
            show()
            draw()
        # the last step was always wrong, reverse it
        if direction == 1:
            e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = 2
        else:
            e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = 1
        sleep(3)

        #### pico 1, x
        p[0:-1] = p[1:]
        p0 = average_power(10000)
        print p0
        p[-1] = p0
        clf()
        plot(p)
        show()
        draw()
        # first move in +Y
        direction = 3
        e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = direction
        sleep(3)
        p[0:-1] = p[1:]
        p1 = average_power(10000)
        print p1
        p[-1] = p1
        clf()
        plot(p)
        show()
        draw()
        # if power is lower, reverse direction
        if p1 < p0:
            direction = 4
        # continue as long as power gets larger
        while p1 >= p0:
            p0 = p1
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = direction
            sleep(3)
            p[0:-1] = p[1:]
            p1 = average_power(10000)
            print p1
            p[-1] = p1
            clf()
            plot(p)
            show()
            draw()
        # the last step was always wrong, reverse it
        if direction == 3:
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 4
        else:
            e['SYS-MOTION_C_PICO_B_MOTOR_1_DRIVE'] = 3
        sleep(3)


        #### pico 8, x
        p[0:-1] = p[1:]
        p0 = average_power(10000)
        print p0
        p[-1] = p0
        clf()
        plot(p)
        show()
        draw()
        # first move in +Y
        direction = 3
        e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = direction
        sleep(3)
        p[0:-1] = p[1:]
        p1 = average_power(10000)
        print p1
        p[-1] = p1
        clf()
        plot(p)
        show()
        draw()
        # if power is lower, reverse direction
        if p1 < p0:
            direction = 4
        # continue as long as power gets larger
        while p1 >= p0:
            p0 = p1
            e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = direction
            sleep(3)
            p[0:-1] = p[1:]
            p1 = average_power(10000)
            print p1
            p[-1] = p1
            clf()
            plot(p)
            show()
            draw()
        # the last step was always wrong, reverse it
        if direction == 3:
            e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = 4
        else:
            e['SYS-MOTION_C_PICO_B_MOTOR_8_DRIVE'] = 3
        sleep(3)
