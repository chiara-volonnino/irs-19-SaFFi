local vector = require "vector"

local SEARCH_FIRE, ATTEMPT_NEIGHBOURS, DEAL_FIRE = 0, 1, 2

local light_sensor, motor_ground = nil, nil
local robot_state = 0

local drift_vector, behaviors_vector, comunication_vector = {}, {}, {}

function init()
	L = robot.wheels.axis_length
	robot.leds.set_all_colors("black")
end

function reset()
	robot.leds.set_all_colors("black")
	robot.wheels.set_velocity(0,0)
end

function destroy()
   -- put your code here
end

function step()
	if robot_state == SEARCH_FIRE then            
		drift_vector = vector.vec2_polar_sum(wander(), avoid_obstacle())
        comunication_vector = read_range_and_bearing()
        if comunication_vector.length ~= 0 then
            behaviors_vector = vector.vec2_polar_sum(drift_vector, comunication_vector)
            wheels_l, wheels_r = trasformation_vector_to_velocity(v3)
            robot.leds.set_all_colors("white")
        else
            behaviors_vector = vector.vec2_polar_sum(drift_vector, follow_light())
            wheels_l, wheels_r = trasformation_vector_to_velocity(behaviors_vector)
            robot.leds.set_all_colors("yellow")
        end
		robot.wheels.set_velocity(wheels_l, wheels_r)
		if get_temperature_readings() then
            robot.leds.set_all_colors("red")
			robot_state = ATTEMPT_NEIGHBOURS
		end
	elseif robot_state == ATTEMPT_NEIGHBOURS then
        write_range_and_bearing(3,1)
		robot.wheels.set_velocity(0, 0)
        if check_antenna() then
            robot.leds.set_all_colors("green")
            robot_state = DEAL_FIRE
        end
	elseif robot_state == DEAL_FIRE then
        write_range_and_bearing(4,50)
		robot.wheels.set_velocity(0, 0)
	end
end

-------------- Controller functions --------------

function wander() 
	return {
        length = robot.random.uniform(2), 
        angle = robot.random.uniform(-math.pi/4, math.pi/4)
    }
end 

function follow_light()
	max_light_value, max_light_angle = 0, 0
	for _, light_sensor in pairs(robot.light) do
		if light_sensor.value > max_light_value then 
			max_light_value = light_sensor.value
			max_light_angle = light_sensor.angle
		end 
	end
	return {
        length = (1 - max_light_value) * 3, 
        angle = max_light_angle
    }
end

function avoid_obstacle()
	max_proximity_value = 0
	max_proximity_angle = 0
	for _, proximity_sensor in pairs(robot.proximity) do
		if proximity_sensor.value > max_proximity_value then
			max_proximity_value = proximity_sensor.value
			max_proximity_angle = proximity_sensor.angle
		end
	end
    v1 = {
        length = max_proximity_value * 6, 
        angle = max_proximity_angle + math.pi
    }
    v2 = {
        length = max_proximity_value * 2, 
        angle = max_proximity_angle - math.pi/2
    }
	return vector.vec2_polar_sum(v1,v2)
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
		  medium_temp = medium_temp+1
	  end
  end
  if medium_temp == 4 then
	  return true
  else
	  return false
  end
end

function read_range_and_bearing()
    closest_rab = nil
    min_range = 1000
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[4] == 50 and rab.range < min_range then
            closest_rab = rab
            min_range = rab.range
        end
    end
    if closest_rab ~= nil then
        return {length = 9, angle = closest_rab.horizontal_bearing+(math.pi)}
    else
        return  {length = 0, angle = 0}
    end
end

function write_range_and_bearing(i,n)
    robot.range_and_bearing.set_data(i,n)
end

function check_antenna()
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[6] == 1 then
            return true
        end
    end
    return false
end
