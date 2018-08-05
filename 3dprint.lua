


local pastebin_code = "Hhv9XxMr"
local args = {...}

local data = {
	"123456",
	"111111",
	"111111",
	"111111",
	"111111"
}


local function update()
	-- first let me delete myself
	print(fs.delete(shell.getRunningProgram()))

	-- Now get the program from pastebin.com
	-- Format: pastebin get (pasteid) (destination)
	-- not so simple way to get name of this program without path
	shell.run("pastebin get "..pastebin_code.." "..fs.getName(shell.getRunningProgram()))
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

local function PD(slot_number)
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

if args[1] == "update" then
	update()
	return
end

print(#data[1])
print(string.sub(data[1], 1, 1))

local function build_scheme()
	moveForward()
	PD(1)

	for i = 1, #data[1] - 1 do
		moveForward()
		PD(tonumber(string.sub(data[1], i, i)))
	end

	if not isEven(i) then 
		turtle.turnLeft()
		moveForward()
		turtle.turnLeft()
	end

	if isEven(i) then
		turtle.turnRight()
		moveForward()
		turtle.turnRight()
	end
end

build_scheme()