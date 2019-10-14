-- Put your global variables here

MOVE_STEPS = 50
n_steps = 0
steps_resolution = 5
robot_number = 0
light_sensor = nil
motor_ground = nil

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
    n_steps = 0
	robot.leds.set_all_colors("black")
	robot.range_and_bearing.set_data(1, 1)
end

function step()
	robot_number = countRAB()	
	--log("range_and_bearing " .. robot_number)
	if n_steps % steps_resolution == 0 then
    	steps_resolution = DEFAULT_STEPS_RESOLUTION
		follow_light()
  	end
  	n_steps = n_steps + 1
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

function see_light()
	for _, light_sensor in pairs(robot.light) do
		if light_sensor.value > 0 then 
			robot.leds.set_all_colors("yellow")
			return true
		end 
	end 
	return false
end

function see_fire() 
	for _, motor_ground in pairs(robot.motor_ground) do
		log("motor_ground.value " .. motor_ground.value)
		if robot.motor_ground[_].value == 0.29899998085172 then 
			robot.leds.set_all_colors("red")
			return true
		elseif robot.motor_ground[_].value == 0.69493725346584 then
			robot.leds.set_all_colors("blue")
			return true
		else 
			log("don't see nothing")
			return false
		end
	end
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
