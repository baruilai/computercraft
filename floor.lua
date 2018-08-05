local width
local height
local job
local args = {...}

--pozor, pokud budou v inventáři díry - volné sloty, tak to nebude fungovat

local function update()
	-- Deleting
	fs.delete("floor")

	-- Getting
	-- This will now download the programs you deleted above.
	-- Format: pastebin get (pasteid) (destination)

	shell.run("pastebin get BgintcNn floor")
end

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


local function isEven(number)
	if math.fmod(number, 2) == 0 then
		return true
	else
		return false
	end
end

local function selectNextSlot()
	--if there is no material, select next slot
	--přejmenovat ať to dává větší smysl
	if turtle.getItemCount(turtle.getSelectedSlot()) == 0 and turtle.getSelectedSlot() < 16 then 
		turtle.select(turtle.getSelectedSlot() + 1)
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

local function makeWallsAround(width, depth)
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

	makeWall(depth)

	turtle.turnRight()
	moveBack()

	makeWall(width)

	turtle.turnRight()
	moveBack()

	makeWall(depth)

	turtle.turnRight()
	moveBack()

	makeWall(width)

	turtle.turnLeft()
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

print("turtle start to the right")
if args[1] == nil then
	print("Size?")
	write("Width: ")
	width = read()
	write("Length: ")
	length = read()
else
	if args[2] == nil then
		if args[1] == "update" then
			update()
			return "updated"
		else
			width = args[1]
			write("Length: ")
			length = read()
		end
	else		
		width = args[1]
		length = args[2]
		job = args[3]
	end
end

turtle.select(1)
if job ~= "digdown" then
	while turtle.getItemCount(turtle.getSelectedSlot()) == 0 do
		if turtle.getSelectedSlot() == 16 then
			error("inventory is empty")
		end
		turtle.select(turtle.getSelectedSlot() + 1)
	end
end

if job == "wall" then
	makeWallsAround(width, length)
else
	laySurface(width, length, job, false)
end