local vector = require "vector"

local SEARCH_FIRE, ATTEMPT_NEIGHBOURS, DEAL_FIRE = 0, 1, 2
local GREEN_LED, RED_LED, BLACK_LED = "green", "red", "black"
local ROBOT_PRESENCE, ANTENNA_FIELD, ROBOT_FIELD, ANTENNA_COMUNICATION = 1, 2, 3, 4
local MIN_WHEELS, MAX_WHEELS = 1, 10
local LOW_RANGE = 60
local ATTRACT_WRITER, REPULSE_WRITER = 1, 2 
local MAX_MOTOR_GROUND_SENSOR = 4
local VERY_LOW_POWER, LOW_POWER, MEDIUM_POWER, HIGH_POWER, VERY_HIGH_POWER = 2, 3, 4, 6, 10
local FIRE_GROUND, TEMPERATURE_GROUND = 0.2, 0.7

-- CONSTANTI MOLTIPLICATIVE
local motor_ground = nil
local robot_state = 0
local drift_vector, constrol_vector, behaviours_vector = {}, {}, {}

function init()
	distance_between_2_wheels = robot.wheels.axis_length
	robot.leds.set_all_colors(BLACK_LED)
end

function reset()
	robot.leds.set_all_colors(BLACK_LED)
	robot.wheels.set_velocity(0,0)
end

function destroy()
   -- put your code here
end

function step()
	if robot_state == SEARCH_FIRE then            
		drift_vector = vector.vec2_polar_sum(wander(), avoid_obstacle())
        constrol_vector = vector.vec2_polar_sum(listen_neighbors_for_help(), find_fire_field_behaviours())
        behaviours_vector = vector.vec2_polar_sum(drift_vector, constrol_vector)
        wheels_l, wheels_r = trasformation_vector_to_velocity(behaviours_vector)
		robot.wheels.set_velocity(wheels_normalization(wheels_l), wheels_normalization(wheels_r))
		if get_temperature_readings() then
            robot.leds.set_all_colors(RED_LED)
			robot_state = ATTEMPT_NEIGHBOURS
		end
	elseif robot_state == ATTEMPT_NEIGHBOURS then
        write_range_and_bearing(ROBOT_PRESENCE, ATTRACT_WRITER)
        write_range_and_bearing(ROBOT_FIELD, ATTRACT_WRITER)
		robot.wheels.set_velocity(0, 0)
        if check_antenna() then
            robot.leds.set_all_colors(GREEN_LED)
            robot_state = DEAL_FIRE
        end
    elseif robot_state == DEAL_FIRE then
        write_range_and_bearing(ROBOT_FIELD, REPULSE_WRITER)
		robot.wheels.set_velocity(0, 0)
	else 
		--log("robot in state n")
	end
end

-------------- Controller functions --------------
function wander() 
	return {
        length = robot.random.uniform(5), 
        angle = robot.random.uniform(-math.pi/4, math.pi/4)
    }
end 

function avoid_obstacle()
	max_proximity_value, max_proximity_angle = 0, 0
	for _, proximity_sensor in pairs(robot.proximity) do
		if proximity_sensor.value > max_proximity_value then
			max_proximity_value = proximity_sensor.value
			max_proximity_angle = proximity_sensor.angle
		end
	end
    v1 = {
        length = max_proximity_value * HIGH_POWER, 
        angle = max_proximity_angle + math.pi
    }
    v2 = {
        length = max_proximity_value * LOW_POWER, 
        angle = max_proximity_angle + math.pi/2
    }
	return vector.vec2_polar_sum(v1,v2)
end    

function listen_neighbors_for_help()
    neighbors_result = check_neighbors(ROBOT_FIELD)
    if not check_antenna() and neighbors_result.attract_field then
        return {
            length = range_and_bearing_normaliation(neighbors_result.rab.range) * VERY_LOW_POWER,  
            angle = neighbors_result.rab.horizontal_bearing
        }
    elseif check_antenna() and repulse then
        return {
            length = range_and_bearing_normaliation(neighbors_result.rab.range) * MEDIUM_POWER,  
            angle = neighbors_result.rab.horizontal_bearing - math.pi
        }
    else
        return {
            length = 0,  
            angle = 0
        }
    end
end 

-------------- Extra functions --------------
function trasformation_vector_to_velocity(v)
	v_left = v.length - ((v.angle * distance_between_2_wheels)/2)
	v_right = v.length + ((v.angle * distance_between_2_wheels)/2)
  return v_left, v_right
end

function get_temperature_readings()
  motor_ground_number = 0
  for _, motor_ground in pairs(robot.motor_ground) do
	  if robot.motor_ground[_].value >= FIRE_GROUND and robot.motor_ground[_].value <= TEMPERATURE_GROUND then
        motor_ground_number = motor_ground_number + 1
	  end
  end
  if motor_ground_number == MAX_MOTOR_GROUND_SENSOR then
	  return true
  else
	  return false
  end
end

function find_fire_field_behaviours()  
    neighbors_result = check_neighbors(ANTENNA_FIELD)
    if neighbors_result.attract_field and neighbors_result.rab.range < LOW_RANGE then
        return {
            length = range_and_bearing_normaliation(neighbors_result.rab.range) * VERY_LOW_POWER,  
            angle = neighbors_result.rab.horizontal_bearing        }
    elseif neighbors_result.attract_field then
        return {
            length = range_and_bearing_normaliation(neighbors_result.rab.range) * MEDIUM_POWER,  
            angle = neighbors_result.rab.horizontal_bearing
        }
    elseif neighbors_result.repulse_field and neighbors_result.rab.range < LOW_RANGE then
        return {
            length = range_and_bearing_normaliation(neighbors_result.rab.range) * MEDIUM_POWER,  
            angle = neighbors_result.rab.horizontal_bearing - math.pi
        }
    else
        return {
            length = 0, 
            angle = 0
        }
    end
end

function write_range_and_bearing(i,n)
    robot.range_and_bearing.set_data(i,n)
end

function check_antenna()
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[ANTENNA_COMUNICATION] == 1 and rab.range < LOW_RANGE then
            return true
        end
    end
    return false
end

function check_neighbors(range_and_bearing_data)
    attract_field, repulse_field = false, false
    effective_rab = nil
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[range_and_bearing_data] == ATTRACT_WRITER and not repulse_field then  
            attract_field = true 
            effective_rab = rab
        elseif rab.data[range_and_bearing_data] == REPULSE_WRITER and rab.range < LOW_RANGE then
            log("Repulse")
            repulse_field = true
            attract_field = false
            effective_rab = rab
        end
    end
    return {
        rab = effective_rab, 
        attract_field = attract_field, 
        repulse_field = repulse_field
    }
end

function range_and_bearing_normaliation(value) 
    return 1 - 1 / value
end

function wheels_normalization(value)
    return  ((value - MIN_WHEELS) / (MAX_WHEELS - MIN_WHEELS)) * 10
end