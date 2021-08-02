from Phidget22.Phidget import *
from load_cell_class_avg import *
import numpy as np
import time
from os import system


#------------------------------------------------------------------------------------------------------------------------------------------------------------

def main():
	# np.set_printoptions(suppress = True)

	sensor = load_cell(0, 582968, -5057135.515175622, 10, 50)
	sensor.tare()
	sensor.display = True

	try:
		while True:
			pass
			# _ = system('cls')
			# print("Mass: " + str(round(sensor.mass, 3)) + " g" + "     AvgMass: " +  str(round(sensor.mass_filt, 3)) + " g")

			# print("Force: " + str(round(sensor.mass*9.81/1000, 3)) + " N" + "     AvgForce: " +  str(round(sensor.mass_filt*9.81/1000, 3)) + " N")
			# print("Force: " + str(round((sensor.mass)*9.81/1000, 3)))


	except KeyboardInterrupt:
		print("\n--User Termination--")

	sensor.phidget.close()


main()
