-- By Kingdaro
-- A nice, small class implementation.
-- http://www.computercraft.info/forums2/index.php?/topic/12518-a-nice-small-class-implementation/

local entity = {}
function class(obj)
	obj = obj or {}
	obj.init = obj.init or function() end
	
	function obj:new(...)
		local instance = setmetatable({__class = obj}, {__index = obj})
		return instance, instance:init(...)
	end
	
	function obj:extend(t)
		t = t or {}
		for k,v in pairs(obj) do
			if not t[k] then
				t[k] = v
			end
		end
		return class(t)
	end
	
	return setmetatable(obj, {__call = obj.new})
end

return entity

--[[ Usage example:

Thing = class()

function Thing:speak()
  print 'I am a thing.'
end

Organism = Thing:extend{
  kind = '';
}

function Organism:init(kind)
  self.kind = kind or self.kind
end

function Organism:speak()
  Thing.speak(self)
  print 'A living thing, in fact.'
  print('I am a '..self.kind)
end

Person = Organism:extend{
  name = '';
  kind = 'human';
}

function Person:init(name)
  self.name = name or self.name
end

function Person:speak()
  Organism.speak(self)
  print('My name is '..self.name)
end

unknown = Thing()
unknown:speak() --> I am a thing.

frog = Organism('frog')
frog:speak()
--> I am a thing.
--> A living thing, in fact.
--> I am a frog

bob = Person('Bob')
bob:speak()
--> I am a thing.
--> A living thing, in fact.
--> I am a human
--> My name is Bob

--]]