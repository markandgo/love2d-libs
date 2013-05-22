local spatialhash= include ((...):getFolderPath() .. 'spatialhash')
local class      = class 'BoxCollisionManager'

function class.init(s,cell_size,onCollision,endCollision)
	s.boxes            = {}
	s.collideLastUpdate= {}
	s.spatialhash      = spatialhash.new(cell_size)
	s.onCollision      = onCollision
	s.endCollision     = endCollision
end

function class:addBox(box,isPassive)
	self.boxes[box] = {box = box,isActive = not isPassive}
end

function class:setActive(box,isActive)
	self.boxes[box].isActive = isActive
end

function class:update()
	local gd          = self.getDimensions
	local oc          = self.onCollision
	local ec          = self.endCollision
	local hash        = self.spatialhash
	local active      = {}
	local checkedPairs= {}
	local collided    = {}
	local clu         = self.collideLastUpdate
	
	for box,data in pairs(self.boxes) do
		local x,y,w,h = box:unpack()
		hash:setBox(box,x,y,w,h)
		
		if data.isActive then active[box] = box end		
	end
	
	for box in pairs(active) do
		local neighbors   = hash:getNeighbors(box)
		checkedPairs[box] = {}
		collided[box]     = {}
		
		for otherbox in pairs(neighbors) do
			
			if not (checkedPairs[otherbox] and checkedPairs[otherbox][box]) then
				local hit,dx,dy = box:testBox(otherbox:unpack())
								
				if hit then
					if oc then oc(box,otherbox,dx,dy) end
					collided[box][otherbox] = true
					
					if clu[box] then clu[box][otherbox] = nil end
					if clu[otherbox] then clu[otherbox][box] = nil end
				end
				
				checkedPairs[box][otherbox] = true
			end
		end
		
	end
	
	if ec then 
		local separatedPairs = clu
		
		for box,collided in pairs(separatedPairs) do
			for otherbox in pairs(collided) do
				ec(box,otherbox)
			end
		end
		
	end
	
	self.collideLastUpdate = collided
end

return class