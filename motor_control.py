from initialize_motors import*
import time

def main():
	rescale_factor = (1.8*5/360/16)
	stepper = motor_init(0, 620982, rescale_factor, 150)
	# channel, serial number, rescale factor, velocity of motor
	switch = switch_init(1, 0, stepper)
	#port from hub, port from input phidget, stepper

	home_motors(stepper, switch)
	target_0 = -50
	stepper.setTargetPosition(target_0)

	try:
		while True:
				try:
					user_in = input("Distance to Move: ")
					target = float(user_in)


					stepper.setTargetPosition(target + target_0)
				except ValueError:
					print("This needs to be a number!")

	except KeyboardInterrupt:
		print("\n--User Termination--")

	stepper.close()
	switch.close()

main()
