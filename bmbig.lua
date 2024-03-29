--9x9 bazén
--sapling, drevo, hlina
--jine nastaveni pro borovice a pro brizu

--borovice - trees = 6, saplings = 6 is ok
--briza - trees = 4, saplings = 5

local slot = {
	sapling = 1,
	log = 2,
	bonemeal = 3
}

local gameItem = {
	chest = "minecraft:chest",
	leaves = "minecraft:leaves",
	torch = "minecraft:wall_torch",
	water = "minecraft:water",
	podzol = "minecraft:podzol"
}

local peripherals = {
	workbench = "workbench"
}

local consecutiveTrees = 2
local minimumSaplingYield = consecutiveTrees * 4 + 1
local waitForSaplingsInSeconds = 120

local minimumSaplings = 5
local minimumFuel = 100
local optimumFuel = 2000
local countdown = 3
local maximumTreeHeight = 31

local function moveForward(distance)
	if distance == nil then
		distance = 1
	end

	for i = 1, distance do
		if turtle.detect() then
			turtle.dig()
		end

		--mob protection
		while not turtle.forward() do
			sleep(1)
			turtle.dig()
		end
	end
end

local function moveUp(distance)
	if distance == nil then
		distance = 1
	end

	for i = 1, distance do
		if turtle.detectUp() then
			turtle.digUp()
		end

		--mob protection
		while not turtle.up() do
			sleep(1)
			turtle.digUp()
		end
	end
end

local function moveDown(distance)
	if distance == nil then
		distance = 1
	end

	for i = 1, distance do
		if turtle.detectDown() then
			turtle.digDown()
		end

		--mob protection
		while not turtle.down() do
			sleep(1)
			turtle.digDown()
		end
	end
end

local function moveBack(distance)
	if distance == nil then
		distance = 1
	end

	for i = 1, distance do
		while not turtle.back() do
			turtle.turnLeft()
			turtle.turnLeft()
			turtle.dig()
			turtle.turnLeft()
			turtle.turnLeft()
		end
	end
end

local function frontBlockIs(block)
	local has_block, data = turtle.inspect()
	if not has_block then
		return false
	end

	if data.name == block or data[block] then
		return true
	end

	return false
end

local function bottomBlockIs(block)
	local has_block, data = turtle.inspectDown()
	if not has_block then
		return false
	end

	if data.name == block or data[block] then
		return true
	end

	return false
end

local function topBlockIs(block)
	local has_block, data = turtle.inspectUp()
	if not has_block then
		return false
	end

	if data.name == block or data[block] then
		return true
	end

	return false
end

local function requestAssistance(problem)
	print(problem)
	print("press enter to continue")

	while true do
		local event, key = os.pullEvent("key")

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

local function drop()
	if not turtle.drop() then
		requestAssistance("Chest in front of me is full.")
	end
end

local function dropDown()
	if not turtle.dropDown() then
		requestAssistance("Chest down is full.")
	end
end

local function plantSaplings()
	turtle.select(slot.log)
	if turtle.compare() then
		return
	end

	turtle.select(slot.sapling)
	if turtle.compare() then
		return
	end

	-- distant left corner
	moveForward()
	turtle.turnLeft()
	moveForward()
	turtle.turnRight()
	turtle.place()

	-- close left corner
	turtle.turnLeft()
	moveBack()
	turtle.place()

	-- distant right corner
	turtle.turnRight()
	turtle.place()

	-- close right corner
	moveBack()
	turtle.place()
end

local function unloadLogs()
	turtle.select(slot.log)
	for i = slot.bonemeal, 16 do
		if turtle.compareTo(i) then
			turtle.select(i)
			dropDown()
			turtle.select(slot.log)
		end
	end
end

local function unloadRest()
	turtle.turnLeft()
	for i = slot.bonemeal + 1, 16 do
		turtle.select(i)
		if turtle.getItemCount() > 0 and not turtle.drop() then
			requestAssistance("Chest for saplings is full")
		end
	end
	turtle.turnRight()
end

local function refuel()
	if turtle.getFuelLevel() > optimumFuel or turtle.getItemCount(slot.log) <= 17 then
		return
	end

	if (peripheral.getType("left") == peripherals.workbench or peripheral.getType("right") == peripherals.workbench) then
		turtle.turnLeft()

		turtle.suck()
		turtle.suck()
		turtle.select(slot.sapling)
		drop()
		turtle.select(slot.bonemeal)
		drop()

		for i = slot.bonemeal + 1, 16, 1 do
			drop()
		end

		turtle.craft(16)
		turtle.select(slot.log + 1)
		turtle.refuel(64)
		turtle.select(slot.sapling)
		turtle.suck()
		turtle.select(slot.bonemeal)
		turtle.suck()
		turtle.turnRight()

		print("Fuel level: " .. turtle.getFuelLevel())
	elseif turtle.getFuelLevel() < minimumFuel then
		requestAssistance("We are run out of fuel")
	end
end

local function getBonemeal()
	turtle.select(slot.bonemeal)
	local bonemealCount = turtle.getItemSpace(slot.bonemeal)
	turtle.suckUp(bonemealCount)

	if turtle.getItemCount() <= 1 then
		requestAssistance("We are run out of bonemeal")
	end
end

local function goToChestPosition()
	moveForward()
	turtle.turnLeft()
	turtle.turnLeft()
	moveForward()
	moveDown()
	while not bottomBlockIs(gameItem.chest) do
		moveForward()
	end
	turtle.turnRight()
	turtle.turnRight()
end

local function goToOperationPosition()
	moveForward(4)
	moveUp()
end

local function restock()
	goToChestPosition()
	unloadLogs()
	unloadRest()
	refuel()
	getBonemeal()
	goToOperationPosition()
end

local function useBonemeal()
	turtle.select(slot.bonemeal)

	while turtle.place() do
		if turtle.getItemCount(slot.bonemeal) <= 1 then
			restock()
		end

		turtle.select(slot.log)
		if turtle.compare() then
			return
		end

		turtle.select(slot.bonemeal)
	end
end

local function makeTree()
	turtle.select(slot.log)
	if turtle.compare() then
		return
	end

	plantSaplings()
	useBonemeal()
end

local function cutTreeFromBelow()
	turtle.select(slot.log)
	while turtle.compareUp() or turtle.compare() do
		turtle.dig()
		moveUp()
	end
end

local function cutTreeFromAbove()
	while not bottomBlockIs(gameItem.podzol) do
		turtle.dig()
		moveDown()
	end
	turtle.dig()
end

local function harvestTree()
	moveForward()

	cutTreeFromBelow()

	turtle.turnLeft()
	moveForward()
	turtle.turnRight()

	cutTreeFromAbove()

	turtle.turnLeft()
	moveBack()
	turtle.turnRight()
	moveBack()
end

local function getSaplings()
	local saplings_before = turtle.getItemCount(slot.sapling)
	local targetSaplingCount = saplings_before + minimumSaplingYield

	moveDown(2)
	moveForward()

	turtle.select(slot.sapling)
	for i = slot.bonemeal + 1, 16 do
		if turtle.compareTo(i) then
			turtle.select(i)
			turtle.transferTo(slot.sapling)
			turtle.select(slot.sapling)
		end
	end

	local i = 0
	while i < waitForSaplingsInSeconds and turtle.getItemCount(slot.sapling) < 64 do
		while turtle.suckDown() do
		end

		print("Found " .. turtle.getItemCount(slot.sapling) - saplings_before .. " saplings.")

		if turtle.getItemCount(slot.sapling) == 64 or turtle.getItemCount(slot.sapling) >= targetSaplingCount then
			break
		end

		sleep(10)
		i = i + 10
	end
	print("Waited " .. (i) .. " seconds.")

	moveBack()
	moveUp(2)
end

local function farmTrees()
	while turtle.getItemCount(slot.sapling) >= minimumSaplings and turtle.getFuelLevel() > minimumFuel do
		if turtle.getItemCount(16) > 0 or turtle.getFuelLevel() < optimumFuel then
			restock()
		end

		for i = 1, consecutiveTrees do
			makeTree()
			harvestTree()
		end

		getSaplings()
	end
end

local function cancelTimer(duration, text)
	local timer = os.startTimer(1)
	repeat
		term.clear()
		term.setCursorPos(1, 1)
		print(text)
		print("Press enter to end program.")
		print(duration)

		local id, p1 = os.pullEvent()
		if id == "key" and p1 == 28 then
			error()
		elseif id == "timer" and p1 == timer then
			duration = duration - 1
			timer = os.startTimer(1)
		end
	until duration < 0
	term.clear()
	term.setCursorPos(1, 1)
	return false
end

local function restoreWorkingPosition()
	if turtle.detectDown() and not bottomBlockIs(gameItem.leaves) then
		return false
	end

	turtle.select(slot.sapling)
	if turtle.compare() then
		return true
	end

	moveDown()
	local isInWorkingPosition = frontBlockIs(gameItem.podzol)
	moveUp()

	if not isInWorkingPosition then
		return false
	end

	print("Restoring from working position.")

	return true
end

local function restoreRestockPosition()
	if not bottomBlockIs(gameItem.chest) then
		return false
	end

	while not frontBlockIs(gameItem.chest) do
		turtle.turnLeft()
	end

	turtle.turnRight()
	goToOperationPosition()

	print("Restoring from restock position.")
	return true
end

local function restoreUnderPodzolPosition()
	if not topBlockIs(gameItem.podzol) then
		return false
	end

	moveBack()
	moveUp(2)

	print("Restoring from under podzol position.")
	return true
end

local function restoreOverPodzolPosition()
	if not bottomBlockIs(gameItem.podzol) then
		return false
	end

	while turtle.detectDown() do
		moveForward()
		if (bottomBlockIs(gameItem.podzol)) then
			moveForward()
		end

		if not turtle.detectDown() then
			moveBack()
			break
		end

		if bottomBlockIs(gameItem.torch) then
			moveBack()
		end

		turtle.turnRight()
	end

	turtle.turnRight()
	turtle.turnRight()
	moveBack()

	return true
end

local function restoreOverWaterPosition()
	if turtle.detectDown() or turtle.detectUp() then
		return false
	end

	if turtle.detect() and not frontBlockIs(gameItem.leaves) then
		if frontBlockIs(gameItem.podzol) then
			moveUp()
			return true
		else
			return false
		end
	end

	moveDown()

	if not bottomBlockIs(gameItem.water) then
		moveUp()
		return false
	end

	moveUp()
	for i = 1, 3, 1 do
		if frontBlockIs(gameItem.podzol) then
			break
		end
		moveForward()
	end
	moveUp()

	print("Restoring from over water position.")
	return true
end

local function restoreCuttingTreePosition()
	while not bottomBlockIs(gameItem.podzol) do
		moveDown()
	end

	restoreOverPodzolPosition()
	moveForward()

	turtle.select(slot.log)
	for i = 1, maximumTreeHeight, 1 do
		moveUp()
		if turtle.compare() or turtle.compareUp() then
			cutTreeFromBelow()
			break
		end
	end

	turtle.turnLeft()
	moveForward()
	turtle.turnRight()

	cutTreeFromAbove()
	restoreOverPodzolPosition()

	print("Restoring from under tree position.")
	return true
end

local function restorePosition()
	cancelTimer(countdown, "Turtle will now restore session")

	local restoreFunctions = {
		restoreWorkingPosition,
		restoreRestockPosition,
		restoreUnderPodzolPosition,
		restoreOverPodzolPosition,
		restoreOverWaterPosition,
		-- restoreCuttingTreePosition must be last function
		restoreCuttingTreePosition
	}

	for index, restoreFunction in ipairs(restoreFunctions) do
		local restored = restoreFunction()
		if restored then
			return
		end
	end
end

local function checkInventory()
	term.clear()
	term.setCursorPos(1, 1)
	while turtle.getItemCount(slot.sapling) < minimumSaplings do
		print("Not enought saplings.")
		print("Minimum required saplings is " .. minimumSaplings)
		requestAssistance("Please insert saplings into slot number " .. slot.sapling)
	end
	while turtle.getItemCount(slot.log) == 0 do
		print("Turtle has no wood in correct slot")
		requestAssistance("Please insert some wood of chosen type into slot number " .. slot.log)
	end
end

checkInventory()
restorePosition()
farmTrees()

if turtle.getFuelLevel() < 100 then
	print("turtle low on fuel")
end
