local gamestate = class 'gamestate'
function gamestate:init()
	self.pre   = {}
	self.post  = {}
end

function gamestate:register()
	for i,callback in pairs(love.handlers) do
		love[callback] = function(...)
			if self.pre[callback] then self.pre[callback](self,...) end
			if self[callback] then self[callback](self,...) end
			if self.post[callback] then self.post[callback](self,...) end
		end
	end
	
	love.update = function(...)
		if self.pre['update'] then self.pre['update'](self,...) end
		if self['update'] then self['update'](self,...) end
		if self.post['update'] then self.post['update'](self,...) end
	end
	
	love.draw = function(...)
		if self.pre['draw'] then self.pre['draw'](self,...) end
		if self['draw'] then self['draw'](self,...) end
		if self.post['draw'] then self.post['draw'](self,...) end
	end
end

return gamestate() :include(state)