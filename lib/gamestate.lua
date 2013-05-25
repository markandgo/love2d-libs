local gamestate = class 'gamestate'
function gamestate:init()
	self.global = {}
end

function gamestate:register()
	for i,callback in pairs(love.handlers) do
		love[callback] = function(...)
			if self[callback] then self[callback](self,...) end
			if self.global[callback] then self.global[callback](self,...) end
		end
	end
	
	love.update = function(...)
		if self['update'] then self['update'](self,...) end
		if self.global['update'] then self.global['update'](self,...) end
	end
	
	love.draw = function(...)
		if self['draw'] then self['draw'](self,...) end
		if self.global['draw'] then self.global['draw'](self,...) end
	end
end

return gamestate() :include(state)