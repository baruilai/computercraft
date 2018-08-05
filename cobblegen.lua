-- Cobblestone generator

-- check inventory

-- bug - nad pravou částí truhly nesmí být solid block, jinak nepude otevřít
-- bug - želva nevyčistí prostor, pokud pracuje v podzemí
-- na začátku v komentářích: název, k čemu slouží, autor, licence

-- update v menu je špatně, vymyslet způsob jak se updatovat a znovu spustit nebo tu položku vypustit
-- update může rozbít program, pokud neexistuje připojení k webu

-- nápad -> uložit update program na pastebin, stáhnout update program, spustit update, update smaže původní program, updatuje ho a spustí, nový program smaže update

-- start protekce stačí čtyřikrát, nepoužívat while loop, pokud nenajdu cobble tak vypsat hlášku

-- stavění jde udělat určitě jinak - funkce se smyčkou vykonává krok po kroku instrukce z tabulky nebo jiných dat... každý krok může být přerušen

local pastebin_code = "2Dzm73eb"
local slot = {blocks = 1, chest = 2, water = 3, lava = 4}

local args = {...}
local min_fuel_req = 80
local min_block_req = 54

local bEnd = false
--[[local message = {
	fuel = "Turtle has no fuel!", full = "Chest is full!", position = "No cobblestone to mine", 
	material = "No building material", water = ""
	}

		if message == "fuel" then
			term.write("Turtle has no fuel!")
		elseif message == "full" then
			term.write("Chest is full!")
		elseif message == "position" then
			term.write("No Cobblestone to mine")
		end
]]

local function update()
	-- first let me delete myself
	print(fs.delete(shell.getRunningProgram()))

	-- Now get the program from pastebin.com
	-- Format: pastebin get (pasteid) (destination)
	-- not so simple way to get name of this program without path
	shell.run("pastebin get "..pastebin_code.." "..fs.getName(shell.getRunningProgram()))
end

local function requestAssistance(problem)
		print(problem)
		print("press enter to continue")
 
		while true do
				event, key = os.pullEvent("key")
 
				if key == keys.enter then
						term.clear()
						term.setCursorPos(1, 1)
						print("thank you")
						sleep(1.5)
						term.clear()
						term.setCursorPos(1, 1)
						return
				end
		end
end

local function moveForward(forward)
	if forward == nil then forward = 1 end

	for i = 1, forward do

		if turtle.detect() then 
			turtle.dig() 
		end

		--mob protection
		while not turtle.forward() do
			if not turtle.detect() then
				turtle.dig()
				sleep(0.5)
			else
					turtle.attack()
			end
		end
	end
end

local function moveUp(up)
	if up == nil then up = 1 end
 
	for i = 1, up do

		if turtle.detectUp() then 
			turtle.digUp() 
		end

		--mob protection
		while not turtle.up() do
			if not turtle.detect() then
				turtle.digUp()
				sleep(0.5)
			else
				turtle.attackUp()
			end
		end
	end
end
 
local function moveDown(down)
	if down == nil then down = 1 end

	for i = 1, down do

		if turtle.detectDown() then 
			turtle.digDown() 
		end

			--mob protection
			while not turtle.down() do
				if not turtle.detect() then
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

local function placeSolidBlock(direction)

	if direction == "up" then
		if not turtle.compareUp() and turtle.detectUp() then
			turtle.digUp()
		end
		while not turtle.placeUp() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
			turtle.attackUp()
		end
	elseif direction == "front" then
		if not turtle.compare() and turtle.detect() then
			turtle.dig()
		end
		while not turtle.place() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
			turtle.attack()
		end
	elseif direction == "down" then
		if not turtle.compareDown() and turtle.detectDown() then
			turtle.digDown()
		else
			while not turtle.placeDown() and not turtle.detectDown() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
				turtle.attackDown()
				print("attack")
			end
		end

		--if we use sand or gravel for drying water or lava lake
		while not turtle.detectDown() do
			turtle.placeDown()
		end

	elseif direction == "down_clear_up" then
		if not turtle.compareDown() and turtle.detectDown() then
			turtle.digDown()
		else
			while not turtle.placeDown() and not turtle.detectDown() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
				turtle.attackDown()
				print("attack")
			end
		end
		if turtle.detectUp() then turtle.digUp() end

		while not turtle.detectDown() do
			turtle.placeDown()
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
	end
 
		--place x number of lines
		for r = 1, x do
 
			placeBlock(z)
				
			if r ~= x then
				if r%2 == 0 then
						turtle.turnLeft()
						moveForward()
						turtle.turnLeft()
				else
						turtle.turnRight()
						moveForward()
						turtle.turnRight()
				end
			end
		end
 
		--return to start
		if go_to_start == true then
				if isEven(x) then
						turtle.turnRight()
						moveForward(x - 1)
						turtle.turnRight()
				end
 
				if not isEven(x) then
						moveBack(z - 1)
						turtle.turnLeft()
						moveForward(x - 1)
						turtle.turnRight()
				end
		end
end

local function makeCobbleGenerator()
	term.clear()
	term.setCursorPos(1, 1)

	if turtle.getFuelLevel() < 80 then
		message = "fuel"
		return
	end

	print("Making cobblestone generator")
	print("please stay around")

	turtle.select(slot.blocks)

	-- prepare for flooring
	moveDown()
	turtle.turnRight()
	moveForward(2)
	turtle.turnRight()
	moveForward(2)
	turtle.turnRight()
	laySurface(5, 6, "down_clear_up")

	-- second layer
	moveBack()
	moveUp()
	turtle.turnLeft()
	moveForward()
	laySurface(1, 3, "down")
	moveForward()
	turtle.turnLeft()
	moveForward()
	placeSolidBlock("down")
	turtle.turnLeft()
	moveForward(3)
	placeSolidBlock("down")
	turtle.turnRight()
	moveForward()
	turtle.turnRight()
	laySurface(1, 3, "down")

	-- drainage for water
	moveBack()
	turtle.turnLeft()
	moveForward()
	moveDown(2)
	placeSolidBlock("down")

	-- third layer
	moveUp(3)
	moveForward()
	turtle.select(slot.chest)
	placeSolidBlock("down")
	moveBack()
	placeSolidBlock("down")

	turtle.turnLeft()
	turtle.select(slot.blocks)
	moveForward(2)
	turtle.turnLeft()
	moveForward()
	laySurface(1, 3, "down")
	moveForward()
	turtle.turnLeft()
	moveForward()
	placeSolidBlock("down")
	moveForward(2)
	placeSolidBlock("down")
	moveForward()
	turtle.turnLeft()
	moveForward()
	placeSolidBlock("down")
	turtle.turnLeft()
	moveForward(2)
	turtle.turnLeft()
	placeSolidBlock("front")
	placeSolidBlock("down")
	moveBack()
	placeSolidBlock("down")
	turtle.turnLeft()
	placeSolidBlock("front")
	turtle.turnRight()
	turtle.turnRight()
	placeSolidBlock("front")
	turtle.turnLeft()
	moveBack()
	placeSolidBlock("down")
	moveBack()
	placeSolidBlock("front")
	turtle.turnLeft()
	placeSolidBlock("front")
	turtle.turnLeft()

	-- place water and lava
	moveUp()
	turtle.select(slot.water)
	turtle.placeDown()
	moveBack(2)
	turtle.select(slot.lava)
	turtle.placeDown()

	-- move to working position
	moveForward()
	turtle.turnLeft()
	moveBack()
	moveDown(2)
	moveForward()
	turtle.digUp()
	turtle.dig()
	turtle.digDown()
end

local function unload()
	turtle.turnRight()
	
	for i = 1, 16 do
		if turtle.getItemCount(i) > 0 then
			turtle.select(i)
			if not turtle.drop() then
				turtle.turnLeft()
				message = "full"
				return false
			end
		end
	end
	turtle.select(1)
	turtle.turnLeft()
	message = nil
	return true
end

function mineCobble()
		turtle.select(1)

		while not bEnd do

			if turtle.detect() then
				turtle.dig()
			elseif turtle.detectUp() then
				turtle.digUp()
			elseif turtle.detectDown() then
				turtle.digDown()
			end

			if turtle.getItemCount(turtle.getSelectedSlot()) == 64 then
				bEnd = not unload()
			end
		end
end

local function getKey()
	while not bEnd do
		local event, key = os.pullEvent("key")
		if key ~= keys.escape then
			bEnd = true
		end
	end     
end

local function mine()
	term.clear()
	term.setCursorPos(1, 1)

	-- in case of turtle got unloaded while facing chest
	loops = 1
	while inspect("front", "name") ~= "minecraft:cobblestone" and loops < 5 do
		turtle.turnLeft()
		loops = loops + 1
	end
	if loops == 5 and inspect("up", "name") ~= "minecraft:cobblestone" and inspect("down", "name") ~= "minecraft:cobblestone" then
		message = "position"
		return
	end

	if turtle.getItemCount(turtle.getSelectedSlot()) > 0 then
		bEnd = not unload()
		if bEnd then return end
	end

	print("Press any key to enter menu")

	parallel.waitForAny(getKey, mineCobble)
	term.clear()
	term.setCursorPos(1, 1)
end

local function runMenu()
	local startup
	if fs.exists("startup") then
		startup = "Delete startup file"
	else
		startup = "Create startup file"
	end

	local function modifyStartup()
		if fs.exists("startup") then
			fs.delete("startup")
			startup = "Create startup file"
		else
			local file = fs.open("startup","w")
			file.write('shell.run("' .. fs.getName(shell.getRunningProgram()) .. '", "nomenu")')
			file.close()
			startup = "Delete startup file"
		end
	end

	local function checkStartup()
		if fs.exists("startup") then
			return "Delete startup file"
		else
			return "Create startup file"
		end
	end

	local menu = {
		["main"] = {
			options =   {"Start mining",    "Build cobblestone generator",  startup,        "Update",   "Quit"},
			job =       {mine,              makeCobbleGenerator,            modifyStartup,  update,     "quit"}
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
		local message = "Fuel: " .. turtle.getFuelLevel()
		term.setCursorPos(term_width - #message, 1)
		term.write(message)
	end

	local function printStatus()
		term.setCursorPos(1, 1)
		if message == "fuel" then
			term.write("Turtle has no fuel!")
		elseif message == "full" then
			term.write("Chest is full!")
		elseif message == "position" then
			term.write("No Cobblestone to mine")
		end
	end

	while true do
		--this is only to update startup entry, probably should use menu["main"].options[3] = startup
		menu = {
			["main"] = {
				options =   {"Start mining",    "Build cobblestone generator",  startup,        "Update",   "Quit"},
				job =       {mine,              makeCobbleGenerator,            modifyStartup,  update,     "quit"}
			}
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
		elseif key == keys.down and selected == #menu[menustate].options then
			selected = 1
		elseif key == keys.up and selected > 1 then
			selected = selected - 1
		elseif key == keys.up and selected == 1 then
			selected = #menu[menustate].options
		elseif key == keys.enter then
			if type(menu[menustate].job[selected]) == "function" then
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
elseif args[1] == "build" then
	makeCobbleGenerator()
elseif args[1] == "nomenu" then
	mine()
end

runMenu()