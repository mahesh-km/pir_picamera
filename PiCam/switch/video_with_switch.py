import time
import picamera
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.IN, GPIO.PUD_UP)

with picamera.PiCamera() as camera:
    camera.start_preview()
    GPIO.wait_for_edge(17, GPIO.FALLING)
    camera.start_recording('/home/pi/video.h264')
    time.sleep(1)
    GPIO.wait_for_edge(17, GPIO.FALLING)
    camera.stop_recording()
    camera.stop_preview()
