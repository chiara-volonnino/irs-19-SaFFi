-- Put your global variables here

MOVE_STEPS = 50
n_steps = 0

robot_state = 0  -- 0 = find light, 1 = reached fire, 2 = following robot, 3 = fleeing from fire




--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	robot.leds.set_all_colors("black")
	robot.range_and_bearing.set_data(1, 1)
end

function step()
	movement_vector = {}
	if robot_state == 0 then
		if im_on_a_fire() then
		   log("Sono su un fuoco")
		   robot_state = 1
	   else
		   log("Devo raggiungere un fuoco")
		   log("Calcolo vettore movimento")
		   local vector = require "vector"
		   light_vector = read_light_sensors()
		   log("Light  Value   " .. light_vector.value)
		   log("Light   Angle   " .. light_vector.angle)
		   obstacle_vector = read_obstacle_sensors()
		   log("Obstacle  Value   " .. obstacle_vector.value)
		   log("Obstacle   Angle   " .. obstacle_vector.angle)
		   movement_vector = vector.vec2_polar_sum(light_vector, obstacle_vector)
			if movement_vector.lenght == 0 and movement_vector.angle == 0 then
				log("Wander")
				robot.wheels.set_velocities(10,10)
			else
				log("Go towards luce")
				velocities = get_wheel_velocities(movement_vector)
				robot.wheels.set_velocities(velocities.v1, velocities.v2)
			end
	   end
   end
end

function get_wheel_velocities(movement_vector)
    L = robot.wheels.axis_length
	v1 = movement_vector.lenght - L*(movement_vector.angle)/2
	v2 = movement_vector.lenght + L*(movement_vector.angle)/2
	velocities = {v1 = v1, v2 = v2 }
	return velocities
end


function im_on_a_fire()
	sensors_on_fire = 0
	for i = 1,4,1 do
		if robot.motor_ground[i].value == 0.69493725346584 then
			sensors_on_fire = sensor_on_fire + 1
		end
	end
	if sensors_on_fire >= 3 then
		return true
	else
		return false
	end
end

function read_light_sensors()
	max_light_sensor_value = 0
	max_light_sensor_angle = 0
	for i = 1,24,1 do
		if robot.light[i].value > max_light_sensor_value then
			max_light_sensor_value = robot.light[i].value
			max_light_sensor_angle = robot.light[i].angle
		end
	end
	light = {lenght = max_light_sensor_value, angle = max_light_sensor_angle}
	return light
end

function read_obstacle_sensors()
	max_prox_sensor_value = 0
	max_prox_sensor_angle = 0
	for i= 1,24,1 do
		if robot.proximity[i].value > max_prox_sensor_value then
			max_prox_sensor_value = robot.proximity[i].value
			max_prox_sensor_angle = robot.proximity[i].angle
		end
	end
	obstacle = {lenght = max_prox_sensor_value, angle = max_prox_sensor_angle }
	return obstacle
end

function reset()
	robot.wheels.set_velocity(0,0)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function destroy()
   -- put your code here
end