Dye farming

local function unload()
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.dropDown() 
        end
        turtle.select(1)
    end

end

turtle.select(1)
while turtle.getItemCount(1) > 0 do
    turtle.place()
    turtle.suck()
end
unLoad()