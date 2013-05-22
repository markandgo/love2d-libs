local modes = {bounce = true, loop = true, once = true}

local newDelays = function(total,delays)
	if type(delays) == 'table' then return {unpack(delays)} end
	local t = {}
	for i = 1,total do
		t[i] = delays
	end
	return t
end

local a  = {}
a.__index= a

function a.new(total,delays,mode)
	self = {}
	self.delays      = newDelays(total,delays)
	self.time        = 0
	self.currentFrame= 1
	self.totalFrames = total
	self.direction   = 1
	self.playing     = true
	a.setMode(self,mode or 'loop')
	return setmetatable(self,a)
end

--[[
===================
SETTERS/GETTERS
===================
--]]

function a:isPlaying()
	return self.playing
end

function a:getTotalFrames()
	return self.totalFrames
end

function a:getCurrentFrame()
	return self.currentFrame
end

function a:setMode(mode)
	assert(modes[mode],'invalid mode')
	self.mode = mode
end

function a:getMode()
	return self.mode
end

--[[
===================
DIRECTION
===================
--]]

function a:setDirection(direction)
	self.direction = direction == 'forward' and 1 or direction == 'backward' and -1
	self.time      = self.delays[self.currentFrame]-self.time
end

function a:getDirection()
	return self.direction == 1 and 'forward' or 'backward'
end

function a:reverseDirection()
	self.direction = self.direction*-1
end

--[[
===================
PLAYBACK
===================
--]]
function a:reset()
	a.setDirection(self,1)
	a.rewind(self)
end

function a:rewind()
	self.time        = 0
	self.currentFrame= self.direction == 1 and 1 or self.totalFrames
	self.playing     = true
end

function a:seek(frame)
	self.currentFrame= frame
	self.time        = 0
end

--[[
===================
CALLBACK
===================
--]]

function a:update(dt)
	if not self.playing then return end
	local t     = self.time + dt
	local frame = self.currentFrame
	local delays= self.delays
	local total = self.totalFrames
	
	while t >= delays[frame] do
		t    = t - delays[frame]
		frame= frame+self.direction
		
		if not self.delays[frame] then 
			if self.mode == 'loop' then
				a.rewind(self)
			elseif self.mode == 'bounce' then
				a.reverseDirection(self)
				a.rewind(self)
			else
				self.playing = false 
			end
			return
		end
	end
	self.currentFrame = frame
	self.time         = t
end
 
function a:draw(image,atlas,...)
	atlas:draw(image,self.currentFrame,...)
end

return a