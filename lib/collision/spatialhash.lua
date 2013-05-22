local ceil = math.ceil

local path  = (...):match('^.+[%.\\/]') or ''

print (path..'grid')

local grid  = require (path..'grid')

local function toGrid(x,y,gw,gh)
	return ceil(x/gw),ceil(y/gh)
end

local function removeFromGrid(self,name)
	local t       = self.boxes[name]
	local ox,oy   = t[1],t[2]
	local ox2,oy2 = t[3],t[4]
	local gx,gy   = toGrid(ox,oy,self.width,self.height)
	local gx2,gy2 = toGrid(ox2,oy2,self.width,self.height)
	for gx,gy,v in grid.rect(self,gx,gy,gx2-gx,gy2-gy,true) do
		v[name] = nil
	end
end

local function addToGrid(self,name,x,y,w,h)
	local x2,y2   = x+w,y+h
	local gx,gy   = toGrid(x,y,self.width,self.height)
	local gx2,gy2 = toGrid(x2,y2,self.width,self.height)
	for gx,gy,v in grid.rect(self,gx,gy,gx2-gx,gy2-gy) do
		v       = v or {}
		v[name] = name
	end
end

--[[
===================
INTERFACE
===================
--]]
local hash  = {}
hash.__index= hash

function hash.new(width,height)
	assert(width > 0 and (not height or height > 0),'Cell dimensions must be non-zero!')
	local self  = grid.new()
	self.width  = width
	self.height = height or width
	self.boxes  = {}
	return setmetatable(self,hash)
end

function hash:setBox(name,x,y,w,h)
	local t = self.boxes[name]
	if t then removeFromGrid(self,name) end
	addToGrid(self,name,x,y,w,h)
	if t then 
		t[1],t[2],t[3],t[4] = x,y,x+w,y+h
	else
		self.boxes[name] = {x,y,x+w,y+h}
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

function hash:getNeighbors(name)
	local list    = {}
	local t       = self.boxes[name]
	local ox,oy   = t[1],t[2]
	local ox2,oy2 = t[3],t[4]
	local gx,gy   = toGrid(ox,oy,self.width,self.height)
	local gx2,gy2 = toGrid(ox2,oy2,self.width,self.height)
	for gx,gy,v in grid.rect(self,gx,gy,gx2-gx,gy2-gy) do
		for obj in pairs(v) do
			list[obj] = obj
		end
	end
	list[name] = nil
	return list
end

return hash