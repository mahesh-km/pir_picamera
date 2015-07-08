#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import picamera
import datetime

sensorPin = 7

GPIO.setmode(GPIO.BOARD)
GPIO.setup(sensorPin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

def getFileName():    
    return datetime.datetime.now().strftime("/home/pi/Images/%Y-%m-%d_%H.%M.%S.jpg")

revState = False
currState = False

cam = picamera.PiCamera()

while True:
    time.sleep(0.1)
    prevState = currState
    currState = GPIO.input(sensorPin)
    print currState
    print prevState
    if currState == 1 and prevState != 1:
       print "GPIO pin %s is %s" % (sensorPin, currState)
       cam.start_preview()
       cam.capture(getFileName())
    elif currState == 0:
       cam.stop_preview()
