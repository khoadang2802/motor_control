from Phidget22.Phidget import *
from Phidget22.Devices.Stepper import *
from Phidget22.Devices.DigitalInput import *
import time

def switch_press(self, state):
	if state == True:
		self.linkedOutput.setEngaged(False) #Kills motor that hit the switch


class motor:
	switch = False
	phidget = False


	def __init__(self, port, serial, rescale = 1, vel_lim = False):
		#Initialize Motors
		self.phidget = Stepper()
		stepper = self.phidget

		stepper.setDeviceSerialNumber(serial)
		stepper.setHubPort(port)

		stepper.openWaitForAttachment(5000)
		stepper.setRescaleFactor(rescale)
		if vel_lim is not False:
			stepper.setVelocityLimit(vel_lim) #m/s

		stepper.setEngaged(True) # Turns on power to motor

	def switch_init(self, port, channel):
		self.switch = DigitalInput()
		self.switch.setHubPort(port)
		self.switch.setChannel(channel)
		self.switch.linkedOutput = self.phidget
		self.switch.setOnStateChangeHandler(switch_press)
		self.switch.openWaitForAttachment(5000)
		time.sleep(1)

	def home(self, target_initial = 1000000):
		if self.switch is False:
			raise Exception("The switch is not connected or intialized")
			return

		stepper = self.phidget

		stepper.setTargetPosition(target_initial) # Tells the motor to just start moving until it hits the switch

		while self.switch.getState() == False:
			pass

		time.sleep(.5) # We have to put a pause here because there is some weird sampling rate stuff going on
		stepper.addPositionOffset( - stepper.getPosition())
		stepper.setEngaged(True)


	def safe_home(self, target_initial = 1000000):
		if self.switch is False:
			raise Exception("The switch is not connected or intialized")

		stepper = self.phidget

		print("Press Switch to Continue")
		while self.switch.getState() == False:
			pass

		print("Hey it worked!")
		time.sleep(.5)

		stepper.setEngaged(True)
		stepper.setTargetPosition(target_initial) # Tells the motor to just start moving until it hits the switch

		while self.switch.getState() == False:
			pass

		time.sleep(.5) # We have to put a pause here because there is some weird sampling rate stuff going on
		stepper.addPositionOffset( - stepper.getPosition())
		stepper.setEngaged(True)

	def __del__(self):

		if self.switch is not False:
			self.switch.close()

		self.phidget.close()
