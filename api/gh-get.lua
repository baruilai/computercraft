-- github get by minerobber
-- https://pastebin.com/3wkn9edV

local arg1, arg2, arg3 = ...
if not arg3 then
  if not arg2 then
    if not arg1 then
      error("Expected 3 arguments, got 0")
    end
    error("Expected 3 arguments, got 1")
  end
  error("Expected 3 arguments, got 2")
end

local newURL = "https://raw.githubusercontent.com/" .. arg1 .. "/master/" .. arg2

if http.checkURL(newURL) then
  local h = fs.open(arg3, "w")
  local arg1contents = http.get(newURL)
  h.write(arg1contents.readAll())
  h.close()
  print("Finished!")
else
  error("First argument must be valid GitHub User/Repository pair, Second argument must be valid file in the master branch of that User/Repository.")
end