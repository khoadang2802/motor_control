# in this file contains functions necessary to run a load cell using the phidget bridge.
# We have 4 main variables in this class.
# mass - the recorded mass from the prior reading.
# load_ratio - the slope that relates the voltage ratio to a measurement of mass
# offset - the inital tare value for the load cell
# phidget - this is the pointer to the voltageRatio object for controlling the phidget bridge

# The secondary variables
# mass_filt - the mass value that has been filtered with a rolling average.
# window_size - how many data points will be averaged
# display - if true it displays the current mass reading
# time_diff - this is how long the program should wait between printing results

# this code contains 3 functions
# First two are methods of the load cell class
# tare() - which you call and wait 1 second and it tares everything for you
# constructor - this initializes the phidget_bridge_object. The necessary inputs to this are
# the channel the load cell is conected to, the serial number of the phidget bridge, and the load ratio.
# optional inputs are sampling frequency, the window_size, the offset if you know it, and you can choose to display the measurements or not
# you can sort of think of displaying as it's own function if you want. To activate it you just set load_cell = true

# The final function in this code is not part of the load_cell class. It is actually executed in the phidget object. The get_reading function is what code executes
# when the sensor gets a new reading. This exectues in another thread, hence thew weird "linkedOuput" stuff. You never need to actualy call get_reading.

from Phidget22.Devices.VoltageRatioInput import *
from os import system
import time
import numpy as np
def get_reading(self, voltageRatio):
	lc = self.linkedOutput
	lc.mass = lc.load_ratio*voltageRatio + lc.offset

	lc.window[lc.k] = lc.mass
	lc.mass_filt = np.sum(lc.window) / lc.window_size

	lc.k += 1
	if (lc.k >= lc.window_size):
		lc.k = 0


	if lc.display and (time.time() - lc.display_time) > lc.time_diff:
		lc.display_time = time.time()
		_ = system('cls')
		print("Mass: " + str(round(lc.mass, 1)) + " g" + "     Avg Mass: " +  str(round(lc.mass_filt, 1)) + " g")
		#print("Force: " + str(round(lc.mass*9.81/1000, 3)) + " N" + "     AvgForce: " +  str(round(lc.mass_filt*9.81/1000, 3)) + " N")
class load_cell:
	mass = 0
	load_ratio = 0 # Grams/Volt
	offset = 0
	phidget = 0
	display = False
	display_time = time.time()
	time_diff = 500/1000 # This is the display rate in seconds

	mass_filt = 0
	window = []
	window_size = 0
	k = 0

	def __init__(self, channel, serial, load_ratio, sampling_frequency = 100, window_size = 1, offset = 0, display = False):
		self.load_ratio = load_ratio
		self.window_size = window_size
		self.window = [0]*self.window_size

		self.phidget = VoltageRatioInput()
		self.phidget.setDeviceSerialNumber(serial)
		self.phidget.setChannel(channel)
		self.phidget.setOnVoltageRatioChangeHandler(get_reading)
		self.phidget.linkedOutput = self
		self.phidget.openWaitForAttachment(5000)
		self.phidget.setDataInterval(sampling_frequency)
		#self.phidget.setVoltageRatioChangeTrigger(0)
		np.set_printoptions(suppress = True)




	def tare(self):
		time.sleep(1)
		self.offset = -self.mass_filt
