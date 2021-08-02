from motor_class import *
import time
from load_cell_class_avg import*


def main():
	rescale_factor = (1.8*5/360/16)
	stepper = motor(0, 620971, rescale_factor, 150)
	stepper.switch_init(1, 0)

	stepper.safe_home()
	target_0 = 0
	stepper.phidget.setTargetPosition(target_0)

	sensor = load_cell(0, 582968, -5057135.515175622, 10, 50)
	input("press enter to tare")
	sensor.tare()

	sys.stdout = open("recorded_data.txt","w")
	v = "Position"+' '+"Mass" +'\n';
	print(v);
	try:
		while True:
				try:
					user_in = input()
					target = float(user_in)
					stepper.phidget.setTargetPosition(target + target_0)
					time.sleep(2)
					position = stepper.phidget.getPosition()
					x = int(input())
					if x == 1:
						s = str(position) +'  '+ str(sensor.mass_filt) +'\n';
						print(s)
					#x = int(input())
						#if x == 1:
							#print(s);


				except ValueError:
					print("This needs to be a number!")
				#x = int(input())
				#if x == 1:
					#print(s);
	except KeyboardInterrupt:
		print("\n--User Termination--")

	del stepper
	sys.stdout.close()
main()
