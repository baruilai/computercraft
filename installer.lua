--installer v0.1

local program_list = {
	require.URL = "https://raw.githubusercontent.com/baruilai/Computercraft/master/api/require.lua";
	require.name = "require";
}

require_URL = "https://raw.githubusercontent.com/baruilai/Computercraft/master/api/require.lua"

local function gitGet(git_URL, file_name)
	if http.checkURL(git_URL) then
		local file = fs.open(file_name, "w")
		local file_content = http.get(newURL)
		file.write(file_content.readAll())
		file.close
	else
		return false
	end
end

gitGet(require_URL, require.name)
