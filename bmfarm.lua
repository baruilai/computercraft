--9x9 bazén
--sapling, drevo, hlina
--jine nastaveni pro borovice a pro brizu

--borovice - trees = 6, saplings = 6 is ok
--briza - trees = 4, saplings = 5

local sapling_slot = 1
local wood_slot = 2
local dirt_slot = 3
local bonemeal_slot = 4

local minimum_trees = 5
local minimum_aquired_saplings = 6
local last_bonemeal = 9
local maximum_waiting_time = 12 --x10 seconds, ie. 12 = 120seconds

local minimum_required_saplings = 10
local minimum_fuel = 100
local optimum_fuel = 2000
local countdown = 5

local bonemeal_now = bonemeal_slot

local function moveForward(frwd)
	if frwd == nil then frwd = 1 end

	for i = 1, frwd do

		if turtle.detect() then	turtle.dig() end

		--mob protection
		while not turtle.forward() do 
		sleep(1) 
		turtle.dig()
		end 
	end
end

local function moveUp(up)
	if up == nil then up = 1 end

	for i = 1, up do

		if turtle.detectUp() then turtle.digUp() end

		--mob protection
		while not turtle.up() do 
		sleep(1) 
		turtle.digUp()
		end 
	end
end

local function moveDown(dwn)
	if dwn == nil then dwn = 1 end
	
	for i = 1, dwn do

		if turtle.detectDown() then turtle.digDown() end

		--mob protection
		while not turtle.down() do 
		sleep(1) 
		turtle.digDown()
		end 
	end
end

local function moveBack(bck)
	if bck == nil then bck = 1 end

	for i = 1, bck do

		while not turtle.back() do 
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.dig()
		turtle.turnLeft()
		turtle.turnLeft()
		end 
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

local function plantSapling()
	turtle.select(sapling_slot)
	turtle.place()
end

local function unLoad()
	--go to chests position
	moveDown(2)
	moveBack(4)
	
	--unload wood
	turtle.turnLeft()
	turtle.select(wood_slot)
	for i = bonemeal_slot, 16 do
		if turtle.compareTo(i) then
			turtle.select(i)
			if not turtle.drop() then
     			requestAssistance("Chest for wood is full")
  			end
			turtle.select(wood_slot)
		end
	end

	--unload saplings
	turtle.turnLeft()
	turtle.select(sapling_slot)
	for i = bonemeal_slot, 16 do
		if turtle.compareTo(i) then
			turtle.select(i)
			if not turtle.drop() then
				requestAssistance("Chest for saplings is full")
			end
			turtle.select(sapling_slot)
		end
	end

	--refuel if needed
	if turtle.getFuelLevel() < optimum_fuel and turtle.getItemCount(wood_slot) > 16 then
		if (peripheral.getType("left") == "workbench" or peripheral.getType("right") == "workbench") then
			turtle.turnLeft()
			turtle.turnLeft()
			turtle.select(sapling_slot)
			turtle.drop()
			turtle.select(dirt_slot)
			turtle.drop()
			turtle.craft()
			turtle.refuel(64)
			turtle.select(sapling_slot)
			turtle.suck()
			turtle.select(dirt_slot)
			turtle.suck()
			turtle.turnLeft()
			turtle.turnLeft()
		elseif turtle.getFuelLevel() < minimum_fuel then
			requestAssistance("We are run out of fuel")

		end
	end

	--get bonemeal
	turtle.turnLeft()
	for i = bonemeal_slot, 16 do
		turtle.select(i)
		while turtle.getItemCount(i) < 64 and turtle.getItemCount(last_bonemeal) == 0 do
			if not turtle.suck() then
				if turtle.getItemCount(bonemeal_slot) > 0 then
					break
				else
					requestAssistance("We are run out of bonemeal")
				end
			end
		end
	end
	bonemeal_now = bonemeal_slot

	turtle.turnLeft()
	moveForward(4)
	moveUp(2)
end

local function useBonemeal()
	turtle.select(bonemeal_now)
	local i = bonemeal_now
	while turtle.getItemCount(bonemeal_now) == 0 and i < 16 do
		bonemeal_now = bonemeal_now + 1
		i = i + 1
	end
	turtle.select(bonemeal_now)

	local used_bonemeal = turtle.place()

	if not used_bonemeal then
		if bonemeal_now == 16 then
			unLoad()
		elseif bonemeal_now < 16 then
			bonemeal_now = bonemeal_now + 1
			turtle.select(bonemeal_now)
		end
	end
end

local function makeTree()
	plantSapling()
	turtle.select(wood_slot)

	while not turtle.compare() do
		useBonemeal()
		turtle.select(wood_slot)
	end
end

local function harvestTree()
	local trunk = 0

	turtle.select(wood_slot)

	while turtle.compareUp() do
		moveUp()
		trunk = trunk + 1

		turtle.select(sapling_slot)
		turtle.dig()
		turtle.select(wood_slot)
	end

	moveDown(trunk)
end

function getSaplings()
	local saplings_before = turtle.getItemCount(sapling_slot)
	local saplings_after = saplings_before + minimum_aquired_saplings

	moveDown(2)
	moveForward()

	turtle.select(sapling_slot)

	local i = 1
	while turtle.getItemCount(sapling_slot) < saplings_after and i < maximum_waiting_time and turtle.getItemCount(sapling_slot) ~= 64 do
		if turtle.suckDown() then
			print(turtle.getItemCount(sapling_slot) - saplings_before)
		end
		sleep(10)
		i = i + 1
		print((i * 10).."sekund")
	end

	moveBack()
	moveUp(2)
end	

local function farmTrees()
	
	while turtle.getItemCount(sapling_slot) > 10 and turtle.getFuelLevel() > minimum_fuel do

		for i = 1, minimum_trees do
			makeTree()
			moveForward()
			harvestTree()
			moveBack()
		end

		getSaplings()

		if turtle.getItemCount(16) > 0 or turtle.getFuelLevel() < minimum_fuel then
			unLoad()
		end

	end
end

function cancelTimer(duration, text)
	timer = os.startTimer(1)
	repeat
		term.clear()
		term.setCursorPos (1, 1)
		print(text)
		print("Press enter to end program.")
		print(duration)
		 
		local id, p1 = os.pullEvent()
		if id == "key" and p1 == 28 then error()
		elseif id == "timer" and p1 == timer then
		duration = duration-1
		timer = os.startTimer(1)
		end

	until duration < 0
	term.clear()
	term.setCursorPos (1, 1)
	return false
end

local function restoreSession()
	cancelTimer(countdown, "Turtle will now restore session")

	turtle.select(dirt_slot)

	--in front of dirt block
	if turtle.compare() then
		moveUp()
		return
	end

	--under dirt block
	if turtle.compareUp() then
		moveBack()
		moveUp(2)
		return
	end

	--on top of dirt block
	if turtle.compareDown() then
		turtle.select(wood_slot)
		if turtle.compareUp() then
			harvestTree()
			moveBack()
			return
		else --check if there is partially cut tree
			moveUp()
			if turtle.compareUp() then
				harvestTree()
				moveDown()
				moveBack()
				return
			else
				moveDown()
				moveBack()
				return
			end
		end
	end

	--turtle is between chests
	if turtle.detectDown() and not turtle.compareDown() then
		while turtle.detect() do
			turtle.turnLeft()
		end

		while not turtle.compareUp() do
			moveForward()
		end
		moveBack()
		moveUp(2)
		return
	end

	--somewhere in the air
	if not turtle.detectDown() then

		--are we cutting three?
		turtle.select(wood_slot)
		if turtle.compareUp() then
			harvestTree()
			turtle.select(dirt_slot)
			while not turtle.compareDown() do
				moveDown()
			end
			moveBack()
			return
		else  --lets check for patrially cut tree
			moveUp()
			if turtle.compareUp() then
				harvestTree()
				turtle.select(dirt_slot)
				while not turtle.compareDown() do
					moveDown()
				end
				moveBack()
				return
			end
			moveDown()
		end

		--there is not partially cut tree, let's go down
		turtle.select(dirt_slot)
		while not turtle.detectDown() do
			moveDown()
			--what if we were in the starting possition?
			if turtle.compare() then
				moveUp()
				return 
			end
		end

		--turtle finished cutting tree
		if turtle.compareDown() then
			moveBack()
			return
		end

		--turtle was on the way to starting possition
		if turtle.detectDown() and not turtle.compareDown() then
			moveUp()
			while not turtle.compareUp() do
				moveForward()
			end
			moveBack()
			moveUp(2)
			return
		end
	end
end

local function checkInventory()
	term.clear()
	term.setCursorPos(1, 1)
	while turtle.getItemCount(sapling_slot) < minimum_required_saplings do
		print("Not enought saplings.")
		print("Minimum required saplings is " .. minimum_required_saplings)
		requestAssistance("Please insert saplings into slot number " .. sapling_slot)
	end
	while turtle.getItemCount(wood_slot) == 0 do
		print("Turtle has no wood in correct slot")
		requestAssistance("Please insert some wood of chosen type into slot number " .. wood_slot)
	end
	while turtle.getItemCount(dirt_slot) == 0 do
		print("Turtle has no dirt in correct slot")
		requestAssistance("Please insert at least one dirt into slot number " .. dirt_slot)
	end
end

checkInventory()
restoreSession()
farmTrees()
getSaplings()
unLoad()

if turtle.getFuelLevel() < 100 then
	print("turtle low on fuel")
end