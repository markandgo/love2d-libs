local draw = love.graphics.circle
local min  = math.min
local max  = math.max
local abs  = math.abs

local circle = class 'Circle'

circle.init = function(self,x,y,r)
	self.x       = x
	self.y       = y
	self.radius  = r
end

circle.bbox = function(self)
	local x,y,r = self.x,self.y,self.radius
	return x-r,y-r,r*2,r*2
end

circle.testBox = function(self,bx,by,bw,bh)
	local x,y,r = circle.unpack(self)

	local bx2,by2 = bx+bw,by+bh
	
	local near_x,near_y = x,y
	
	if x < bx then near_x = bx 
	elseif x > bx2 then near_x = bx2 end
	
	if y < by then near_y = by 
	elseif y > by2 then near_y = by2 end
	
	if near_x == x and near_y == y then
		local move_x,move_y
		
		local left_dx,right_dx = x-bx, x-bx2
		if abs(left_dx) < abs(right_dx) then
			move_x = left_dx+r
		else
			move_x = right_dx-r
		end
		
		local top_dy,bot_dy = y-by, y-by2
		if abs(top_dy) < abs(bot_dy) then
			move_y = top_dy+r
		else
			move_y = bot_dy-r
		end
		
		if abs(move_x) < abs(move_y) then return true,-move_x,0 end
		return true,0,-move_y
	end
	
	local dx,dy = near_x-x, near_y-y
	local center_to_closest   = dx*dx+dy*dy
	
	if not (center_to_closest < r*r) then return false end
	
	center_to_closest = center_to_closest^.5
	
	local ux,uy = dx/center_to_closest, dy/center_to_closest
	local rx,ry = ux*r,uy*r
	
	local move_x,move_y = rx-dx, ry-dy
	
	return true,-move_x,-move_y
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
