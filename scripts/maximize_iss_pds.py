import ezca
from time import sleep
from numpy import *

e = ezca.Ezca()

def pdsum(n):
    pd = 0
    for i in range(n):
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD1_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD2_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD3_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD4_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD5_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD6_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD7_OUTPUT')
        pd = pd + e.read('PSL-ISS_SECONDLOOP_PD8_OUTPUT')
    pd = -pd / n
    return pd

   
def measureGradientPico1():
    N = 1000
    gr = zeros(2)

    print 'Measuring gradient pico 1:'

    # measure initial power
    pd0 = pdsum(N)
    print '  P0 = ', pd0
    # select motor 1
    e.write('SYS-MOTION_C_PICO_B_SELECTEDMOTOR', 1)
    sleep(5)
    # move to the right 
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 4)
    sleep(3)
    # measure again power
    pd1 = pdsum(N)
    print '  P1 = ', pd1
    # first value of the gradient
    gr[0] = pd1 - pd0
    # move back
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 3)
    sleep(3)

    # measure initial power
    pd0 = pdsum(N)
    print '  P0 = ', pd0
    # move up
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 1)
    sleep(3)
    # measure again power
    pd1 = pdsum(N)
    print '  P1 = ', pd1
    # first value of the gradient
    gr[1] = pd1 - pd0
    # move back
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 2)
    sleep(3)

    return gr

def measureGradientPico8():
    N = 1000
    gr = zeros(2)

    print 'Measuring gradient pico 8:'

    # measure initial power
    pd0 = pdsum(N)
    print '  P0 = ', pd0
    # select motor 8
    e.write('SYS-MOTION_C_PICO_B_SELECTEDMOTOR', 8)
    sleep(5)
    # move to the right 
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 4)
    sleep(3)
    # measure again power
    pd1 = pdsum(N)
    print '  P1 = ', pd1
    # first value of the gradient
    gr[0] = pd1 - pd0
    # move back
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 3)
    sleep(1.5)

    # measure initial power
    pd0 = pdsum(N)
    print '  P0 = ', pd0
    # move up
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 1)
    sleep(3)
    # measure again power
    pd1 = pdsum(N)
    print '  P1 = ', pd1
    # first value of the gradient
    gr[1] = pd1 - pd0
    # move back
    e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 2)
    sleep(3)

    return gr

def measureGradient():
    gr1 = measureGradientPico1();
    sleep(1)
    gr2 = measureGradientPico8();
    return concatenate([gr1,gr2])

def maximizePower(nstep = 5, niter = 100):
    for i in range(niter):
        print 'Iteration ', i+1
        g = measureGradient()
        print '  Gradient', g
        g = around(g / max(abs(g)) * nstep)
        print '  Motion', g
    
        if g[0] > 0:
            e.write('SYS-MOTION_C_PICO_B_SELECTEDMOTOR', 1)
            sleep(5)
            for j in range(int(abs(g[0]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 4)
                sleep(3)
        else:
            e.write('SYS-MOTION_C_PICO_B_SELECTEDMOTOR', 1)
            sleep(5)
            for j in range(int(abs(g[0]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 3)
                sleep(3)
                 
        if g[1] > 0:
            for j in range(int(abs(g[1]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 1)
                sleep(3)
        else:
            for j in range(int(abs(g[1]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 2)

        if g[2] > 0:
            e.write('SYS-MOTION_C_PICO_B_SELECTEDMOTOR', 8)
            sleep(5)
            for j in range(int(abs(g[2]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 4)
                sleep(3)
        else:
            e.write('SYS-MOTION_C_PICO_B_SELECTEDMOTOR', 8)
            sleep(5)
            for j in range(int(abs(g[2]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 3)
                sleep(3)
                 
        if g[3] > 0:
            for j in range(int(abs(g[3]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 1)
                sleep(3)
        else:
            for j in range(int(abs(g[3]))):
                e.write('SYS-MOTION_C_PICO_B_CURRENT_DRIVE', 2)
