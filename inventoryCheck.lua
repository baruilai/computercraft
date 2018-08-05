
local cob_gen_req = {
	quantity = {52, 2, 1, 1},
	name = {nil, nil, "minecraft:water_bucket", "minecraft:lava_bucket"}
}

local function checkItemName(slot)
	if slot == nil then slot = turtle.getSelectedSlot() end
	item = turtle.getItemDetail(slot)
	if item then
		print(item.name)
		return item.name
	else
		return false
	end
end

local function checkInventory(inventory)
	for i = 1, #inventory.quantity do
		if turtle.getItemCount(i) < inventory.quantity[i] then
			print("mnozstvi")
			return false
		elseif checkItemName(i) ~= inventory.name[i] and inventory.name[i] ~= nil then
			print("jmeno")
			return false
		end
	end
	return true

end

print(checkInventory(cob_gen_req))