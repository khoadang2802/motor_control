from motor_class import *
import time
from load_cell_class_avg import*
import io
import Phidget22


def init_motor(input_port, rescale_factor):
    try:
        print("init motor " + str(rescale_factor) + " " + str(input_port))
        stepper = motor(input_port, 620971, rescale_factor, 150)
        stepper.switch_init(1, 0)

        stepper.safe_home()
        target_0 = 0
        stepper.phidget.setTargetPosition(target_0)

        sensor = load_cell(0, 582968, -5057135.515175622, 10, 50)
        sensor.tare()
        control_motor(stepper, motor, input_port, sensor, rescale_factor)
    except Phidget22.PhidgetException.PhidgetException as e:
        print(e)
        print("Please enter hub number:")
        input_port = int(input())
        stepper = motor(input_port, 620971, rescale_factor, 150)
        stepper.switch_init(1, 0)

        stepper.safe_home()
        target_0 = 0
        stepper.phidget.setTargetPosition(target_0)

        sensor = load_cell(0, 582968, -5057135.515175622, 10, 50)
        sensor.tare()
        control_motor(stepper, motor, input_port, sensor, rescale_factor)


def control_motor(stepper, motor, input_port, sensor, rescale_factor):
    sys.stdout = open("recorded_data" + str(input_port) + ".txt","w")
    v = "Position"+' '+"Mass" +'\n';
    csv_content = "motor1_position,motor1_mass,motor2_position,motor2_mass,\
    motor3_position,motor3_mass,motor4_position,motor4_mass,motor5_position,motor5_mass\
    motor6_position,motor6_mass\n"
    print(v);
    try:
        while True:
            try:
                #print("position: ")
                user_in = input()
                if ("sensor " in user_in):
                    print(user_in)
                    input_port = int(user_in.split(" ")[len(user_in.split(" "))-1])
                    print(input_port)
                    print("init motor 0 " + str(rescale_factor) + " " + str(input_port))

                    stepper = motor(input_port, 620971, rescale_factor, 150)
                    print("init motor 1 " + str(rescale_factor))
                    stepper.switch_init(1, 3)
                    print("switch init 2")
                    # stepper.safe_home()
                else:
                    print("start moving")
                    target = float(user_in)
                    stepper.phidget.setTargetPosition(target)
                    time.sleep(2)
                    position = stepper.phidget.getPosition()
                    if input_port == 0:
                        csv_content += str(position) + "," + str(sensor.mass_filt) + "\n"
                    elif input_port == 1:
                        csv_content += ",,,," + str(position) + "," + str(sensor.mass_filt) + "\n"
                    elif input_port == 2:
                        csv_content += ",,,,," + str(position) + "," + str(sensor.mass_filt) + "\n"
                        print("end moving")
                    elif input_port == 3:
                        csv_content += ",,,,,," + str(position) + "," + str(sensor.mass_filt) + "\n"
                    elif input_port == 4:
                        csv_content += ",,,,,,," + str(position) + "," + str(sensor.mass_filt) + "\n"
                    else:
                        csv_content += ",,,,,,,," + str(position) + "," + str(sensor.mass_filt) + "\n"
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

    s = io.StringIO(csv_content)
    path = './recorded_data.csv'
    with open(path, 'w') as f:
        for line in s:
            f.write(line)
        f.close()

def main():
    rescale_factor = (1.8*5/360/16)
    init_motor(0, rescale_factor)

main()
