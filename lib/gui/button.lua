local path  = (...):match('^.+[%.\\/]') or ''
local box   = include (path..'/../collision.box')

local button = setmetatable({},box)

function button.new()
	local t = {
	state = 'up',
	}
	return setmetatable(t,button)
end

function button:setDown()
	self.state = 'down'
end

function button:setUp()
	self.state = 'up'
end

function button:isDown()
	return self.state == 'down'
end

return button