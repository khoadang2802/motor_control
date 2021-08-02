# These set of functions are supposed to provide two sets of tools
# 1) We have included a function to initilize a motor:
	# The user needs to provide the vint hub port, and the serial number of the stepper phidget
	# The user then has the option of providing a scaling factor for the motor inputs and an option to set the max velocity of the motor

# 2) These functions are setup to also allow a user to attach a limit/kill switch to a motor
	#To make a switch, the user just has to provide the vint hub port, the channel on the DI phidget, and the object of the stepper motor you want to attach to it

# 3) Lastly, a function to home a motor is provided. It will move the motor until it collides with the switch, thus setting that as the zero position
	# Please note: you need to check to make sure that your initial target actually moves the motor towards the limit switch. Otherwise it will run away forever.




from Phidget22.Phidget import *
from Phidget22.Devices.Stepper import *
from Phidget22.Devices.DigitalInput import *
import time

def switch_press(self, state):
	if state == True:
		self.linkedOutput.setEngaged(False) #Kills motor that hit the switch

def switch_init(port, channel, stepper):
	switch = DigitalInput()
	switch.setHubPort(port)
	switch.setChannel(channel)
	switch.linkedOutput = stepper
	switch.setOnStateChangeHandler(switch_press)
	switch.openWaitForAttachment(5000)
	time.sleep(1)
	return switch

def motor_init(port, serial, rescale = 1, vel_lim = False):
	#Initialize Motors
	stepper = Stepper()
	stepper.setDeviceSerialNumber(serial)
	stepper.setHubPort(port)

	stepper.openWaitForAttachment(5000)
	stepper.setRescaleFactor(rescale)
	if vel_lim is not False:
		stepper.setVelocityLimit(vel_lim) #m/s

	stepper.setEngaged(True) # Turns on power to motor

	return stepper

def home_motors(stepper, switch, target_initial = 1000000):
	stepper.setTargetPosition(target_initial) # Tells the motor to just start moving until it hits the switch

	while switch.getState() == False:
		pass

	time.sleep(.5) # We have to put a pause here because there is some weird sampling rate stuff going on
	stepper.addPositionOffset( - stepper.getPosition())
	stepper.setEngaged(True)
