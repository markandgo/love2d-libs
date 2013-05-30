state = {}

function state.init(self)
	self.__states = self.__states or {}
	local oldmeta = getmetatable(self)
	setmetatable(self.__states,oldmeta)
end

function state:addState(name)
	local states  = self.__states
	local newstate= {}
	states[name]  = newstate	
	return newstate
end

function state:gotoState(name,...)
	local meta     = getmetatable(self) or {}
	local oldstate = meta and meta.__index
	if oldstate and oldstate.leave then oldstate.leave(self,...) end
	
	local state = self.__states[name]
	
	if not state then
		local originalmeta = getmetatable(self.__states)
		setmetatable(self,originalmeta)
		return
	end
	
	if state.enter then state.enter(self,oldstate,...) end
	meta.__index     = state
	meta.__statename = name
	setmetatable(self,meta)
end

function state.getState(self)
	local meta = getmetatable(self)
	if meta then return meta.__statename, meta.__index end
end
