--Farm - program for persistent farming

-- dodelat gameitem a dat tam crops

local wait_for_crops = 900 --seconds
local sleep_on_startup = 3
local min_fuel_requirement = 500
local farm_width, farm_depth = 3, 3
local slot = {["chest"] = 11, ["soil"] = 12, ["left"] = 13, ["front"] = 14, ["right"] = 15, ["back"] = 16}

print("fuel: "..turtle.getFuelLevel())
local args = {...}
local pastebin_code = "kxn741hQ"

local game_item = {
	chest = "minecraft:chest";
	leaves = "minecraft:leaves";
	torch = "minecraft:torch";
	water = "minecraft:water";
	reed = 	"minecraft:reeds";
	wheat = "minecraft:wheat";
	carrot = "minecraft:carrots";
	potatoe = "minecraft:potatoes";
	nether_wart = "minecraft:nether_wart";
	melon_stem = "minecraft:melon_stem";
	pumpkin_stem = "minecraft:pumpkin_stem";
	melon = "minecraft:melon_block";
	pumkin = "minecraft:pumpkin";
}

local message
local error_notification = {
	fuel = 					"Turtle needs more fuel",
	wood_chest_full = 		"Chest for wood is full",
	wood_chest_missing =	"Missing chest below",
	sapling_chest_full = 	"Chest for saplings is full",
	not_crafty = 			"Turtle is not crafty",
	refuel_error = 			"Error while refueling",
	chest_down = 			"Chest down is full",
}

local function update()
	--before we try to delete ourself, just check the connection OK?
	test = http.get("http://pastebin.com/" .. pastebin_code)
	if test then

		-- first let me delete myself
		print(fs.delete(shell.getRunningProgram()))

		-- Now get the program from pastebin.com
		-- Format: pastebin get (pasteid) (destination)
		-- not so simple way to get name of this program without path
		shell.run("pastebin get "..pastebin_code.." "..fs.getName(shell.getRunningProgram()))
	else
		print("Update is not possible")
	end
end

-- you can cancel waiting countdown by this
function cancelTimer(duration, text)
	timer = os.startTimer(1)
	repeat
		term.clear()
		term.setCursorPos (1, 1)
		print("fuel: "..turtle.getFuelLevel())
		print(text)
		print("Press enter to enter menu.")
		print(duration)
		 
		local id, p1 = os.pullEvent()
		if id == "key" and p1 == 28 then
			term.clear()
			term.setCursorPos (1, 1)
			return true
		elseif id == "timer" and p1 == timer then
			duration = duration-1
			timer = os.startTimer(1)
		end

	until duration < 0
	term.clear()
	term.setCursorPos (1, 1)
	return false
end

-- four important moving functions
-- mob protection is obsolete since CC 1.76
local function moveForward(forward)
	if forward == nil then 
		forward = 1 
	end

	for i = 1, forward do

		if turtle.detect() then 
			turtle.dig() 
		end

		--mob and sand/gravel protection
		while not turtle.forward() do
			if turtle.detect() then
				turtle.dig()
				sleep(0.5)
			else
				turtle.attack()
			end
		end
	end
end

local function moveUp(up)
	if up == nil then 
		up = 1 
	end
 
	for i = 1, up do

		if turtle.detectUp() then 
			turtle.digUp() 
		end

		--mob and sand/gravel protection
		while not turtle.up() do
			if turtle.detectUp() then
				turtle.digUp()
				sleep(0.5)
			else
				turtle.attackUp()
			end
		end
	end
end
 
local function moveDown(down)
	if down == nil then 
		down = 1 
	end

	for i = 1, down do

		if turtle.detectDown() then 
			turtle.digDown() 
		end

			--mob and sand/gravel protection
			while not turtle.down() do
				if turtle.detectDown() then
					turtle.digDown()
					sleep(0.5)
				else
					turtle.attackDown()
			end
		end
	end
end
 
local function moveBack(back)
	if back == nil then back = 1 end

	for i = 1, back do

		while not turtle.back() do
			turtle.turnLeft()
			turtle.turnLeft()

			if turtle.detect() then
				turtle.dig()
				sleep(0.5)
			else
				turtle.attack()
			end

			turtle.turnLeft()
			turtle.turnLeft()
		end
	end
end

-- protection against unlimited fuel errors
local function needToRefuel()
	if turtle.getFuelLevel() == "unlimited" or turtle.getFuelLevel() > optimum_fuel_level then 
		return false
	else
		return true
	end
end

local function fuelTooLow()
	if turtle.getFuelLevel() == "unlimited" or turtle.getFuelLevel() > min_fuel_requirement then 
		return false
	else
		return true
	end
end

local function selectNextSlot()
		--if there is no material, select next slot
		--přejmenovat ať to dává větší smysl
		if turtle.getItemCount(turtle.getSelectedSlot()) == 0 and turtle.getSelectedSlot() < 11 then 
				turtle.select(turtle.getSelectedSlot() + 1)
		end
end

local function checkWall()
	local last_slot = turtle.getSelectedSlot()
	if turtle.detect() then
		local inspected, block = turtle.inspect()
		if block.name == game_item.reed then
			turtle.dig()
		else

			for i = 13, 16 do
				turtle.select(i)
				if turtle.compare() then
					turtle.select(last_slot)
					return(i)
				end
			end
			
		end
	end
	turtle.select(last_slot)
end

-- check name on block
local function inspect(direction, requested_data)
	local inspected, item

	if direction == "front" then
		inspected, item = turtle.inspect()
	elseif direction == "down" then
		inspected, item = turtle.inspectDown()
	elseif direction == "up" then
		inspected, item = turtle.inspectUp()
	end

	if inspected then
		if requested_data == "name" then
			return item.name
		elseif requested_data == "metadata" then
			return item.metadata
		end
	else return false
	end
end

local function unload()
	for i = 2, 12 do
		turtle.select(i)
		if not turtle.dropDown() then
			message = "chest_down"
			return false
		end
	end
	turtle.select(1)
end

local function checkChestDown()
	turtle.select(1)
	while turtle.getItemCount(turtle.getSelectedSlot()) == 0 do
		if turtle.getSelectedSlot() == 12 then
				error("inventory is empty")
		end
		turtle.select(turtle.getSelectedSlot() + 1)
	end
	if turtle.getSelectedSlot() > 1 then
		turtle.transferTo(1)
		turtle.select(1)
	end

	if not turtle.suckDown() then
		return true
	else
		turtle.dropDown()
		turtle.select(2)
		if not turtle.dropDown() then
			turtle.select(1)
			turtle.suckDown()
			turtle.select(2)
			turtle.dropDown()
			turtle.select(1)
			return false
		else
			turtle.select(1)
			turtle.suckDown()
			return true
		end
	end
end

local function harvest(length) --harvest only, no planting
	-- fuel check
	if fuelTooLow() then
		message = "fuel"
		return
	end

	if inspect("down", "name") == game_item.chest then
		-- chest check
		unload()
		if not checkChestDown() then
			message = "chest_down"
			return
		end
	end

	local function till()
		while not turtle.detect() do
			moveForward()
			turtle.digDown()
		end
	end

	till()

	while not fuelTooLow() do
		if checkWall() == slot.front then 
			turtle.turnRight()
			if turtle.detect() and checkWall() == slot.right then 
				turtle.turnLeft()
				turtle.turnLeft()
			else
				moveForward()
				turtle.turnRight()
				turtle.digDown()
			end
			till()
		end

		if checkWall() == slot.back then
			turtle.turnLeft()
			if turtle.detect() and checkWall() == slot.right then 
				turtle.turnLeft()
				turtle.turnLeft()
			else
				moveForward()
				turtle.turnLeft()
				turtle.digDown()
			end
			till()
		end

		if checkWall() == slot.left then
			turtle.turnRight()
			local search_start = true
			while search_start do
				moveBack()
				local inspected, item = turtle.inspectDown()
				if inspected then
					if item.name == game_item.chest then
						return true
					end
				end
			end
		end
	end
	till()
end

local function plant(length)

	local function getCrop()
		--dig only full grown crops
		local cropType = inspect("down", "name")
		if cropType == game_item.wheat or cropType == game_item.carrot or cropType == game_item.potatoe then
			if inspect("down", "metadata") == 7 then
				turtle.digDown()
				turtle.placeDown()
			end
		--dig only full grown netherwart
		elseif cropType == game_item.nether_wart then
			if inspect("down", "metadata") == 3 then
				turtle.digDown()
				turtle.placeDown()
			end
		elseif cropType == game_item.reed then
			turtle.digDown()
		elseif cropType == game_item.melon_stem or cropType == game_item.pumpkin_stem then
			--do nothing
		elseif cropType == game_item.melon or cropType == game_item.pumpkin then
			turtle.digDown()
		else
			turtle.digDown()
			turtle.placeDown()
		end
		selectNextSlot()
	end

	local function seed()

		while not turtle.detect() do
			moveForward()
			getCrop()
		end
	end

	seed()

	while not fuelTooLow() do

		if checkWall() == slot.front then 
			turtle.turnRight()
			if turtle.detect() and checkWall() == slot.right then 
				turtle.turnLeft()
				turtle.turnLeft()
			else
				moveForward()
				turtle.turnRight()

				getCrop()

				seed()
			end
		end

		if checkWall() == slot.back then
			turtle.turnLeft()
			if turtle.detect() and checkWall() == slot.right then 
				turtle.turnLeft()
				turtle.turnLeft()
			else
				moveForward()
				turtle.turnLeft()

				getCrop()
			end
			seed()
		end

		if checkWall() == slot.right then
			turtle.turnLeft()
			turtle.turnLeft()
			getCrop()
			seed()
		end

		if checkWall() == slot.left then
			turtle.turnRight()
			local search_start = true

			while search_start do
				moveBack()
				if inspect("down", "name") == game_item.chest then
					search_start = false
					return true
				end
			end
		end

			seed()
	end 
end

local function placeSolidBlock(direction)

	if direction == "up" then
			if not turtle.compareUp() and turtle.detectUp() then
				turtle.digUp()
			end
			while not turtle.placeUp() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
				turtle.attackUp()
			end
			selectNextSlot()
	elseif direction == "front" then
			if not turtle.compare() and turtle.detect() then
				turtle.dig()
			end
			while not turtle.place() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
				turtle.attack()
			end
			selectNextSlot()
	elseif direction == "down" then 
			if not turtle.compareDown() and turtle.detectDown() then 
				turtle.digDown() 
			else
				while not turtle.placeDown() and not turtle.detectDown() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
					turtle.attackDown()
					print("attack")
				end
				selectNextSlot()
			end
			--if we use sand or gravel for drying water or lava lake
			while not turtle.detectDown() do
				turtle.placeDown()
				selectNextSlot()
			end
	end
end

local function laySurface (x, z, direction, go_to_start)
	if direction == nil then direction = "down" end

	--place blocks in one line
	local function placeBlock(length)

		if length == nil then length = 1 end

		for i = 2, length do
			
			if direction == "digdown" then
				if turtle.detectDown() then
					turtle.digDown()
				end
			else
				placeSolidBlock(direction)
			end

			selectNextSlot()
			moveForward()
		end

		--finishing move
		if direction == "digdown" then
			if turtle.detectDown() then
				turtle.digDown()
			end
		else
			placeSolidBlock(direction)
		end

		--if there is no material, select next slot
		selectNextSlot()
	end

	--place x number of lines
	for r = 1, x do

		placeBlock(z)

		if r%2 == 1 and r ~= x then 
			turtle.turnRight()
			moveForward()
			turtle.turnRight()
		end

		if r%2 == 0 and r ~= x then
			turtle.turnLeft()
			moveForward()
			turtle.turnLeft()
		end
	end

	--return to start
	if go_to_start == true then
		if x%2 == 0 then 
			turtle.turnRight()
			moveForward(x - 1)
			turtle.turnRight()
		end

		if x%2 == 1 then
			moveBack(z - 1)
			turtle.turnLeft()
			moveForward(x - 1)
			turtle.turnRight()
		end
	end
end

local function makeWallsAround(width, depth, slot_1, slot_2, slot_3, slot_4)
	moveForward()
	turtle.turnLeft()
	turtle.turnLeft()

	local function makeWall(length)
		placeSolidBlock("up")
		placeSolidBlock("down")
		for i = 1, length - 3 do
			moveBack()
			placeSolidBlock("up")
			placeSolidBlock("front")
			placeSolidBlock("down")
		end
		moveBack()
		placeSolidBlock("front")
	end

	turtle.select(slot_1)
	makeWall(depth)

	turtle.turnRight()
	moveBack()

	turtle.select(slot_2)
	makeWall(width)

	turtle.turnRight()
	moveBack()

	turtle.select(slot_3)
	makeWall(depth)

	turtle.turnRight()
	moveBack()

	turtle.select(slot_4)
	makeWall(width - 1)

	turtle.turnLeft()
end

local function makeFarm(width, depth)
	turtle.select(12)
	moveForward()
	laySurface(farm_width, farm_depth, "down", true)
	moveBack()
	turtle.turnLeft()
	moveForward()
	turtle.turnRight()
	makeWallsAround(farm_width + 2, farm_depth + 2, slot.left, slot.front, slot.right, slot.back)
	moveUp()
	turtle.select(11)
	turtle.placeDown()
	turtle.turnLeft()
	moveForward()
	turtle.placeDown()
	moveBack()
	turtle.turnRight()
end

local function farm()
	-- fuel check
	if fuelTooLow() then
		message = "fuel"
		return
	end

	if inspect("down", "name") == game_item.chest then
		-- chest check
		unload()
		if not checkChestDown() then
			message = "chest_down"
			return
		end
	end

	turtle.select(1)
	while turtle.getItemCount(turtle.getSelectedSlot()) == 0 do
		if turtle.getSelectedSlot() == 16 then
				error("inventory is empty")
		end
		turtle.select(turtle.getSelectedSlot() + 1)
	end
	if turtle.getSelectedSlot() > 10 then
		turtle.select(1)
	end 
	plant()
	unload()
end

local function farmForever()
	-- fuel check
	if fuelTooLow() then
		message = "fuel"
		return
	end

	if inspect("down", "name") == game_item.chest then
		-- chest check
		unload()
		if not checkChestDown() then
			message = "chest_down"
			return
		end
	end

	turtle.select(1)
	while turtle.getItemCount(turtle.getSelectedSlot()) == 0 do
			if turtle.getSelectedSlot() == 16 then
					error("inventory is empty")
			end
			turtle.select(turtle.getSelectedSlot() + 1)
	end

	if turtle.getSelectedSlot() > 10 then
		turtle.select(1)
	end 

	while not fuelTooLow() do
		plant()
		unload()
		
	for i = 1, wait_for_crops do
		term.clear()
		term.setCursorPos(1, 1)
		print("fuel: "..turtle.getFuelLevel())
		print("Waiting for crops to grow")
		print(wait_for_crops - i)
		sleep(1)
	end
	end
end

-- create startup file with command to start program harvesting loop
local function createStartup()
	if fs.exists("startup") then
		fs.delete("startup")
	end

	local file = fs.open("startup","w")
	file.write('shell.run("' ..fs.getName(shell.getRunningProgram()).. '", "loop")')
	file.close()
end

local function deleteStartup()
	fs.delete("startup")
end

local function farmLoop()
	createStartup()
	farmForever()
end

local function options()
	local term_width, term_height = term.getSize()
	local selected = 1
	local menustate = "main"

	local menu = {
			["main"] = {"Wait for crops to grow", "Minimum fuel required"},
			["Wait for crops to grow"] = {0, 3, 60, 1974, 2256, 2867, 3277}
		}

	local function printLeft(string, y_position)
		term.setCursorPos(2, y_position)
		term.write(string)
	end

		term.clear()
		for i = 1, #menu[menustate].options do
			if i == selected then
				printLeft("[ "..menu[menustate].options[i].." ]", term_height / 2 - #menu[menustate].options / 2 + i)
			else
				printCentered(menu[menustate].options[i], term_height / 2 - #menu[menustate].options / 2 + i)
			end
		end
end

local function runMenu()

	local function checkStartup()
		if fs.exists("startup") then
			return "Delete startup file"
		else
			return "Create startup file"
		end
	end

	local startup = checkStartup()

	local function modifyStartup()
		if fs.exists("startup") then
			fs.delete("startup")
			startup = "Create startup file"
		else
			createStartup()
			startup = "Delete startup file"
		end
	end

	local menu = {
		["main"] = {
			options =   {"Farm just once",  "Harvest all crops",    "Farm in loop",   "Make farm", startup, 		"Quit"},
			job =       { farm,              harvest,                farmLoop,         makeFarm,   modifyStartup,	"quit"}
		},
	}

	local term_width, term_height = term.getSize()
	local selected = 1
	local menustate = "main"

	local function printCentered(string, y_position)
		term.setCursorPos(term_width / 2 - #string / 2, y_position)
		term.write(string)
		return true
	end

	local function printFuelLevel()
		if turtle.getFuelLevel() ~= "unlimited" then
			local fuel_report = "Fuel: " .. turtle.getFuelLevel()
			term.setCursorPos(term_width - #fuel_report, 1)
			term.write(fuel_report)
		end
	end

	local function printStatus()
		if message then
			term.setCursorPos(1, 1)
			term.write(error_notification[message])
		end
	end

	-- never ever use while true... why is it even working?
	while true do
		--this is only to update startup entry, probably should use menu["main"].options[3] = startup
		local menu = {
			["main"] = {
				options =   {"Farm just once",  "Harvest all crops",    "Farm in loop",   "Make farm", startup, 		"Quit"},
				job =       { farm,              harvest,                farmLoop,         makeFarm,   modifyStartup,	"quit"}
			},
		}

		term.clear()
		printFuelLevel()
		printStatus()

		for i = 1, #menu[menustate].options do
			if i == selected then
				printCentered("[ "..menu[menustate].options[i].." ]", term_height / 2 - #menu[menustate].options + i * 2)
			else
				printCentered(menu[menustate].options[i], term_height / 2 - #menu[menustate].options + i * 2)
			end
		end

		event, key = os.pullEvent("key")

		if key == keys.down and selected < #menu[menustate].options then
			selected = selected + 1
		elseif key == keys.up and selected > 1 then
			selected = selected - 1
		elseif key == keys.down and selected == #menu[menustate].options then
			selected = 1
		elseif key == keys.up and selected == 1 then
			selected = #menu[menustate].options
		elseif key == keys.enter then
			if type(menu[menustate].job[selected]) == "function" then
				term.clear()
				term.setCursorPos(1, 1)
				message = nil
				menu[menustate].job[selected]()
			else
				menustate = menu[menustate].job[selected]
				selected = 1
			end
			
			if menustate == "quit" then 
				term.clear()
				term.setCursorPos(1, 1)
				return
			end
		end
	end
end

if args[1] == "update" then
	update()
	return
end

if args[2] then
	wait_for_crops = tonumber(args[2])
end
if args[3] then
	min_fuel = tonumber(args[3])
end

if args[1] == "loop" then
	if not cancelTimer(sleep_on_startup, "Countdown to start") then
		farmForever()
	end
end

runMenu()