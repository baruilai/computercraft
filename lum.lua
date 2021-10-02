-- Woody - program for pesistent wood farming
-- version 3 for Minecraft 1.8.9

-- you can edit these variables
local sleep_on_startup = 3 --seconds, to prevent lagging caused by too many computer starting
local wait_for_saplings = 60 --seconds shoud get you up to 6 logs per minute, feel free to experiment
local min_fuel_requirement = 500 --turtle will not work if less
local optimum_fuel_level = 5000 --turtle will try to keep fuel level around this level (search for unload function)
local starting_position = "left" --if you change starting position to right side, change this to "right"
local get_sapling_pos = "front" -- where are saplings collected - front, back, left right
local max_trunk_height = 20 -- to implement into restore session

-- you should not edit these variables, unless you know what you are doing
local pastebin_code = "dN6aBV51"
local working_altitude = 4
local slot = {
	sapling = 1,
	dirt = 2,
	log = 3,
	cobblestone = 4,
	bucket1 = 10,
	bucket2 = 11,
	down = 12,
	to_start = 13,
	front = 14,
	turn = 15,
	back = 16
}
local turtle_need_fuel = true

local message
local error_notification = {
	fuel = "Turtle needs more fuel",
	wood_chest_full = "Chest for wood is full",
	wood_chest_missing = "Missing chest below",
	sapling_chest_full = "Chest for saplings is full",
	not_crafty = "Turtle is not crafty",
	refuel_error = "Error while refueling"
}

-- minimum item requirement for farming trees
local felling_req = {
	quantity = {[1] = 1, [2] = 1, [3] = 2, [12] = 1, [13] = 1, [14] = 1, [15] = 1, [16] = 1},
	name = {},
	description = {
		[1] = "saplings",
		[2] = "dirt",
		[3] = "logs",
		[12] = "sappling block",
		[13] = "finishing block",
		[14] = "distant block",
		[15] = "turnaround block",
		[16] = "back block"
	}
}

-- minimum item requirement for building a tree farm
local building_req = {
	quantity = {
		[2] = 26,
		[3] = 30,
		[4] = 64,
		[5] = 64,
		[6] = 64,
		[7] = 64,
		[8] = 64,
		[9] = 37,
		[10] = 1,
		[11] = 1,
		[12] = 8,
		[13] = 17,
		[14] = 17,
		[15] = 17,
		[16] = 16
	},
	name = {},
	description = {
		[2] = "dirt",
		[3] = "torches",
		[4] = "building block",
		[5] = "building block",
		[6] = "building block",
		[7] = "building block",
		[8] = "building block",
		[9] = "building block",
		[10] = "waterbucket",
		[11] = "waterbucket",
		[12] = "block going down",
		[13] = "left block",
		[14] = "distant block",
		[15] = "right block",
		[16] = "close block"
	}
}

-- to do
local game_item = {
	chest = "minecraft:chest",
	leaves = "minecraft:leaves",
	torch = "minecraft:wall_torch",
	water = "minecraft:water"
}

local args = {...}

local function update()
	--before we try to delete ourself, just check the connection OK?
	test = http.get("http://pastebin.com/" .. pastebin_code)
	if test then
		-- first let me delete myself
		print(fs.delete(shell.getRunningProgram()))

		-- Now get the program from pastebin.com
		-- Format: pastebin get (pasteid) (destination)
		-- not so simple way to get name of this program without path
		shell.run("pastebin get " .. pastebin_code .. " " .. fs.getName(shell.getRunningProgram()))
	else
		print("Update is not possible")
	end
end

-- create startup file with command to start program harvesting loop
local function createStartup()
	if fs.exists("startup") then
		fs.delete("startup")
	end

	local file = fs.open("startup", "w")
	file.write(
		'shell.run("' ..
			fs.getName(shell.getRunningProgram()) ..
				'", "' .. starting_position .. '", "' .. get_sapling_pos .. '", "' .. wait_for_saplings .. '", "skipmenu")'
	)
	file.close()
end

-- you can cancel waiting countdown by this
function cancelTimer(duration, text)
	timer = os.startTimer(1)
	repeat
		term.clear()
		term.setCursorPos(1, 1)
		print("fuel: " .. turtle.getFuelLevel())
		print(text)
		print("Press enter to enter menu.")
		print(duration)

		local id, p1 = os.pullEvent()
		if id == "key" and p1 == 28 then
			term.clear()
			term.setCursorPos(1, 1)
			return true
		elseif id == "timer" and p1 == timer then
			duration = duration - 1
			timer = os.startTimer(1)
		end
	until duration < 0
	term.clear()
	term.setCursorPos(1, 1)
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
	if back == nil then
		back = 1
	end

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
	else
		return false
	end
end

local function isFrontBlock(block)
	local has_block, data = turtle.inspect()
	if not has_block then
		return false
	end

	if data.name == block or data[block] then
		return true
	end
end

local function isBottomBlock(block)
	local has_block, data = turtle.inspectDown()
	if not has_block then
		return false
	end

	if data.name == block or data[block] then
		return true
	end
end

local function isTopBlock(block)
	local has_block, data = turtle.inspectUp()
	if not has_block then
		return false
	end

	if data.name == block or data[block] then
		return true
	end
end

local function checkForEmptySlot()
	-- if there is no material, select next slot
	-- could use better name :-)
	while turtle.getItemCount(turtle.getSelectedSlot()) == 0 and turtle.getSelectedSlot() < 16 do
		turtle.select(turtle.getSelectedSlot() + 1)
	end
end

-- legacy function, checking if there is dirt on sapling position
local function plantTree()
	turtle.select(slot.sapling)

	if turtle.getItemCount() > 1 then
		if not turtle.placeDown() then --must have not been able to place a sapling
			moveDown()
			turtle.select(slot.dirt)

			if not turtle.compareDown() then
				turtle.digDown()
			end

			turtle.placeDown()
			turtle.select(slot.sapling)
			moveUp()
			turtle.placeDown()
		end
	end
end

-- you are looking at the very core of this program :-)
local function chopTree()
	local trunk = 0

	turtle.select(slot.log)

	if turtle.compareDown() then
		turtle.digDown()
	end

	while turtle.compareUp() and trunk < max_trunk_height do
		moveUp()
		trunk = trunk + 1
	end

	moveDown(trunk)
end

local function checkTree()
	turtle.select(slot.log)
	if turtle.compare() then
		moveForward()
		chopTree()
		plantTree()
		return true
	else
		--[[moveForward()
		--prevent broken trees
		if turtle.compareDown() or turtle.compareUp() then
			chopTree()
			plantTree()
		end

		if inspect("down", "name") ~= "minecraft:sapling" then
			plantTree()
		end --]]
		return false
	end
end

-- compare block with navigation items
local function checkWall()
	local last_slot = turtle.getSelectedSlot()
	for i = 12, 16 do
		turtle.select(i)
		if turtle.getItemCount() > 0 then
			if turtle.compare() then
				turtle.select(last_slot)
				return i
			end
		end
	end
	turtle.select(last_slot)
end

local function unLoad()
	-- turtle will consume 64 wood(not logs) every time it goes under optimum fuel level
	local function refuel()
		if turtle.getItemCount(slot.log) > 16 then
			redstone.setOutput("top", true)

			for i = 1, 8 do
				turtle.suck()
			end

			turtle.select(slot.sapling)
			turtle.drop()
			turtle.select(slot.dirt)
			turtle.drop()
			turtle.select(slot.to_start)
			turtle.drop()
			turtle.select(slot.front)
			turtle.drop()
			turtle.select(slot.turn)
			turtle.drop()
			turtle.select(slot.back)
			turtle.drop()
			turtle.select(slot.down)
			turtle.drop()

			for i = slot.cobblestone, slot.bucket2 do
				turtle.select(i)
				if turtle.getItemCount() > 0 then
					turtle.drop()
				end
			end

			for i = 1, 2 do
				turtle.select(slot.sapling)
				turtle.equipLeft()
				turtle.select(slot.dirt)
				turtle.equipRight()
			end

			if turtle.craft ~= nil then
				turtle.craft()
				turtle.refuel(64)
				print("fuel: " .. turtle.getFuelLevel())
			end

			turtle.select(slot.sapling)
			turtle.suck()
			turtle.select(slot.dirt)
			turtle.suck()
			turtle.select(slot.to_start)
			turtle.suck()
			turtle.select(slot.front)
			turtle.suck()
			turtle.select(slot.turn)
			turtle.suck()
			turtle.select(slot.back)
			turtle.suck()
			turtle.select(slot.down)
			turtle.suck()
			redstone.setOutput("top", false)
			return true
		else
			return false
		end
	end

	--unload wood
	turtle.select(slot.log)
	for i = slot.cobblestone, 11 do
		if turtle.compareTo(i) then
			turtle.select(i)
			if turtle.getItemCount() > 1 then
				if not turtle.dropDown() then
					message = "wood_chest_full"
					return
				end
			end
			turtle.select(slot.log)
		end
	end

	--unload rest (mainly for saplings)
	if starting_position == "left" then
		turtle.turnLeft()
	elseif starting_position == "right" then
		turtle.turnRight()
	end

	turtle.select(slot.sapling)
	for i = slot.cobblestone, slot.bucket2 do
		--if turtle.compareTo(i) then
		turtle.select(i)
		if turtle.getItemCount() > 0 then
			if not turtle.drop() then
				message = "sapling_chest_full"
				return
			end
		end
		turtle.select(slot.sapling)
		--end
	end

	if needToRefuel() then
		refuel()
	end

	if starting_position == "left" then
		turtle.turnRight()
	elseif starting_position == "right" then
		turtle.turnLeft()
	end
end

-- could use some refactoring
local function farmTrees()
	local max_move = 250 -- not very effective attempt to prevent rogue turtles
	while max_move > 1 do
		turtle.select(slot.sapling)
		while isFrontBlock(game_item.leaves) do
			moveForward()
			turtle.select(slot.sapling)
			if turtle.getItemCount() > 1 then
				turtle.placeDown()
			end

			--protection against rogue turtles
			if isBottomBlock(game_item.chest) then
				while not isFrontBlock(game_item.chest) do
					turtle.turnLeft()
				end
				if starting_position == "left" then
					turtle.turnRight()
				elseif starting_position == "right" then
					turtle.turnLeft()
				end
				unLoad()
			end

			if turtle.detectDown() then
				turtle.select(slot.log)
				if turtle.compareDown() then
					chopTree()
				end
				turtle.select(slot.sapling)
			end
		end

		if not checkTree() and turtle.detect() then
			local wall_number = checkWall()

			if wall_number == slot.front then
				turtle.turnRight()

				if isFrontBlock(game_item.leaves) then
					turtle.dig()
				end

				local steps = 0
				while not turtle.detect() and steps < 3 do
					moveForward()
					if isFrontBlock(game_item.leaves) then
						turtle.dig()
					end
					steps = steps + 1
				end

				if not turtle.detect() then
					turtle.turnRight()
				end
			elseif wall_number == slot.back then
				--heading for opposite wall and then to start
				turtle.turnLeft()
				if isFrontBlock(game_item.leaves) then
					turtle.dig()
				end

				local steps = 0
				while not turtle.detect() and steps < 3 do
					moveForward()
					if isFrontBlock(game_item.leaves) then
						turtle.dig()
					end
					steps = steps + 1
				end

				if not turtle.detect() then
					turtle.turnLeft()
				end
			elseif wall_number == slot.turn then
				--for collecting saplings (turtle go down)
				turtle.turnLeft()
				turtle.turnLeft()
			elseif wall_number == slot.down then
				--last wall before heading to start
				turtle.select(slot.down)

				if isBottomBlock(game_item.leaves) then
					turtle.digDown()
				end

				local travelled = 0
				while not turtle.compareDown() and not isBottomBlock(game_item.water) do
					moveDown()
					if isBottomBlock(game_item.leaves) then
						turtle.digDown()
					end
					travelled = travelled + 1
				end

				if turtle.compareDown() then
					moveUp()
					travelled = travelled - 1
					sleep(1.5)
				end

				turtle.select(slot.sapling)
				while turtle.suckDown() do
					sleep(0.5)
				end

				moveUp(travelled)

				if starting_position == "left" and get_sapling_pos == "front" then
					turtle.turnRight()
				elseif starting_position == "left" and get_sapling_pos == "back" then
					turtle.turnLeft()
				elseif starting_position == "right" and get_sapling_pos == "front" then
					turtle.turnLeft()
				elseif starting_position == "right" and get_sapling_pos == "back" then
					turtle.turnRight()
				end

				if isFrontBlock(game_item.leaves) then
					turtle.dig()
				end

				local steps = 0
				while not turtle.detect() and steps < 3 do
					moveForward()
					if isFrontBlock(game_item.leaves) then
						turtle.dig()
					end
					steps = steps + 1
				end

				if starting_position == "left" and get_sapling_pos == "front" then
					turtle.turnRight()
				elseif starting_position == "left" and get_sapling_pos == "back" then
					turtle.turnLeft()
				elseif starting_position == "right" and get_sapling_pos == "front" then
					turtle.turnLeft()
				elseif starting_position == "right" and get_sapling_pos == "back" then
					turtle.turnRight()
				end
			elseif wall_number == slot.to_start then
				if starting_position == "left" then
					turtle.turnLeft()
				elseif starting_position == "right" then
					turtle.turnRight()
				end

				while not turtle.detect() or isFrontBlock(game_item.leaves) do
					moveForward()
				end

				if starting_position == "left" then
					while turtle.detect() do
						turtle.turnLeft()
						moveForward()
						turtle.turnRight()
					end
				elseif starting_position == "right" then
					while turtle.detect() do
						turtle.turnRight()
						moveForward()
						turtle.turnLeft()
					end
				end

				moveForward()
				turtle.turnLeft()
				turtle.turnLeft()

				if isBottomBlock(game_item.chest) then
					return true
				end
			elseif wall_number == slot.cobblestone then
				error("something wrong")
			else
				moveForward()
			end
		end
		max_move = max_move - 1
	end
end

-- check for item name in inventory
local function checkItemName(slot)
	if slot == nil then
		slot = turtle.getSelectedSlot()
	end
	item = turtle.getItemDetail(slot)
	if item then
		return item.name
	else
		return false
	end
end

-- inventory check, no user input requested
local function checkInv(inventory_table)
	local iterations = 0

	local function checkSlot(slot)
		if inventory_table.quantity[slot] == nil then
			return true
		elseif turtle.getItemCount(slot) < inventory_table.quantity[slot] then
			return false
		elseif checkItemName(slot) ~= inventory_table.name[slot] and inventory_table.name[slot] ~= nil then
			return false
		end

		return true
	end

	for key, value in pairs(inventory_table) do
		iterations = iterations + 1
	end

	for i = 1, 16 do
		if not checkSlot(i) then
			return false
		end
	end
	return true
end

-- item requirement function
-- user input required
local function checkInventory(inventory_table)
	local term_width, term_height = term.getSize()
	local event, p1
	local line_number = 0
	local lines = 1

	local req = 1

	for key, value in pairs(inventory_table) do
		line_number = line_number + 1
	end

	local function checkSlot(slot)
		if inventory_table.quantity[slot] == nil then
			return true
		elseif turtle.getItemCount(slot) < inventory_table.quantity[slot] then
			return false
		elseif checkItemName(slot) ~= inventory_table.name[slot] and inventory_table.name[slot] ~= nil then
			return false
		end

		return true
	end

	while req <= 16 do
		req = 1
		lines = 1

		term.clear()
		term.setCursorPos(1, 1)

		print("Please insert following items into their slots")
		term.setCursorPos(2, 4)
		term.write("Item")
		term.setCursorPos(30, 4)
		term.write("Slot")

		for i = 1, 16 do
			if not checkSlot(i) then
				term.setCursorPos(2, lines + 5)
				term.write(inventory_table.quantity[i])

				term.setCursorPos(5, lines + 5)
				term.write(inventory_table.description[i])

				term.setCursorPos(32, lines + 5)
				term.write(i)
				lines = lines + 1
			else
				req = req + 1
			end
		end

		term.setCursorPos(1, term_height)
		term.write(string.rep(" ", term_width))
		term.setCursorPos(1, term_height)
		term.write("Press q to quit")

		if req <= 16 then
			local event, p1 = os.pullEvent()
			if event == "key" and p1 == 16 then
				term.clear()
				term.setCursorPos(1, 1)
				return false
			end
		end
	end
	term.clear()
	term.setCursorPos(1, 1)
	return true
end

-- veeery long function with farm building instructions
local function makeTreeFarm()
	local function placeCobbleDown(length)
		if length == nil then
			length = 1
		end

		for i = 2, length do
			if not isTopBlock(game_item.chest) then
				turtle.digUp()
			end

			if not turtle.compareDown() then
				turtle.digDown()
				turtle.placeDown()
			end

			checkForEmptySlot()

			moveForward()
		end

		turtle.digUp()
		if not turtle.compareDown() then
			turtle.digDown()
			turtle.placeDown()
		end

		checkForEmptySlot()
	end

	local function placeCobbleAround()
		turtle.turnLeft()

		placeCobbleDown(4)
		turtle.turnRight()
		placeCobbleDown(18)
		turtle.turnRight()
		placeCobbleDown(19)
		turtle.turnRight()
		placeCobbleDown(18)
		turtle.turnRight()
		placeCobbleDown(18)

		turtle.turnRight()
		moveForward()
		moveDown()
	end

	local function placeCobbleFront()
		if not turtle.compare() then
			turtle.dig()
			turtle.place()
		end

		checkForEmptySlot()
	end

	local function layFloor(x, z)
		checkForEmptySlot()

		for r = 1, x do
			placeCobbleDown(z)

			if r % 2 == 1 and r ~= x then
				turtle.turnRight()
				moveForward()
				turtle.turnRight()
			end

			if r % 2 == 0 and r ~= x then
				turtle.turnLeft()
				moveForward()
				turtle.turnLeft()
			end
		end
	end

	local function fillWaterCanal()
		local function fillBucket()
			moveBack()
			sleep(1)
			turtle.select(slot.bucket1)
			turtle.placeDown()
			sleep(1)
			turtle.select(slot.bucket2)
			turtle.placeDown()
		end

		local function fillCanal()
			moveForward(2)
			turtle.select(slot.bucket1)
			turtle.placeDown()

			moveForward(2)
			turtle.select(slot.bucket2)
			turtle.placeDown()
		end

		--prepare for loop
		turtle.select(slot.bucket1)
		turtle.placeDown()

		moveForward(2)
		turtle.select(slot.bucket2)
		turtle.placeDown()

		--loop
		for i = 1, 4 do
			fillBucket()
			fillCanal()
		end

		--finishing
		fillBucket()
		moveForward(2)
		turtle.placeDown()
		moveBack()
		sleep(1)
		turtle.placeDown()
		moveForward()
	end

	local function digMiddleCanal()
		local last_slot
		--prepare
		turtle.turnRight()
		moveForward()
		turtle.turnRight()

		--left side of the canal
		moveDown()
		placeCobbleDown(8)
		moveUp()
		placeCobbleDown(9)
		turtle.turnLeft()
		turtle.turnLeft()
		placeCobbleDown(16)

		--back side of the canal
		turtle.turnRight()
		moveForward()
		turtle.turnLeft()
		turtle.dig()

		last_slot = turtle.getSelectedSlot()
		turtle.select(slot.down)
		placeCobbleFront()
		moveDown()
		placeCobbleFront()
		moveDown()
		placeCobbleFront()
		turtle.select(last_slot)

		turtle.turnLeft()
		turtle.turnLeft()

		--middle of the canal
		last_slot = turtle.getSelectedSlot()
		turtle.select(slot.down)
		placeCobbleDown(1)
		moveForward()
		turtle.select(last_slot)
		placeCobbleDown(7)
		moveForward()
		moveUp()
		placeCobbleDown(8)

		--front side of the canal
		placeCobbleFront()
		moveUp()
		turtle.turnLeft()
		turtle.turnLeft()

		--dig the rest of the middle
		for i = 1, 15 do
			turtle.digUp()
			moveForward()
		end

		turtle.turnRight()
		moveForward()
		turtle.turnRight()

		--right side of the canal
		moveDown()
		placeCobbleDown(8)
		moveUp()
		placeCobbleDown(9)
		turtle.turnLeft()
		turtle.turnLeft()
		placeCobbleDown(16)

		--prepare for next function
		turtle.turnLeft()
		turtle.turnLeft()
		moveForward(15)
		turtle.turnLeft()
		moveForward()
		turtle.turnLeft()
	end

	local function placeDirtandTorches(x_num_trees, z_num_trees, special_line)
		local function placedt()
			turtle.select(slot.dirt)
			turtle.placeDown()
			moveBack()
			-- select torch - same slot as wood logs
			turtle.select(slot.log)
			turtle.placeDown()
		end

		local function placeSpecial()
			turtle.select(slot.dirt)
			turtle.placeDown()
			moveForward()
			turtle.select(slot.log)
			turtle.placeDown()
			moveBack(2)
			turtle.placeDown()
		end

		moveUp(2)
		turtle.turnLeft()
		moveForward(6)
		turtle.turnRight()
		moveBack(2)

		placedt()
		for i = 1, (z_num_trees - 1) do
			moveBack(2)
			placedt()
		end

		for i = 1, x_num_trees - 1 do
			turtle.turnRight()
			moveForward(3)
			turtle.turnLeft()
			moveForward(13)
			if i == special_line - 1 then
				placeSpecial()
			else
				placedt()
			end

			for j = 1, (z_num_trees - 1) do
				moveBack(2)
				if i == special_line - 1 then
					placeSpecial()
				else
					placedt()
				end
			end
		end
	end

	-- make tree farm starts here

	if fuelTooLow() then
		message = "fuel"
		return false
	end

	if not checkInventory(building_req) then
		return false
	end

	moveForward()
	moveDown(2)
	moveBack()
	turtle.select(slot.cobblestone)
	placeCobbleAround()

	layFloor(7, 16)
	digMiddleCanal()
	layFloor(7, 16)

	moveUp()
	turtle.turnRight()
	turtle.turnRight()

	fillWaterCanal()

	turtle.turnRight()
	moveForward(16)
	turtle.turnRight()

	fillWaterCanal()

	turtle.turnRight()
	moveForward(8)
	turtle.turnRight()

	moveForward(7)
	moveDown(2)
	turtle.select(slot.bucket1)
	turtle.placeDown()
	moveUp(2)
	moveForward(8)
	moveDown()
	turtle.select(slot.bucket2)
	turtle.placeDown()

	turtle.turnLeft()
	turtle.turnLeft()
	moveForward(15)

	placeDirtandTorches(5, 5, 3)

	-- build fence
	-- right side
	moveBack()
	moveUp(2)
	turtle.turnRight()
	moveForward(3)
	turtle.turnLeft()
	moveForward()
	turtle.select(slot.turn)
	placeCobbleDown(16)

	-- distant side
	moveForward()
	turtle.turnLeft()
	moveForward()
	turtle.select(slot.front)
	placeCobbleDown(8)

	-- sappling path
	moveForward()
	turtle.select(slot.down)
	moveDown(2)
	turtle.digDown()
	for i = 1, 2 do
		turtle.placeDown()
		moveUp()
	end
	turtle.placeDown()
	moveForward()

	-- left side
	turtle.select(slot.front)
	placeCobbleDown(8)
	moveForward()
	turtle.turnLeft()
	moveForward()
	turtle.select(slot.to_start)
	placeCobbleDown(16)

	-- near side
	moveForward()
	turtle.turnLeft()
	moveForward()
	turtle.select(slot.back)
	placeCobbleDown()
	moveForward(3)
	placeCobbleDown(14)

	moveBack(14)
	turtle.turnLeft()
	moveDown()

	-- get saplings from sapling chest
	turtle.turnLeft()
	turtle.select(slot.sapling)
	turtle.drop()
	turtle.suck()

	for i = 3, 11 do
		turtle.select(i)
		turtle.drop()
	end
	turtle.turnRight()
	turtle.select(slot.log)
	turtle.suckDown()

	if checkInv(felling_req) then
		farmTrees()
	end
end -- end of veery long bulding function

-- session persistence main function
local function restoreSession()
	-- easy position -> over chest or sapling
	if turtle.detectDown() then
		--turtle was waiting in starting position
		if isBottomBlock(game_item.chest) then
			--turtle is on top of sapling, which is ok and can continue safely
			while not isFrontBlock(game_item.chest) do
				turtle.turnLeft()
			end
			if starting_position == "left" then
				turtle.turnRight()
			elseif starting_position == "right" then
				turtle.turnLeft()
			end
			return
		elseif isBottomBlock(game_item.sapling) then
			return
		end
	end

	--are we cutting three?
	turtle.select(slot.log)
	if turtle.compareUp() then
		chopTree()
		turtle.select(slot.dirt)
		while not turtle.compareDown() do
			moveDown()
		end
		moveUp()
		plantTree()
		return
	end

	-- we were going for saplings
	turtle.select(slot.down)
	if turtle.compare() then
		while turtle.compare() do
			moveUp()
		end
		moveDown()
		return
	end

	local moves = 0
	if not turtle.detectDown() then
		moveDown()
		moves = moves + 1
	end

	-- we got wrong altitude while returning from collecting saplings
	turtle.select(slot.down)
	if turtle.compare() then
		return
	end

	-- we must be somewhere in the air
	while not turtle.detectDown() or isBottomBlock(game_item.leaves) do
		moveDown()
		moves = moves + 1
	end

	turtle.select(slot.down)
	if turtle.compareDown() then
		while not turtle.compare() do
			turtle.turnLeft()
		end
		while turtle.compare() do
			moveUp()
		end
		moveDown()
		return
	end

	--we were above dirt block
	turtle.select(slot.dirt)
	if turtle.compareDown() then
		-- if there is torch under turtle
		moveUp(moves + 1)
		turtle.select(slot.log)
		if turtle.compareUp() then
			chopTree()
			turtle.select(slot.dirt)
			while not turtle.compareDown() do
				moveDown()
			end
			moveUp()
			plantTree()
			return
		else
			turtle.select(slot.dirt)
			while not turtle.compareDown() do
				moveDown()
			end
			moveUp()
			plantTree()
			return
		end
	elseif isBottomBlock(game_item.torch) then
		moveUp()
		return
	else
		-- we are just under water, let get back to working altitude
		moveUp(working_altitude - 1)
		return
	end
end

local function startLumberjacking()
	if checkInventory(felling_req) then
		restoreSession()

		while not fuelTooLow() do
			if isBottomBlock(game_item.chest) then
				turtle.select(slot.log)
				if turtle.getItemCount() > 1 and not turtle.dropDown(1) then
					message = "wood_chest_full"
					return
				else
					turtle.suckDown(1)
				end
			end
			farmTrees()
			unLoad()
			if cancelTimer(wait_for_saplings, "Waiting for saplings") then
				break
			end
		end
	end
end

local function farmTreesOnce()
	if checkInventory(felling_req) then
		restoreSession()

		if isBottomBlock(game_item.chest) then
			if fuelTooLow() then
				message = "fuel"
				return false
			end

			turtle.select(slot.log)
			if turtle.getItemCount() > 1 and not turtle.dropDown(1) then
				message = "wood_chest_full"
				return
			else
				turtle.suckDown(1)
			end
		end
		farmTrees()
		unLoad()
		return true
	else
		return false
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
			options = {"Harvest trees just once", "Start harvesting loop", "Build tree farm", startup, "Quit"},
			job = {farmTreesOnce, startLumberjacking, makeTreeFarm, modifyStartup, "quit"}
		}
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
				options = {"Harvest trees just once", "Start harvesting loop", "Build tree farm", startup, "Quit"},
				job = {farmTreesOnce, startLumberjacking, makeTreeFarm, modifyStartup, "quit"}
			}
		}

		term.clear()
		printFuelLevel()
		printStatus()

		for i = 1, #menu[menustate].options do
			if i == selected then
				printCentered("[ " .. menu[menustate].options[i] .. " ]", term_height / 2 - #menu[menustate].options + i * 2)
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

if turtle.craft == nil then
	message = "not_crafty"
end

if args[1] == "update" then
	update()
	return
elseif args[1] == "left" or args[1] == "right" then
	starting_position = args[1]
elseif args[1] == "help" then
	term.clear()
	term.setCursorPos(1, 1)
	print("update for program update")
	print("left or right for starting position")
	print("front or back for saplings collection")
	print("number for waiting between loops")
	print("nomenu to start working without menu")
	print("")
	print("examples:")
	print("")
	print("woody update")
	print("woody left front 180 nomenu ")
	return
end

if args[2] then
	if args[2] == "left" or "right" or "front" or "back" then
		get_sapling_pos = args[2]
	end
end
if args[3] then
	wait_for_saplings = args[3]
end

if args[4] then
	if args[4] == "skipmenu" then
		if not cancelTimer(sleep_on_startup, "Countdown to start") then
			startLumberjacking()
		end
	end
end

runMenu()

-- notes, ToDo
-- in czech :-P

-- spotřeba paliva 220

-- efektivní výška borovic je 10, šířka 5 - 2 na každou stranu
-- 25 stromů, 154 dřeva cca 240sec., 340 paliva
-- farmy se dají vrstvit nad sebou - stačí postavit sloup o výšce 15
-- pokud se dobře pamatuju, tak čistá práce - těžení trvá 100s

-- velikost farmy: šířka: 19, délka 17, výška 6

-- výpis stavu by měl být vypsaný furt vč paliva, plus co se zrovna dělá

-- překopat stavbu kanálů farmy
-- fillwatercanal potřebuje variabilní vstup
-- možnost zastavit želvu uprostřed práce

-- border blocky nesmí být stejné

-- feature - collect saplings nemusí být jen na jednom místě, ale na několika!

-- protection from full saplings chest while using refuel
