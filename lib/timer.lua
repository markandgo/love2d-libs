local timer   = {}
timer.__index = timer

function timer.new(duration,callback,loop)
	assert(duration > 0,'timer duration must be greater than 0')
	return setmetatable({t = 0, loop = loop, callback = callback, duration = duration},timer)
end

function timer:update(dt)
	if self.t >= self.duration then return end
	self.t = self.t + dt
	if self.t >= self.duration then 
		if self.callback then self:callback() end
		if self.loop then timer.reset(self) else self.t = duration end
	end
end

function timer:isDone()
	return self.t >= self.duration
end

function timer:reset()
	self.t = 0
end

function timer:setLoop(loop)
	self.loop = loop
end

function timer:getDuration()
	return self.duration
end

function timer:getElapsed()
	return self.t
end

function timer:getRemaining()
	return self.duration-self.t
end

function timer:setCallback(callback)
	self.callback = callback
end

return timer