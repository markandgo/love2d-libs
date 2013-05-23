local ceil = math.ceil

local path  = (...):match('^.+[%.\\/]') or ''

local grid  = require (path..'grid')

local DEFAULT_HASH_SIZE = 100

local function toGrid(x,y,gw,gh)
	return ceil(x/gw),ceil(y/gh)
end

local function removeFromGrid(self,name)
	local t      = self.boxes[name]
	local gx,gy  = t[1],t[2]
	local gx2,gy2= t[3],t[4]
	for gx,gy,v in grid.rectangle(self,gx,gy,gx2,gy2,true) do
		v[name] = nil
	end
end

local function addToGrid(self,name,x,y,w,h)
	local x2,y2   = x+w,y+h
	local gx,gy   = toGrid(x,y,self.width,self.height)
	local gx2,gy2 = toGrid(x2,y2,self.width,self.height)
	for gx,gy,v in grid.rectangle(self,gx,gy,gx2,gy2) do
		if not v then v = {}; grid.set(self,gx,gy,v) end
		v[name] = name		
	end
	return gx,gy,gx2,gy2
end

--[[
===================
INTERFACE
===================
--]]
local hash  = {}
hash.__index= hash

function hash.new(width,height)
	width = width or DEFAULT_HASH_SIZE
	height= height or width
	assert(width > 0 and (not height or height > 0),'Cell dimensions must be non-zero!')
	local self  = grid.new()
	self.width  = width
	self.height = height
	self.boxes  = {}
	return setmetatable(self,hash)
end

function hash:setBox(name,x,y,w,h)
	local t = self.boxes[name]
	if t then removeFromGrid(self,name) end
	local gx,gy,gx2,gy2 = addToGrid(self,name,x,y,w,h)
	if t then 
		t[1],t[2],t[3],t[4] = gx,gy,gx2,gy2
	else
		self.boxes[name] = {gx,gy,gx2,gy2}
	end
	return self
end

function hash:unsetBox(name)
	local t = self.boxes[name]
	if not t then return self end
	removeFromGrid(self,name)
	self.boxes[name] = nil
	return self
end

function hash:getCellSize()
	return self.width,self.height
end

function hash:getNeighbors(name)
	local list   = {}
	local t      = self.boxes[name]
	local gx,gy  = t[1],t[2]
	local gx2,gy2= t[3],t[4]
	for gx,gy,v in grid.rectangle(self,gx,gy,gx2,gy2,true) do
		for obj in pairs(v) do
			list[obj] = obj						
		end
	end
	list[name] = nil
	return list
end

return hash