
local suckDirection = "down"
local dropDirection = "up"
local args = {...}

local recipy =	{64, 64, 64, 0,
				  0,  0,  0, 0,
				  0,  0,  0, 0,
				  0,  0,  0, 0}

local wait_for_ingots = 360 --seconds

local function suck()
	for i = 1, #recipy do
		turtle.select(i)

		while turtle.getItemCount(i) < recipy[i] do
			if suckDirection == "up" then
				if not turtle.suckUp() then break end
			elseif suckDirection == "front" then
				if not turtle.suck() then break end
			elseif suckDirection == "down" then
				if not turtle.suckDown() then break end
			end
		end

		if turtle.getItemCount(i) > recipy[i] then
			if dropDirection == "up" then
				turtle.dropUp()
			elseif dropDirection == "front" then
				turtle.drop()
			elseif dropDirection == "down" then
				turtle.dropDown()
			end
		end
	end

	local x = 0

	for i = 1, #recipy do
		if recipy[i] == turtle.getItemCount(i) then 
			x = x + 1
		end
	end

	if x == 16 then
		return true
	else
		return false
	end
end

--if you just entered the world, wait some time for fps to stabilize
sleep(3)

if args[1] then
	suckDirection = args[1]
end
if args[2] then
	dropDirection = args[2]
end

local success
while turtle.getFuelLevel() > 50 do
	success = suck()
	if success then
		for i = 1, 3 do
			turtle.craft()
			if not turtle.dropUp() then 
				term.clear()
				term.setCursorPos(1, 1)
				print("truhla na papir je plna, cekam")
				sleep(wait_for_ingots)
				while not turtle.dropUp() do
					sleep(wait_for_ingots)
				end
			end
		end

	elseif not success then
		print("cekam na suroviny")
		sleep(wait_for_ingots)
	end

	for i = 1, #recipy do
		turtle.select(i)
		if dropDirection == "up" then
			turtle.dropUp()
		elseif dropDirection == "front" then
			turtle.drop()
		elseif dropDirection == "down" then
			turtle.dropDown()
		end
	end
end