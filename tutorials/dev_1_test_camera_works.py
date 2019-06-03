#!/usr/bin/env python

import donkeycar as dk
import donkeycar.parts.camera as dk_cam
import donkeycar.parts.datastore as dk_ds
import spylunking.log.setup_logging as log_utils

log = log_utils.build_colorized_logger(
    name='test-camera-works-on-a-vm',
    handler_name='no_date_colors')


# initialize the vehicle
log.info(
    '1 - creating donkey car vehicle')
V = dk.Vehicle()

# add a camera part
log.info(
    '2 - creating donkey car camera')

# the PiCamera requires the rasberry pi camera pip: picamera installed
# which does not work on other operating systems and will result in errors
# like:
# from ubuntu: $ pip install picamera
# ValueError: Unable to determine if this system is a Raspberry Pi
# cam = dk_cam.PiCamera()
cam = dk_cam.Webcam()

log.info(
    '3 - adding donkey car camera to vehicle')
V.add(cam, outputs=['image'], threaded=True)

# add tub part to record images
log.info(
    '4 - creating donkey car tub')
tub = dk_ds.Tub(
    path='~/mycar/gettings_started',
    inputs=['image'],
    types=['image_array'])
log.info(
    '5 - adding donkey car tub to vehicle')
V.add(tub, inputs=['image'])

# start the vehicle's drive loop
V.start(max_loop_count=100)
