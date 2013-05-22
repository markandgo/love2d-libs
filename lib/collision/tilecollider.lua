--[[
Tile Collider 4.0

Copyright (c) 2013 Minh Ngo

Permission is hereby granted, free of charge, to any person 
obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, 
publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
--]]
local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min

local t   = setmetatable({startzero = nil},{__call = function(self,...) return self.new(...) end})
t.__index = t

-----------------------------------------------------------
-- example collision callback, return true if tile/slope is collidable
local function isResolvable(side,value,x,y)
end
-----------------------------------------------------------
local function getTileRange(tw,th,x,y,w,h)
	gx,gy   = floor(x/tw)+1,floor(y/th)+1
	gx2,gy2 = w == 0 and gx or ceil( (x+w)/tw ), h == 0 and gy or ceil( (y+h)/th )
	return gx,gy,gx2,gy2
end

local function getActualCoord(self,tx,ty)
	if self.startzero then return tx-1,ty-1 else return tx,ty end
end

-----------------------------------------------------------
function t.new(getTile,tileWidth,tileHeight,isResolvable,heightmaps,startzero)
	local o = {
		getTile     = getTile,
		tileWidth   = tileWidth,
		tileHeight  = tileHeight,
		isResolvable= isResolvable,
		heightmaps  = heightmaps or {},
		startzero   = startzero,
	}
	return setmetatable(o,t)
end
-----------------------------------------------------------
function t:resolve(side,x,y,w,h)
	local tw,th        = self.tileWidth,self.tileHeight
	local gx,gy,gx2,gy2= getTileRange(tw,th,x,y,w,h)
	local newx         = x
	local newy         = y
	local getTile      = self.getTile
	local isResolvable = self.isResolvable
	local heightmaps   = self.heightmaps
	
	for tx = gx,gx2 do
		for ty = gy,gy2 do 
		
			local actualtx,actualty = getActualCoord(self,tx,ty)
			local tile = getTile(actualtx,actualty)
			
			if tile then
				local hmap,ti,bi,li,ri
				
				if side == 'left' or side == 'right' then
					hmap = heightmaps[tile] and heightmaps[tile].horizontal
					if hmap then
						ti = floor(y-(ty-1)*th)+1
						bi = ceil(y+h-(ty-1)*th)
						ti = ti > th and th or ti < 1 and 1 or ti
						bi = bi > th and th or bi < 1 and 1 or bi
					end
					
					if side == 'right' then
					
						if hmap then
							minx = min(x,tx*tw-w-hmap[ti],tx*tw-w-hmap[bi])
							if minx ~= x and isResolvable('right',tile,actualtx,actualty) then
								newx = min(minx,newx)
							end
						elseif isResolvable('right',tile,actualtx,actualty) then
							newx = min(newx,(tx-1)*tw-w)
						end
						
					else
					
						if hmap then
							maxx = max(x,(tx-1)*tw+hmap[ti],(tx-1)*tw+hmap[bi])
							if maxx ~= x and isResolvable('left',tile,actualtx,actualty) then
								newx = max(maxx,newx)
							end
						elseif isResolvable('left',tile,actualtx,actualty) then
							newx = max(newx,tx*tw)
						end
						
					end	
					
				else
					hmap = heightmaps[tile] and heightmaps[tile].vertical
					if hmap then
						li   = floor(x-(tx-1)*tw)+1
						ri   = ceil((x+w)-(tx-1)*tw)
						li   = li > tw and tw or li < 1 and 1 or li
						ri   = ri > tw and tw or ri < 1 and 1 or ri 	
					end
					
					if side == 'bottom' then
					
						if hmap then
							local miny = min(y,ty*th-h-hmap[li],ty*th-h-hmap[ri])
							if miny ~= y and isResolvable('bottom',tile,actualtx,actualty) then
								newy = min(miny,newy)
							end
						elseif isResolvable('bottom',tile,actualtx,actualty) then
							newy = min(newy,(ty-1)*th-h)
						end
						
					else
					
						if hmap then
							local maxy = max(y,(ty-1)*th+hmap[li],(ty-1)*th+hmap[ri])
							if maxy ~= y and isResolvable('top',tile,actualtx,actualty) then
								newy = max(maxy,newy)
							end
						elseif isResolvable('top',tile,actualtx,actualty) then
							newy = max(newy,ty*th)
						end
						
					end
					
				end	
				
			end
			
		end
	end
	
	return newx,newy
end
-----------------------------------------------------------
return t