-- Put your global variables here

MOVE_STEPS = 50
vector = require "vector"
n_steps = 0
steps_resolution = 5
robot_number = 0

wheel_speed_L = 0
wheel_speed_R = 0

light_sensor = nil
motor_ground = nil

robot_state = 0  -- 0 = find light, 1 = reached fire, 2 = following robot, 3 = fleeing from fire




--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
    n_steps = 0
	robot.leds.set_all_colors("black")
	robot.range_and_bearing.set_data(1, 1)
end

function step()
    v = {0, 0}
	if robot_state == 0 then
		if get_temperature_readings() then
            log("reached fire")
            robot_state = 1
		else
            log("must find fire")
            v = vector.vec2_polar_sum(see_light(), see_obstacle())
            log("VECTOR 0:       " .. v[0])
            log("VECTOR 1:       " .. v[1])
        end
    end
	if has_to_wander(v) then
        log("has to wander")
        wander()		
    else
        log("i'm going to the fire")
        wheels = trasformation(v.x, v.y)
		robot.wheels.set_velocity(robot.random.uniform(10), robot.random.uniform(10))
	end

	--robot_number = countRAB()	
	--log("range_and_bearing " .. robot_number)
	--if n_steps % steps_resolution == 0 then
    	--steps_resolution = DEFAULT_STEPS_RESOLUTION
		--follow_light()
  	--end
  	--n_steps = n_steps + 1
end


function trasformation(v, w)
	v = proximity_sensor.value
	w = proximity_sensor.angle
	if between(angle, 0, math.pi/2) then
	  v_left = v - ((w * L)/2)
	  v_right = v + ((w * L)/2)
	elseif between(angle, -math.pi/2, 0) then
	  v_left = v + ((w * L)/2)
	  v_right = v - ((w * L)/2) 
	end
	return {v_left, v_right}
  end
  
function has_to_wander(v)
    if robot_state == 0 then
        if v[0] == 0 and v[1] == 0 then
            return true
        end
    end
    return false
end


function fire_danger_zone()
	for _, motor_ground in pairs(robot.motor_ground) do
		log("motor_ground.value " .. motor_ground.value)
		if robot.motor_ground[_].value == 0.29899998085172 then 
			robot.leds.set_all_colors("red")
			return true
		else 
			log("don't see fire")
			return false
		end
	end
end

function fire_handling_zone()
	for _, motor_ground in pairs(robot.motor_ground) do
 		if robot.motor_ground[_].value == 0.69493725346584 then
			robot.leds.set_all_colors("blue")
			return true
		 else
			return false
		 end
	end
end

function get_temperature_readings()
	medium_temp = 0
	--high_temp = 0
	for _, motor_ground in pairs(robot.motor_ground) do
		if robot.motor_ground[_].value == 0.69493725346584 then
			robot.leds.set_all_colors("blue")
			medium_temp = medium_temp+1
		end
		--if robot.motor_ground[_].value == 0.29899998085172 then 
		--	high_temp = high_temp+1
		--end
	end
	if medium_temp >= 3 then
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
    log("OBSTACLE VALUE    :" .. max_proximity_value)
    log("OSTACLE ANGLE  :" .. max_proximity_angle)
    v.lenght = max_proximity_value
    v.angle = max_proximity_angle
	return v
end

function see_light()
	max_light_value = 0
	max_light_angle = 0
    v = {}
	for _, light_sensor in pairs(robot.light) do
		if light_sensor.value > max_light_value then 
			robot.leds.set_all_colors("red")
			max_light_value = light_sensor.value
			max_light_angle = light_sensor.angle
		end 
	end 
    log("LIGHT VALUE     :" .. max_light_value)
    log("LIGHT ANGLE     :" .. max_light_angle)
    v.lenght = max_light_value
    v.angle = max_light_angle
	return v
end

function wander() 
	--log("Robot is in wander state")
	steps_resolution = 20 
	robot.range_and_bearing.set_data(1, 0)
	robot.wheels.set_velocity(robot.random.uniform(10), robot.random.uniform(10))
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

