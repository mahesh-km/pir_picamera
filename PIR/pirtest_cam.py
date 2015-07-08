#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import picamera

sensorPin = 7

GPIO.setmode(GPIO.BOARD)
GPIO.setup(sensorPin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

prevState = False
currState = False

cam = picamera.PiCamera()

while True:
    time.sleep(0.1)
    prevState = currState
    currState = GPIO.input(sensorPin)
    print currState
    print prevState
    if currState != prevState:
        newState = "HIGH" if currState else "LOW"
        print "GPIO pin %s is %s" % (sensorPin, newState)
        if currState:
            cam.start_preview()
        else:
            cam.stop_preview()
