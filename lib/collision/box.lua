local abs   = math.abs
local rect  = love.graphics.rectangle

local box  = {__type = 'box'}
box.__index= box

function box.new(x,y,w,h)
	assert(w > -1 and h > -1, 'Width and height must be non-negative!')
	self       = {}
	self.x     = x
	self.y     = y
	self.width = w
	self.height= h
	return setmetatable(self,box)
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

function box:unpack()
	return self.x,self.y,self.width,self.height
end

function box:testBox(bx,by,bw,bh)
	local x,y,w,h = box.unpack(self)
	local x2,y2   = x+w,y+h
	local bx2,by2 = bx+bw,by+bh
	if x2 > bx and x < bx2 and y2 > by and y < by2 then
		cx,cy   = x+w/2,y+w/2
		cbx,cby = bx+bw/2,by+bh/2
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