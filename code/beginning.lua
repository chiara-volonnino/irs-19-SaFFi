local vector = require "vector"

light_sensor = nil
motor_ground = nil
robot_state = 0  -- 0 = find light, 1 = reached fire, 2 = following robot, 3 = fleeing from fire

step = 0
local v1 = {}
local v2 = {}


function init()
	L = robot.wheels.axis_length
	robot.leds.set_all_colors("black")
	--robot.range_and_bearing.set_data(1, 1)
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
		v1 = vector.vec2_polar_sum(wander(), avoid_obstacle())
        
        v5 = read_range_and_bearing(1)
        if v5.length ~= 0 then
            v3 = vector.vec2_polar_sum(v1,v5)
            wheels_l, wheels_r = trasformation_vector_to_velocity(v3)
            robot.leds.set_all_colors("white")
        else
            v2 = vector.vec2_polar_sum(v1, follow_light())
            wheels_l, wheels_r = trasformation_vector_to_velocity(v2)
            robot.leds.set_all_colors("yellow")
        end
		robot.wheels.set_velocity(wheels_l, wheels_r)
		if get_temperature_readings() then
            robot.leds.set_all_colors("red")
			robot_state = 1
		else
			log("")
		end
	elseif robot_state == 1 then
        write_range_and_bearing(2,25)
		robot.wheels.set_velocity(0, 0)
        if count_assisting_robots() then
            robot.leds.set_all_colors("green")
            robot_state = 2
        end
	elseif robot_state == 2 then
        write_range_and_bearing(2,25)
        write_range_and_bearing(1,50)
		robot.wheels.set_velocity(0, 0)
	else 
		log("robot in state n")
	end
end

-------------- Controller functions --------------

function wander() 
	--log("Robot is in wander state")
	--robot.range_and_bearing.set_data(1, 0)
	return {length = robot.random.uniform(5), angle = robot.random.uniform(-math.pi/4, math.pi/4)} -- TODO: settare il random value
end 

function follow_light()
	max_light_value = 0
	max_light_angle = 0
	for _, light_sensor in pairs(robot.light) do
		if light_sensor.value > max_light_value then 
			max_light_value = light_sensor.value
			max_light_angle = light_sensor.angle
		end 
	end
	return {length = max_light_value * 4, angle = max_light_angle}
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
	return {length = max_proximity_value * 7, angle = max_proximity_angle + math.pi}
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
  if medium_temp >= 4 then
	  return true
  else
	  return false
  end
end

--function countRAB()
	--number_robot_sensed = 0
	--for _, rab in ipairs(robot.range_and_bearing) do
		--if rab.range < 30 and rab.data[1] == 1 then   
			--number_robot_sensed = number_robot_sensed + 1
			--log("in :" .. number_robot_sensed)
		--end
	--end
	--return number_robot_sensed
--end 


function read_range_and_bearing(i)
    for _,rab in ipairs(robot.range_and_bearing) do
        log("RAB Range" .. rab.range)
        log("RAB Data" .. rab.data[i])
        if rab.data[1] == 50 then
            log("GO AWAY")
            return {length = (rab.range/100)*15, angle = rab.horizontal_bearing+(math.pi)}
        else
            log("Nessun cambiamento")
            return {length = 0, angle = 0}
        end
    end
end

function write_range_and_bearing(i,n)
    robot.range_and_bearing.set_data(i,n)
end

function count_assisting_robots()
    assisting_robots = 1
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[2] == 25 then
            assisting_robots = assisting_robots +1
        end
    end
    log("Assisting robots == " .. assisting_robots)
    if assisting_robots >= 4 then
        log("FIre Reached Capacity")
        return true
    else
        log("Still need help with fire")
        return false
    end
end
