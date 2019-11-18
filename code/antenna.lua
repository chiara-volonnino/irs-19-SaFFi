local HIGH_TEMPERATURE, LOW_TEMPERATURE = 0, 1
local ROBOT_PRESENCE, ANTENNA_FIELD, ANTENNA_COMUNICATION = 1, 2, 4
local ATTRACT_WRITER, REPULSE_WRITER = 1, 2
local MAX_NUMBER_OF_ROBOTS = 4

local robot_state = 0

function init()
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
    robot.wheels.set_velocity(0,0)
    if robot_state == HIGH_TEMPERATURE then
        write_range_and_bearing(ANTENNA_FIELD, ATTRACT_WRITER)
        if count_assisting_robots() then
            write_range_and_bearing(ANTENNA_COMUNICATION, ATTRACT_WRITER)
            robot_state = LOW_TEMPERATURE
            robot.leds.set_all_colors("white")
        end
    elseif robot_state == LOW_TEMPERATURE then
        write_range_and_bearing(ANTENNA_FIELD, REPULSE_WRITER)
    end
end

-------------- Controller functions --------------
function write_range_and_bearing(i,n)
    robot.range_and_bearing.set_data(i,n)
end

function count_assisting_robots()
    assisting_robots = 0
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[ROBOT_PRESENCE] == ATTRACT_WRITER  then
            assisting_robots = assisting_robots + 1
        end
    end
    if assisting_robots == MAX_NUMBER_OF_ROBOTS then
        return true
    else
        return false
    end
end
