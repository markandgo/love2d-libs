-- simple class
-------------------------------------------------
local base    = {__type = 'object'}
base.__index  = base

function base.type(obj)
	return getmetatable(obj).__type
end

function base.typeOf(obj,name)
	local parent = getmetatable(obj)
	while parent do
		if parent.__type == name then return true end
		parent = getmetatable(parent)
	end
	return false
end

function base.__call(class,...)
	local obj = {}
	if class.init then obj = class.init(obj,...) or obj end
	return setmetatable(obj,class)
end

function base:extend(parent)
	parent.__call = base.__call
	return setmetatable(self,parent)
end

function base:include(source)
	local meta  = getmetatable(source) 
	local index = meta and meta.__index
	if index then base.include(self,index) end
	
	for i,v in pairs(source) do
		if type(v) == 'function' then
			self[i] = v
		end
	end
	
	if type(source.included) == 'function' then source:included(self) end
	
	return self
end

local function new(name)
	local class = {__type = name}
	class.__index = class
	class.new = base.__call
	return setmetatable(class,base)
end

class = setmetatable({},{__call = function(_,name) return new(name) end})

function class.extend(name,parent)
	return class(name):extend(parent)
end

function class.include(destination,source)
	base.include(destination,source)
end