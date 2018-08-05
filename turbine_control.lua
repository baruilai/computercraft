
local low = 1
local high = 14  


local optimal_rotor_speed = 1840
local min_rotor_speed = 1750

local reactor = peripheral.wrap("BigReactors-Reactor_1")
local turbine = peripheral.wrap("BigReactors-Turbine_3")

sleep(3)
while true do
	--local reactor = peripheral.wrap("BigReactors-Reactor_1")
	--local turbine = peripheral.wrap("BigReactors-Turbine_1")

--	if turbine.getEnergyStored() <= low then
  if redstone.getAnalogInput("right") <= low then
		if not reactor.getActive() then
			reactor.setActive(true)
		end
		if not turbine.getInductorEngaged() then
			turbine.setInductorEngaged(true)
		end
	end
	
--	if turbine.getEnergyStored() >= high then
  if redstone.getAnalogInput("right") >= high then

		turbine.setInductorEngaged(false)
	end

	if turbine.getRotorSpeed() > optimal_rotor_speed and reactor.getActive() then
		reactor.setActive(false)
	elseif turbine.getRotorSpeed() < min_rotor_speed and not reactor.getActive() then
  reactor.setActive(true)
 end

	sleep(5)
end
