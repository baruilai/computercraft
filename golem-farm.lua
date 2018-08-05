--domyslet ochranu před tím kdy dojde materiál
--ochrana proti chybejicim dverim
--torche
--moznost vytvorit tunel pro vesnose
--moznost vytvorit sloupy

--66 bloku na sloup
--celkem na prvni vez - 456 bloku, tj pres 7 staku
--sklo pouzite na vezeni - 16

--problem pri resetovani inventare - pokud se zmeni nastaveni nahore, nezmeni se dole

-- 8 staku materialu

local slot = {solid_block = 1, doors = 12, glass = 13, halfslab = 14, bucket1 = 15, bucket2 = 16}

local inventory = {}
local empty_inventory = {}

local distance_between_towers = 65
local x = 0

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


local function placeSolidBlock(direction)
	turtle.select(slot.solid_block)
	if direction == 	"up" then
		turtle.placeUp()
	elseif direction == "front" then
		turtle.place()
	elseif direction == "down" then
		turtle.placeDown()
	end

	if turtle.getItemCount(slot.solid_block) == 0 and slot.solid_block < slot.glass then 
		slot.solid_block = slot.solid_block + 1
		turtle.select(slot.solid_block)
	end
end

local function placeGlass(direction)
	turtle.select(slot.glass)
	if direction == "up" then
		turtle.placeUp()
	elseif direction == "front" then
		turtle.place()
	elseif direction == "down" then
		turtle.placeDown()
	end

	if turtle.getItemCount(slot.glass) == 0 and slot.glass < slot.bucket1 then 
		slot.glass = slot.glass + 1
		turtle.select(slot.glass)
	end
end

local function placeSlab(direction)
	turtle.select(slot.halfslab)
	if direction == 	"up" then
		turtle.placeUp()
	elseif direction == "front" then
		turtle.place()
	elseif direction == "down" then
		turtle.placeDown()
	end

	if turtle.getItemCount(slot.halfslab) == 0 and slot.halfslab < slot.glass then 
		slot.halfslab = slot.halfslab + 1
		turtle.select(slot.halfslab)
	end
end

local function makeDoublePillar(height, direction)
	if direction == "up" then
		placeSolidBlock("front")
		for i = 1, height - 1 do
			moveUp()
			placeSolidBlock("front")
			placeSolidBlock("down")
		end
		moveBack()
		placeSolidBlock("front")
	end

	if direction == "down" then
		turtle.place()
		for i = 1, height - 1 do
			moveDown()
			placeSolidBlock("front")
			placeSolidBlock("up")
		end
		moveBack()
		turtle.place()
	end
end

local function makeShaft(height)
	turtle.turnLeft()
	moveUp(2)
	makeDoublePillar(height - 3, "up")
	turtle.turnLeft()
	moveBack(2)
	makeDoublePillar(height, "down")
	turtle.turnLeft()
	moveBack(2)
	makeDoublePillar(height, "up")
	turtle.turnLeft()
	moveBack(2)
	makeDoublePillar(height, "down")
end

local function isEven(number)
	if math.fmod(number, 2) == 0 then
		return true
	else
		return false
	end
end

local function placeCobbleDown(length)
	if length == nil then length = 1 end

	for i = 2, length do

		turtle.digUp()
		
		if not turtle.compareDown() then 
			turtle.digDown()
			placeSolidBlock("down")
		end

		if turtle.getItemCount(slot.solid_block) == 0 and slot.solid_block < slot.glass then 
			slot.solid_block = slot.solid_block + 1
			turtle.select(slot.solid_block)
		end

		moveForward()
	end

	turtle.digUp()
	if not turtle.compareDown() then 
		turtle.digDown()
		placeSolidBlock("down")
	end
end

local function laySurface (direction, x, z)
	--example: laySurface("down", 2, 8, dirt, true)

	--place blocks in one line
	local function placeBlock(length)
		local i = 1
		while turtle.getItemCount(slot.solid_block) == 0 and i < 16 do
			slot.solid_block = slot.solid_block + 1
			i = i + 1
		end

		turtle.select(slot.solid_block)

		if length == nil then length = 1 end

		for i = 2, length do
			
			if direction == "up" and not turtle.compareUp() then
				turtle.placeUp()
			elseif direction == "down" and not turtle.compareDown() then
				turtle.placeDown()
			end

			--if there is no material, select next slot
			if turtle.getItemCount(slot.solid_block) == 0 and slot.solid_block < 16 then 
				slot.solid_block = slot.solid_block + 1
				turtle.select(slot.solid_block)
			end

			moveForward()
		end

		--finishing move
		if direction == "up" and not turtle.compareUp() then
			turtle.placeUp()
		elseif direction == "down" and not turtle.compareDown() then
			turtle.placeDown()
		end

		--if there is no material, select next slot
		if turtle.getItemCount(slot.solid_block) == 0 and slot.solid_block < 16 then 
			slot.solid_block = slot.solid_block + 1
			turtle.select(slot.solid_block)
		end
	end

	--place x number of lines
	for r = 1, x do

		placeBlock(z)

		if not isEven(r) and r ~= x then 
			turtle.turnRight()
			moveForward()
			turtle.turnRight()
		end

		if isEven(r) and r ~= x then
			turtle.turnLeft()
			moveForward()
			turtle.turnLeft()
		end
	end
end

local function makeWallsAround()
	local function makeWall()
		placeSolidBlock("up")
		placeSolidBlock("down")
		for i = 1, 9 do
			moveBack()
			placeSolidBlock("up")
			placeSolidBlock("front")
			placeSolidBlock("down")
		end
		moveBack()
		placeSolidBlock("front")
	end

	makeWall()
	for i = 1, 3 do
		turtle.turnRight()
		moveBack()
		makeWall()
	end
end

local function makeWallWithSlabs()
	local function makeWall()
		placeSlab("up")
		placeSolidBlock("down")
		for i = 1, 9 do
			moveBack()
			placeSlab("up")
			placeSolidBlock("front")
			placeSolidBlock("down")
		end
		moveBack()
		placeSolidBlock("front")
	end

	makeWall()
	for i = 1, 3 do
		turtle.turnRight()
		moveBack()
		makeWall()
	end
end

local function makeVillagerCell()
	local function makeWall(length)
		placeGlass("down")
		for i = 1, length - 1 do
			moveBack()
			placeGlass("front")
			placeGlass("down")
		end
		moveBack()
		placeGlass("front")
	end

	placeGlass("down")
	moveUp()
	placeGlass("down")
	moveForward()
	moveDown(2)
	
	for i = 1, 3 do
		placeGlass("down")
		moveForward()
	end
	placeGlass("down")


	placeGlass("front")
	moveUp()
	placeGlass("front")
	turtle.turnLeft()
	moveForward()
	turtle.turnRight()
	makeWall(4)
end

local function makeSpawningFloor()
	laySurface("down", 4, 10)
	turtle.turnLeft()
	moveForward()
	turtle.turnLeft()
	placeCobbleDown(4)
	moveForward(3)
	placeCobbleDown(4)
	turtle.turnRight()
	moveForward()
	turtle.turnRight()
	placeCobbleDown(4)
	moveForward(3)
	placeCobbleDown(4)
	turtle.turnLeft()
	moveForward()
	turtle.turnLeft()
	laySurface("down", 4, 10)
end

local function fillWaterBuckets()
	turtle.select(slot.bucket1)
	turtle.placeDown()
	sleep(1)
	turtle.select(slot.bucket2)
	turtle.placeDown()
end

local function askForMaterial()
	print("please insert more material and press enter")
	while true do
		event, key = os.pullEvent("key")

		if key == keys.enter then
			print("thank you")
			sleep(1.5)
			term.clear()
			term.setCursorPos(1, 1)
			return
		end
	end
end

local function makeTower()
	makeSpawningFloor()

	--make 3 high inner wall
	moveForward()
	turtle.turnLeft()
	moveUp()
	makeWallsAround()

	--make second floor
	moveUp(4)
	moveForward()
	turtle.turnLeft()
	moveForward()
	makeSpawningFloor()

	--make upper wall with slabs
	moveForward()
	turtle.turnLeft()
	moveUp()
	makeWallWithSlabs()
end

local function fillWaterCanals()
	local function fillLowerPlatform()
		moveUp(2)
		moveForward(2)
		moveDown(5)
		moveBack(2)
		moveDown(2)
		turtle.select(slot.bucket2)
		turtle.placeDown()
		moveUp(2)
		moveForward(2)
		moveUp(5)
		moveBack(2)
		moveDown(2)
	end

	--make water source
	moveUp(2)
	moveForward()
	turtle.turnLeft()
	moveForward(1)
	moveDown(2)

	turtle.select(slot.bucket1)
	turtle.placeDown()

	moveForward(2)

	turtle.select(slot.bucket2)
	turtle.placeDown()

	--fill buckets
	moveBack()
	fillWaterBuckets()

	--place water to corners

	--upper front right corner
	moveForward(8)
	turtle.select(slot.bucket1)
	turtle.placeDown()

	--lower front right corner
	fillLowerPlatform()

	--get refill
	moveBack(8)
	fillWaterBuckets()

	--upper front left corner
	moveForward(8)
	turtle.turnRight()
	moveForward(9)
	turtle.select(slot.bucket1)
	turtle.placeDown()

	--lower front left corner
	fillLowerPlatform()

	--get refill
	moveBack(9)
	turtle.turnRight()
	moveForward(8)
	fillWaterBuckets()

	--upper back left corner
	moveForward()
	turtle.turnLeft()
	moveForward(9)
	turtle.select(slot.bucket1)
	turtle.placeDown()

	--lower back left corner
	fillLowerPlatform()

	--get refill
	moveBack(9)
	turtle.turnLeft()
	moveForward()
	fillWaterBuckets()

	--lower back right corner
	moveBack()
	turtle.turnLeft()
	fillLowerPlatform()

	--destroy water source
	turtle.turnRight()
	moveForward(2)
	turtle.select(slot.bucket2)
	turtle.placeDown()
	moveBack()
	turtle.select(slot.halfslab)
	turtle.placeDown()
	turtle.digDown()

	--prepare for next function
	moveUp(2)
	moveForward(9)
	turtle.turnRight()
	moveForward(4)
	turtle.turnRight()
	moveBack()
	moveDown(5)

end --fill water canals

local function placeAllDoors(tower_number)
	local function placeDoors()
		for i = 1, 10 do
			turtle.place()
			turtle.turnLeft()
			moveForward()
			turtle.turnRight()
		end
	end

	turtle.select(slot.doors)

	turtle.turnRight()
	moveForward(4)
	turtle.turnLeft()

	--doors on front
	placeDoors()

	turtle.turnRight()
	moveForward(6)
	turtle.turnLeft()

	turtle.turnRight()
	moveForward(6)
	turtle.turnLeft()
	moveForward(11)
	turtle.turnLeft()

	--doors on right
	placeDoors()

	turtle.turnLeft()
	moveForward()
	turtle.turnRight()
	moveForward(6)
	turtle.turnRight()

	turtle.turnLeft()
	moveForward(7)
	turtle.turnRight()
	moveForward(2)
	turtle.turnRight()

	--doors on left
	placeDoors()

	turtle.turnRight()
	moveForward(12)
	turtle.turnLeft()
	moveForward(7)
	turtle.turnLeft()

	turtle.turnLeft()
	moveForward(7)
	turtle.turnRight()
	moveForward(13)
	turtle.turnRight()
	moveForward(2)
	turtle.turnRight()

	--doors on back
	placeDoors()

	turtle.turnLeft()
	moveForward()
	turtle.turnRight()
	moveForward(13)

	turtle.turnRight()
	moveForward(4)
	moveDown(1)
end


--prepare

--moveUp()
--moveForward()

--make shaft for golems

makeShaft(10)

--go to first floor
moveUp(10)
moveBack(3)
turtle.turnLeft()
moveForward(3)
turtle.turnRight()

--make first tower
makeTower()
fillWaterCanals()

placeAllDoors(0)

makeVillagerCell()

--go back to starting position
moveDown(4)
moveForward(2)
turtle.turnRight()
moveForward(5)
moveDown(8)

--resuply
askForMaterial()
slot = {solid_block = 1, doors = 12, glass = 13, halfslab = 14, bucket1 = 15, bucket2 = 16}

--prepare for building second tower
moveUp(8)
moveBack(4)
turtle.turnLeft()
moveForward(5)
turtle.turnRight()
moveUp(10)
moveForward(2)

moveUp(distance_between_towers + 1)

--make second tower
makeTower()
fillWaterCanals()

placeAllDoors(1)

makeVillagerCell()

--go back to starting position
moveDown(4 + 9 + distance_between_towers)
moveForward(2)
turtle.turnRight()
moveForward(5)
moveDown(8)