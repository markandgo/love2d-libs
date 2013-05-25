local syncGlobals = function(module)
	local gamestate = module.gamestate
	
	_CURRENT_STATE = gamestate:getState()
	_FPS           = love.timer.getFPS()
end

local enforceLocal = function()
	local meta = {__newindex = function(t,k,v) 
		if k:sub(1,1) == '_' then rawset(t,k,v) return end
		error ('Cannot declare global variable without "_" prefix.')
	end}
	setmetatable(_G,meta) 
end

local install = function(module)
	local gamestate = module.gamestate
	gamestate:register()
	gamestate.global.update = function(gamestate,dt)
		syncGlobals(module)
	end
	
	enforceLocal()
end

return install