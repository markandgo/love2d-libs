-- simple class
-------------------------------------------------
local base    = {__type = 'Object'}
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

function base:mixin(source)
	local meta = getmetatable(source)
	local index = meta and meta.__index
	
	if index then base.mixin(self,index) end

	for i,v in pairs(source) do
		self[i] = v
	end
	
	if source.init then source.init(self) end
	
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
