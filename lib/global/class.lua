-- simple class
-------------------------------------------------
local base    = {__type = 'Object'}
base.__index  = base

function base.type(obj)
	return obj.__type
end

function base.typeOf(obj,name)
	while obj do
		if obj.__type == name then return true end
		local meta = getmetatable(obj)
		obj = meta and meta.__index
	end
	return false
end

function base.__call(class,...)
	local obj = {}
	if class.init then class.init(obj,...)end
	return setmetatable(obj,class)
end

function base:extend(parent)
	parent.__call = base.__call
	return setmetatable(self,parent)
end

function base:mixin(source,...)
	local recur
	recur = function(self,source)
		local meta = getmetatable(source)
		local index = meta and meta.__index

		if index then recur(self,index) end
	
		for i,v in pairs(source) do
			self[i] = v
		end
	end
	recur(self,source)
	
	if source.init then source.init(self,...) end
	
	return self
end

local function new(name)
	local class = {__type = name}
	class.__index = class
	class.new = function(...) return base.__call(class,...) end
	return setmetatable(class,base)
end

class = setmetatable({},{__call = function(_,name) return new(name) end})

function class.extend(child,parent)
	if type(child) == 'string' then return class(child):extend(parent) end
	base.extend(child,parent)
end

function class.mixin(destination,source)
	base.mixin(destination,source)
end
