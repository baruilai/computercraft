--installer v0.1

test = {}
test.URL = "https://raw.githubusercontent.com/baruilai/Computercraft/master/test.lua"
test.name = "test"

move = {}
move.URL = "https://raw.githubusercontent.com/baruilai/Computercraft/master/api/move"
move.name = "move"

local function gitGet(git_URL, file_name)
	if http.checkURL(git_URL) then
		local file = fs.open(file_name, "w")
		local file_content = http.get(newURL)
		file.write(file_content.readAll())
		file.close()
	else
		return false
	end
end

gitGet(move.URL, move.name)
gitGet(test.URL, test.name)
