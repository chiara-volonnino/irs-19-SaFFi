-- Put your global variables here

MOVE_STEPS = 50
n_steps = 0
steps_resolution = 5
robotNumber = 0

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
    n_steps = 0
	robot.leds.set_all_colors("black")

    max_intensity = 0
    max_light_sensor_index = 1
end

function step()
	robot.range_and_bearing.set_data(1,10)	
	if n_steps % steps_resolution == 0 then
    	steps_resolution = DEFAULT_STEPS_RESOLUTION
		wander()
  	end
  	n_steps = n_steps + 1
end



function wander() 
	log("Wander state")
	steps_resolution = 20 
  	robot.wheels.set_velocity(robot.random.uniform(10), robot.random.uniform(10))
	robotNumber = countRAB()
	log("Robot number:" .. robotNumber)
end 

function followLight() 
end

function obstaclesAvoid()
end

function stopNearFire()
end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,15)
	right_v = robot.random.uniform(0,15)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function countRAB()
	log("countRAB")
	number_robot_sensed = 0
	-- for each robot seen
	for _, rab in ipairs(robot.range_and_bearing) do
		if rab.range < 30 and rab.data[1] == 1 then
			number_robot_sensed = number_robot_sensed + 1
			log("in :" .. number_robot_sensed)
		end
	end
	log("in RAB:" .. number_robot_sensed)
	return number_robot_sensed
end 

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end