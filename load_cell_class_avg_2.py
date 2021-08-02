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



class load_cell_2:
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
