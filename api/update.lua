-- update
-- this program is not working yet, needs arguments and option for git

local function update()
	--before we try to delete ourself, just check the connection OK?
	test = http.get("http://pastebin.com/" .. pastebin_code)
	if test then

		-- first let me delete myself
		print(fs.delete(shell.getRunningProgram()))

		-- Now get the program from pastebin.com
		-- Format: pastebin get (pasteid) (destination)
		-- not so simple way to get name of this program without path
		shell.run("pastebin get "..pastebin_code.." "..fs.getName(shell.getRunningProgram()))
		return true
	else
		print("Update is not possible")
		return false
	end
end