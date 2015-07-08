import picamera

with picamera.PiCamera() as camera:
    camera.resolution = (1920, 1080)
    camera.start_preview()
    camera.start_recording('video1.h264')
    camera.wait_recording(20)
    camera.stop_recording()

