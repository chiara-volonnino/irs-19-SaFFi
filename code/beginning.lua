-- Put your global variables here

local vector = require "vector"

MOVE_STEPS = 50
n_steps = 0
steps_resolution = 5
robot_number = 0

wheel_speed_L = 0
wheel_speed_R = 0

light_sensor = nil
motor_ground = nil

robot_state = 0  -- 0 = find light, 1 = reached fire, 2 = following robot, 3 = fleeing from fire

local v1 = {}
local v2 = {}
--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	L = robot.wheels.axis_length
	robot.leds.set_all_colors("black")
	robot.range_and_bearing.set_data(1, 1)
end

function step()
	if robot_state == 0 then
		--robot.wheels.set_velocity(robot.random.uniform(10), robot.random.uniform(10))
		v1 = vector.vec2_polar_sum(wander(), see_light())
		v2 = vector.vec2_polar_sum(v1, see_obstacle())
		--log("sono qui, after trasformation! ")
		wheels_l, wheels_r = trasformation(v2.length, v2.angle)
		--log("sono qui, next trasformation " .. wheel_l.length)
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
	--robot_number = countRAB()	
	--log("range_and_bearing " .. robot_number)
end


function trasformation(v, w) -- TODO: metti a posto
	--if between(0, math.pi/2) then
	  v_left = v - ((w * L)/2)
	  v_right = v + ((w * L)/2)
	  --log("value return trasformation: " .. v_left, v_right)
	--else
	  --v_left = v + ((w * L)/2)
	  --v_right = v - ((w * L)/2) 
	  --log("value return trasformation: " .. v_left, v_right)
	--end
	--log("value return trasformation: " .. v_left, v_right)
	return v_left, v_right
  end

function get_temperature_readings()
	medium_temp = 0
	--high_temp = 0
	for _, motor_ground in pairs(robot.motor_ground) do
		if robot.motor_ground[_].value >= 0.2 and robot.motor_ground[_].value <= 0.7 then
			robot.leds.set_all_colors("red")
			medium_temp = medium_temp+1
		end
		--if robot.motor_ground[_].value == 0.29899998085172 then 
		--	high_temp = high_temp+1
		--end
	end
	log("temp " .. medium_temp)
	if medium_temp >= 2 then
		return true
	else
		return false
	end
end

function see_obstacle()
	max_proximity_value = 0
	max_proximity_angle = 0
    v = {}
	for _, proximity_sensor in pairs(robot.proximity) do
		if proximity_sensor.value > max_proximity_value then
			max_proximity_value = proximity_sensor.value
			max_proximity_angle = proximity_sensor.angle
		end
	end
	return {length = max_proximity_value, angle = max_proximity_angle}
end

function see_light()
	max_light_value = 0
	max_light_angle = 0
	for _, light_sensor in pairs(robot.light) do
		if light_sensor.value > max_light_value then 
			robot.leds.set_all_colors("yellow")
			max_light_value = light_sensor.value + 5
			max_light_angle = light_sensor.angle
		end 
	end
	return {length = max_light_value, angle = max_light_angle}
end

function wander() 
	--log("Robot is in wander state")
	robot.range_and_bearing.set_data(1, 0)
	return {length = 10, angle = robot.random.uniform(10)} -- TODO: settare il random value
end 

function follow_light()
	if not see_light() then
		wander()
		robot.leds.set_all_colors("black")
		if see_fire() then
			log("I SEE FIRE")
		end
	else 
		-- gestire follow the light secondo un modello definito
        
        
		log("follow the light")
		if see_fire() then
			log("I SEE FIRE")
		end
	end
end

function obstacles_avoid()
end

function stop_near_fire()
end





function countRAB()
	number_robot_sensed = 0
	-- for each robot seen
	for _, rab in ipairs(robot.range_and_bearing) do
		if rab.range < 30 and rab.data[1] == 1 then   
			number_robot_sensed = number_robot_sensed + 1
			--log("in :" .. number_robot_sensed)
		end
	end
	return number_robot_sensed
end 

function reset()
	robot.wheels.set_velocity(0,0)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function destroy()
   -- put your code here
end

