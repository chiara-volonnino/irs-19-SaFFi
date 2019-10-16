local vector = require "vector"

light_sensor = nil
motor_ground = nil

robot_state = 0  -- 0 = find light, 1 = reached fire, 2 = following robot, 3 = fleeing from fire

local v1 = {}
local v2 = {}

function init()
	L = robot.wheels.axis_length
	robot.leds.set_all_colors("black")
	robot.range_and_bearing.set_data(1, 1)
end

function reset()
	robot.leds.set_all_colors("black")
	robot.wheels.set_velocity(0,0)
end

function destroy()
   -- put your code here
end

function step()
	if robot_state == 0 then
		v1 = vector.vec2_polar_sum(wander(), follow_light())
		v2 = vector.vec2_polar_sum(v1, avoid_obstacle())
		wheels_l, wheels_r = trasformation_vector_to_velocity(v2)
		robot.wheels.set_velocity(wheels_l, wheels_r)
		if get_temperature_readings() then
			robot_state = 1
		else
			log("")
		end
	elseif robot_state == 1 then
		robot.wheels.set_velocity(0, 0)
	elseif robot_state == 2 then
		robot.wheels.set_velocity(0, 0)
		log("I'm dead")
	else 
		log("robot in state n")
	end
end

-------------- Controller functions --------------

function wander() 
	--log("Robot is in wander state")
	robot.range_and_bearing.set_data(1, 0)
	return {length = robot.random.uniform(5), angle = robot.random.uniform(-math.pi/4, math.pi/4)} -- TODO: settare il random value
end 

function follow_light()
	max_light_value = 0
	max_light_angle = 0
	for _, light_sensor in pairs(robot.light) do
		if light_sensor.value > max_light_value then 
			robot.leds.set_all_colors("yellow")
			max_light_value = light_sensor.value
			max_light_angle = light_sensor.angle
		end 
	end
	return {length = max_light_value * 10, angle = max_light_angle}
end

function avoid_obstacle()
	max_proximity_value = 0
	max_proximity_angle = 0
    v = {}
	for _, proximity_sensor in pairs(robot.proximity) do
		if proximity_sensor.value > max_proximity_value then
			max_proximity_value = proximity_sensor.value
			max_proximity_angle = proximity_sensor.angle
		end
	end
	return {length = max_proximity_value * 5, angle = max_proximity_angle + math.pi}
end

function stop_near_fire()
end

-------------- Extra functions --------------

function trasformation_vector_to_velocity(v)
	v_left = v.length - ((v.angle * L)/2)
	v_right = v.length + ((v.angle * L)/2)
  return v_left, v_right
end

function get_temperature_readings()
  medium_temp = 0
  for _, motor_ground in pairs(robot.motor_ground) do
	  if robot.motor_ground[_].value >= 0.2 and robot.motor_ground[_].value <= 0.7 then
		  robot.leds.set_all_colors("red")
		  medium_temp = medium_temp+1
	  end
  end
  if medium_temp >= 2 then
	  return true
  else
	  return false
  end
end

function countRAB()
	number_robot_sensed = 0
	for _, rab in ipairs(robot.range_and_bearing) do
		if rab.range < 30 and rab.data[1] == 1 then   
			number_robot_sensed = number_robot_sensed + 1
			--log("in :" .. number_robot_sensed)
		end
	end
	return number_robot_sensed
end 