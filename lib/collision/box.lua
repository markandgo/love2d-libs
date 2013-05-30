local abs   = math.abs
local rect  = love.graphics.rectangle

local box  = class 'Box'

function box:init(x,y,w,h)
	assert(w > -1 and h > -1, 'Width and height must be non-negative!')
	self.x     = x
	self.y     = y
	self.width = w
	self.height= h
end

function box:setPosition(x,y)
	self.x = x; self.y = y
end

function box:move(dx,dy)
	self.x = self.x+dx 
	self.y = self.y+dy
end

function box:setSize(w,h)
	self.width = w; self.height = h
end

function box:scale(sx,sy)
	self.width = self.width*sx
	self.height= self.height*(sy or sx)
end

function box:bbox()
	return box.unpack(self)
end

function box:unpack()
	return self.x,self.y,self.width,self.height
end

-- http://www.metanetsoftware.com/technique/tutorialA.html#section3
function box:testCircle(x,y,r)
	local bx,by,bw,bh = box.unpack(self)
	local bx2,by2     = bx+bw,by+bh
	
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
		
		if abs(move_x) < abs(move_y) then return true,move_x,0 end
		return true,0,move_y
	end
	
	local dx,dy = near_x-x, near_y-y
	local center_to_closest   = dx*dx+dy*dy
	
	if not (center_to_closest < r*r) then return false end
	
	center_to_closest = center_to_closest^.5
	
	local ux,uy = dx/center_to_closest, dy/center_to_closest
	local rx,ry = ux*r,uy*r
	
	local move_x,move_y = rx-dx, ry-dy
	
	return true,move_x,move_y
end

function box:testBox(bx,by,bw,bh)
	local x,y,w,h = box.unpack(self)
	local x2,y2   = x+w,y+h
	local bx2,by2 = bx+bw,by+bh
	if x2 > bx and x < bx2 and y2 > by and y < by2 then
		local cx,cy  = x+w/2,y+h/2
		local cbx,cby= bx+bw/2,by+bh/2
		
		local dx,dy = 0,0
		
		if cx < cbx then
			dx = bx-(x+w)
		else
			dx = bx+bw-x
		end
		if cy < cby then
			dy = by-(y+h)
		else
			dy = by+bh-y
		end
		if abs(dy) > abs(dx) then dy = 0 else dx = 0 end
		return true,dx,dy
	end
	return false
end

function box:testPoint(x,y)
	return x > self.x and x < self.x+self.width and y > self.y and y < self.y+self.height
end

-- kikito box line intersection
function box:testRay(x1,y1,x2,y2)
	local x,y,w,h = box.unpack(self)
	local dx, dy  = x2-x1, y2-y1
	local t0, t1  = 0, 1
	local p, q, r

	for side = 1,4 do
		if     side == 1 then p,q = -dx, x1 - x
		elseif side == 2 then p,q =  dx, x + w - x1
		elseif side == 3 then p,q = -dy, y1 - y
		else                  p,q =  dy, y + h - y1
		end

		if p == 0 then
			if q < 0 then return nil end  -- Segment is parallel and outside the bbox
		else
			r = q / p
			if p < 0 then
				if     r > t1 then return nil
				elseif r > t0 then t0 = r
				end
			else -- p > 0
				if     r < t0 then return nil
				elseif r < t1 then t1 = r
				end
			end
		end
	end

	return true,t0
end

function box:draw(mode)
	rect(mode,box.unpack(self))
end

return box
