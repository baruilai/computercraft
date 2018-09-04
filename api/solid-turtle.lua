local class = require("class")
local solid_turtle = class.class()

solid_turtle.max_effort = 100 -- turtle will try to move this many times and then trow an error
solid_turtle.action_delay = 0.2 -- delay so turtle will not attack or dig too fast, used to prevent error: "Too long without yielding"

function solid_turtle:forward(distance)
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
			sleep(self.action_delay)
			tries = tries + 1
			if tries > self.max_effort then
				print("Error: can't move:")
				error_notification = "Error: can't move:"
				return false
			end
		end
	end
	return true
end

function solid_turtle:up(distance)
	distance = distance or 1
 
	for i = 1, distance do
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
			sleep(self.action_delay)
			tries = tries + 1
			if tries > self.max_effort then
				print("Error: can't move:")
				error_notification = "Error: can't move:"
				return false
			end
		end
	end
	return true
end
 
function solid_turtle:down(distance)
	distance = distance or 1

	for i = 1, distance do
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
			sleep(self.action_delay)
			tries = tries + 1
			if tries > self.max_effort then
				print("Error: can't move:")
				error_notification = "Error: can't move:"
				return false
			end
		end
	end
	return true
end

function solid_turtle:back(distance)
	distance = distance or 1

	for i = 1, distance do
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
			if tries > self.max_effort then
				print("Error: can't move:")
				error_notification = "Error: can't move:"
				return false
			end
		end
	end
	return true
end

return solid_turtle