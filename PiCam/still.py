import time
import picamera

with picamera.PiCamera() as camera:
    camera.resolution = (1920, 1080)
    camera.start_preview()
    time.sleep(5)
    camera.capture('/home/pi/image.jpg')
    camera.stop_preview()
