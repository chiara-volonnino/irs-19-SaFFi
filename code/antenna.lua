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
    robot.wheels.set_velocity(0,0)
    if robot_state == 0 then
        if count_assisting_robots() then
            write_range_and_bearing(6,1)
            robot_state = 1
            robot.leds.set_all_colors("white")
        end
    end
end

-------------- Controller functions --------------

function write_range_and_bearing(i,n)
    robot.range_and_bearing.set_data(i,n)
end

function count_assisting_robots()
    assisting_robots = 0
    for _,rab in ipairs(robot.range_and_bearing) do
        if rab.data[3] == 1  then
            assisting_robots = assisting_robots + 1
        end
    end
    log("Assisting robots == " .. assisting_robots)
    if assisting_robots == 4 then
        return true
    else
        return false
    end
end
