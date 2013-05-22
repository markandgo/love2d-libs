local draw = love.graphics.circle
local min  = math.min
local max  = math.max

local circle = {}
circle.__index = circle

circle.new = function(x,y,r)
	local a = 
	{
		x       = x,
		y       = y,
		radius  = r,
	}
	return setmetatable(a,circle)
end

circle.bbox = function(self)
	local x,y,r = self.x,self.y,self.radius
	return x-r,y-r,r*2,r*2
end

circle.testCircle = function(self,circle)
	local dx,dy = self.x-circle.x, self.y-circle.y
	local radii = self.radius + circle.radius
	local d2 = dx^2+dy^2
	if d2 == 0 then return true,radii,0 end
	if d2 < radii*radii then
		local distance    = d2^.5
		local penetration = radii - distance
		local ndx,ndy     = dx/distance,dy/distance
		return true,ndx*penetration,ndy*penetration
	end
	return false
end

circle.testPoint = function(self,x,y)
	local dx,dy     = self.x-x, self.y-y
	local distance  = dx^2+dy^2
	return distance < self.radius*self.radius
end

-- http://gamedev.stackexchange.com/questions/18333/circle-line-collision-detection-problem
circle.testRay = function(self,x1,y1,x2,y2)
	local dx,dy = x2-x1,y2-y1
	local vx,vy = x1-self.x,y1-self.y
	local t1,t2 = 0,1
	local r2    = self.radius^2
	local l2    = vx*vx+vy*vy
	if l2 < r2 then return true,t1 end
	local a     = dx*dx + dy*dy
	local b     = 2*(vx*dx+vy*dy)
	local c     = l2 - r2
	
	local discriminant = b^2 - 4*a*c
	if discriminant < 0 then return false end
	local root= discriminant^.5
	local t1  = (-b - root)/(2*a)
	local t2  = (-b + root)/(2*a)
	if t1 <= 1 and t1 >= 0 then return true,t1 end
	if t2 <= 1 and t2 >= 0 then return true,t2 end
end

circle.scale = function(self,scale)
	self.radius = self.radius*scale
end

circle.move = function(self,dx,dy)
	self.x,self.y = self.x+dx,self.y+dy
end

circle.setPosition = function(self,x,y)
	self.x,self.y = x,y
end

circle.unpack = function(self)
	return self.x,self.y,self.radius
end

circle.draw = function(self,mode)
	draw(mode,self.x,self.y,self.radius)
end

return circle