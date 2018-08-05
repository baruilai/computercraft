-- Cobblestone generator

-- na začátku v komentářích: název, k čemu slouží, autor, licence

-- okomentovat kód

-- update v menu je špatně, vymyslet způsob jak se updatovat a znovu spustit nebo tu položku vypustit

-- start protekce stačí čtyřikrát, nepoužívat while loop, pokud nenajdu cobble tak vypsat hlášku

-- stavění jde udělat určitě jinak - funkce se smyčkou vykonává krok po kroku instrukce z tabulky nebo jiných dat... každý krok může být přerušen

local pastebin_code = "2Dzm73eb"
local sleep_on_start = 3 -- neimplementováno, pokud se jmenuji startup, tak spát, aby se předešlo lagům

local min_fuel_req = 80
local min_block_req = 52
local min_chest_req = 2

local slot = {blocks = 1, chest = 2, water = 3, lava = 4}
local args = {...}
local bEnd = false

local message
local error_notification = {
	fuel = "Turtle needs more fuel",
	full = "Chest is full",
	position = "No cobblestone to mine",
}

local cob_gen_req = {
	quantity = {52, 2, 1, 1},
	name = {nil, nil, "minecraft:water_bucket", "minecraft:lava_bucket"},
	description = {"non-flammable blocks", "chests", "bucket with water", "bucket with lava"},
}

local cobble_generator = {
	{
	"000000",
	"000000",
	"010000",
	"000000",
	"000000",
	},
	{
	"111111",
	"111111",
	"101111",
	"111111",
	"111111",
	},
	{
	"000100",
	"001010",
	"001010",
	"001110",
	"000000",
	},
	{
	"000010",
	"000001",
	"221110",
	"000001",
	"001110",
	},
	{
	"000000",
	"010100",
	"001001",
	"000100",
	"000000",
	},
}

local function update()
	--befora we try to delete ourself, just check the connection OK?
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

local function checkItemName(slot)
	if slot == nil then slot = turtle.getSelectedSlot() end
	item = turtle.getItemDetail(slot)
	if item then
		return item.name
	else
		return false
	end
end

local function checkInventory(slot)
	--for i = 1, #inventory.quantity do
		if turtle.getItemCount(slot) < cob_gen_req.quantity[slot] then
			return false
		elseif checkItemName(slot) ~= cob_gen_req.name[slot] and cob_gen_req.name[slot] ~= nil then
			return false
		end
	--end
	return true
end

local function PD(slot_number)
	if slot_number == 0 then return end
	if turtle.getItemCount(turtle.getSelectedSlot) ~= slot_number then
		turtle.select(slot_number)
	end

	if not turtle.compareDown() and turtle.detectDown() then
		turtle.digDown()
	end

	while not turtle.placeDown() and not turtle.detectDown() and turtle.getItemCount(turtle.getSelectedSlot) > 0 do
		turtle.attackDown()
		print("attack")
	end
end

local function build(scheme)
	for x = 1, #scheme do 
		for y = 2, #scheme[x], 2 do
			scheme[x][y] = string.reverse(scheme[x][y])
		end
	end

	for x = 2, #scheme, 2 do 
		for y = 1, #scheme[x] do
			scheme[x][y] = string.reverse(scheme[x][y])
		end
		for y = 1, #scheme[x] / 2 do
			scheme[x][y], scheme [x][#scheme + 1 - y] = scheme [x][#scheme + 1 - y], scheme[x][y]
		end
	end
	
	for k = 1, #scheme do
		for j = 1, #scheme[k] do
			PD(tonumber(string.sub(scheme[k][j], 1, 1)))
			for i = 2, #scheme[k][j] do
				moveForward()
				PD(tonumber(string.sub(scheme[k][j], i, i)))
			end

			if j % 2 == 1 and j ~= #scheme[k] then 
				turtle.turnRight()
				moveForward()
				turtle.turnRight()
			end

			if j % 2 == 0 and j ~= #scheme[k] then
				turtle.turnLeft()
				moveForward()
				turtle.turnLeft()
			end
		end
		if k ~= #scheme then
			moveUp()
			turtle.turnLeft()
			turtle.turnLeft()
		end
	end
end

local function inventoryCheck()
	local term_width, term_height = term.getSize()
	local loop = 1
	local event, p1

	while loop <= #cob_gen_req.quantity do
		loop = 1

		term.clear()
		term.setCursorPos(1, 1)

		print("Please insert following items into their slots")
		term.setCursorPos(2, 4)
		term.write("Item")
		term.setCursorPos(30, 4)
		term.write("Slot")

		term.setCursorPos(1, term_height)
		term.write("Press q to quit")
		for i = 1, #cob_gen_req.quantity do
			if not checkInventory(i) then

				term.setCursorPos(2, i + 5)
				term.write(cob_gen_req.quantity[i])

				term.setCursorPos(5, i + 5)
				term.write(cob_gen_req.description[i])

				term.setCursorPos(32, i + 5)
				term.write(i)
				loop = loop - 1
			else
				loop = loop + 1
			end
		end
		if loop <= #cob_gen_req.quantity then 
			event, p1 = os.pullEvent()
			if event == "key" and p1 == 16 then
				return false
			end
		end
	end
	return true
end

local function buildCoGen()
	if turtle.getFuelLevel() < min_fuel_req then
		message = "fuel"
		return false
	else
		message = nil
	end

	if inventoryCheck() then
		term.clear()
		term.setCursorPos(1, 1)
		print("Building cobblestone generator,")
		print("please stay within loaded area")

		-- going to starting position
		turtle.turnRight()
		moveForward(2)
		turtle.turnRight()
		moveForward(2)
		turtle.turnRight()
		moveDown(2)

		-- build entire cobble generator
		build(cobble_generator)

		-- finishing moves
		moveBack(2)
		turtle.turnLeft()
		moveForward(2)

		turtle.select(slot.lava)
		turtle.placeDown()

		turtle.turnLeft()
		moveForward(2)

		turtle.select(slot.water)
		turtle.placeDown()

		moveBack()
		turtle.turnLeft()
		moveBack()
		moveDown(2)
		moveForward()

		turtle.digUp()
		turtle.dig()
		turtle.digDown()
	end
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
	else 
		message = nil
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
			job =       {mine,              buildCoGen,     		       modifyStartup,  	update,     "quit"}
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
		local fuel_report = "Fuel: " .. turtle.getFuelLevel()
		term.setCursorPos(term_width - #fuel_report, 1)
		term.write(fuel_report)
	end

	local function printStatus()
		if message then
			term.setCursorPos(1, 1)
			term.write(error_notification[message])
		end
	end

	while true do
		--this is only to update startup entry, probably should use menu["main"].options[3] = startup
		local menu = {
			["main"] = {
				options =   {"Start mining",    "Build cobblestone generator",  startup,        "Update",   "Quit"},
				job =       {mine,              buildCoGen,     		       modifyStartup,  	update,     "quit"}
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