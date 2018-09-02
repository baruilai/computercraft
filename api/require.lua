-- require() for CC by comp500
-- MIT license - https://github.com/comp500/CCSnippets/
function require(...)
    local c,r = fs.combine,{}
    local function fn(a) return fs.exists(a) and a or false end
    for i,v in ipairs(arg) do
        local file = fn(c('usr/apis',v)) or fn(v) or shell.resolveProgram(v)
        if not file then
            printError("API "..v.." not found")
            table.insert(r,nil)
        else
            os.loadAPI(file)
            local b = _G[v]
            _G[v] = nil
            table.insert(r,b)
        end
    end
    return unpack(r)
end