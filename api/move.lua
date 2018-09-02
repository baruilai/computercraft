-- more advanced moving functions
-- mob protection is obsolete since CC 1.76, turtle will move entities 

local max_effort = 100 -- turtle will try to move this many times and then trow an error
local action_delay = 0.2 -- delay so turtle will not attack or dig too fast

local function forward(distance)
	distance = distance or 1

	for i = 1, distance do
        local tries = 0
		if turtle.detect() then 
			turtle.dig() 
		end

		--mob and sand/gravel protection
		while not turtle.forward() do
			if turtle.detect() then
				turtle.dig()
			else
				turtle.attack()
            end
            sleep(action_delay)
            tries = tries + 1
            if tries > max_effort then
                print("Error: can't move.")
                error_notification = "Error: can't move."
                return false
            end
		end
    end
    return true
end

local function up(distance)
	distance = distance or 1
 
    for i = 1, up do
        local tries = 0

		if turtle.detectUp() then 
			turtle.digUp() 
		end

		--mob and sand/gravel protection
		while not turtle.up() do
			if turtle.detectUp() then
				turtle.digUp()
			else
				turtle.attackUp()
            end
            sleep(action_delay)
            tries = tries + 1
            if tries > max_effort then
                print("Error: can't move.")
                error_notification = "Error: can't move."
                return false
            end
		end
    end
    return true
end
 
local function down(distance)
	distance = distance or 1


	for i = 1, down do
        local tries = 0

		if turtle.detectDown() then 
			turtle.digDown() 
		end

			--mob and sand/gravel protection
			while not turtle.down() do
				if turtle.detectDown() then
					turtle.digDown()
				else
                    turtle.attackDown()
                end
                sleep(action_delay)
                tries = tries + 1
                if tries > max_effort then
                    print("Error: can't move.")
                    error_notification = "Error: can't move."
                    return false
                end
			end
		end
    end
    return true
end
 
local function back(distance)
	distance = distance or 1

    for i = 1, back do
        local tries = 0

		--mob and sand/gravel protection
		while not turtle.back() do
			turtle.turnLeft()
			turtle.turnLeft()

			if turtle.detect() then
				turtle.dig()
			else
				turtle.attack()
            end
			turtle.turnLeft()
            turtle.turnLeft()
            tries = tries + 1
            if tries > max_effort then
                print("Error: can't move.")
                error_notification = "Error: can't move."
                return false
            end
		end
    end
    return true
end