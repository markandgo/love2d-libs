local lg      = love.graphics
local cos     = math.cos
local sin     = math.sin
local mousepos= love.mouse.getPosition
local max,min = math.max,math.min

local rotate = function(theta,x,y)
	return x*cos(theta)-y*sin(theta),x*sin(theta)+y*cos(theta)
end

local getCenter = function(self)
	return self.ox+self.w/2,self.oy+self.h/2
end
-------------------
-- public interface
-------------------
local camera   = {}
camera.__index = camera

function camera.new(x,y,angle,sx,sy,ox,oy,w,h)
	x,y  = x or lg.getWidth()/2, y or lg.getHeight()/2
	sx   = sx or 1
	sy   = sy or sx
	angle= angle or 0
	ox,oy= ox or 0,oy or 0
	w,h  = w or lg.getWidth(),h or lg.getHeight()
	t    = {x= x, y= y, angle = angle, sx = sx, sy = sy, ox = ox, oy = oy, w = w, h = h}
	return setmetatable(t,camera)
end

function camera:rotate(angle)
	self.angle = self.angle + angle
end

function camera:setRotation(angle)
	self.angle = angle
end

function camera:getRotation()
	return self.angle
end

function camera:move(dx,dy)
	self.x, self.y = self.x + dx, self.y + dy
end

function camera:setPosition(x,y)
	self.x, self.y = x,y
end

function camera:getPosition()
	return self.x,self.y
end

function camera:setScale(sx,sy)
	self.sx = sx or 1
	self.sy = sy or self.sx
end

function camera:getScale()
	return self.sx,self.sy
end

function camera:scale(sx,sy)
	self.sx = sx*self.sx
	self.sy = (sy or sx)*self.sy
end

function camera:setWindow(ox,oy,w,h)
	self.ox,self.oy,self.w,self.h = ox,oy,w,h
end

function camera:getWindow()
	return self.ox,self.oy,self.w,self.h
end

function camera:getViewport()
	-- local w,h = 
end

function camera:set()
	-- draw poly mask
	lg.push()
	local cx,cy = getCenter(self)
	-- transform view in viewport
	lg.setScissor(self.ox,self.oy,self.w,self.h)
	lg.translate(cx, cy)
	lg.scale(self.sx,self.sy)
	lg.rotate(self.angle)
	lg.translate(-self.x, -self.y)
end

function camera:unset()
	lg.pop()
	lg.setScissor()
end

function camera:draw(func)
	camera.set(self)
	func()
	camera.unset(self)
end

function camera:cameraCoords(x,y)
	local cx,cy = getCenter(self)
	x,y = rotate(self.angle, x-self.x, y-self.y)
	return x*self.sx+cx,y*self.sy+cx
end

function camera:worldCoords(x,y)
	local cx,cy = getCenter(self)
	x,y = rotate(-self.angle, (x-cx)/self.sx, (y-cy)/self.sy)
	return x+self.x, y+self.y
end

function camera:mousePosition()
	local mx,my = mousepos() 
	mx = max(self.ox,min(mx,self.ox+self.w))
	my = max(self.oy,min(my,self.oy+self.h))
	return camera.worldCoords(self,mx,my)
end

return camera