-- Put your global variables here

MOVE_STEPS = 10
n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
    n_steps = 0
	robot.leds.set_all_colors("black")
    
    max_intensity = 0
    max_light_sensor_index = 1
end

function getKeysSortedByValue(tbl,sortFunc)
    local keys = {}
    for key in pairs(tbl) do table.insert(keys,key) end
    table.sort(keys, function(a,b) return sortFunc(tbl[a], tbl[b]) end)
    return keys
end

function step()
    
    n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		max_intensity = 0
        max_light_sensor_index = 1
        
        intensities = {0,0,0,0}
        proximities = {0,0,0,0}
        
        for i=1,4 do
            for k=1,6 do
               intensities[5-i] = intensities[5-i] + robot.light[(i-1)*6+k].value
               proximities[5-i] = proximities[5-i] + robot.proximity[(i-1)*6+k].value
            end
        end
        
        log("intensities:")
        log(intensities[1])
        log(intensities[2])
        log(intensities[3])
        log(intensities[4])

        priorities = getKeysSortedByValue(intensities, function(a,b) return a > b end)
        anti_priorities = getKeysSortedByValue(proximities, function(a,b) return a > b end)
        
        blocked_quadrant = 0
        if proximities[anti_priorities[1]] ~= 0 then 
            blocked_quadrant = anti_priorities[1]
        end
        
        priority_index = 1
        
        log("priorities[1] = " .. priorities[1])
        log("blocked quadrant = " .. blocked_quadrant)
        
        for i=1,4 do
            if priorities[i] ~= blocked_quadrant then
                priority_index = priorities[i]
                break
            end
        end
        
        log("moving towards quadrant: " .. priority_index)
        
        high_v = 8
        low_v = 6
        if blocked_quadrant ~= 0 then
            low_v = 1
        end
        
        if priority_index == 4 then
            left_v = low_v
            right_v = high_v
        elseif priority_index == 3 then
            left_v = -low_v
            right_v = -high_v
        elseif priority_index == 2 then
            left_v = -high_v
            right_v = -low_v
        elseif priority_index == 1 then
            left_v = high_v
            right_v = low_v
        end
        
        if intensities[priorities[1]] >= 1.3 then
            left_v = 0
            right_v = 0
        end
        
        robot.wheels.set_velocity(left_v,right_v)
	end

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


--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
