local spatialhash= include ((...):getFolderPath() .. 'spatialhash')
local box        = include ((...):getFolderPath() .. 'box')
local circle     = include ((...):getFolderPath() .. 'circle')
local class      = class 'BoxCollisionManager'
local test_case  = {
	box   = {box= box.testBox,    circle= box.testCircle},
	circle= {box= circle.testBox, circle= circle.testCircle},
}

function class.init(s,cell_size,onCollision,endCollision)
	s.shapes           = {}
	s.collideLastUpdate= {}
	s.spatialhash      = spatialhash.new(cell_size)
	s.onCollision      = onCollision
	s.endCollision     = endCollision
end

function class:addShape(shape,isPassive)
	self.shapes[shape] = {shape = shape,isActive = not isPassive}
end

function class:removeShape(shape)
	self.shapes[shape] = nil
	self.spatialhash:unsetBox(shape)
end

function class:clear()
	class.init(self, self.spatialhash:getCellSize(), self.onCollision, self.endCollision)
end

function class:setActive(shape,isActive)
	self.shapes[shape].isActive = isActive
end

function class:isActive(shape)
	return self.shapes[shape].isActive
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
	
	for shape,data in pairs(self.shapes) do
		local x,y,w,h = shape:bbox()
		hash:setBox(shape,x,y,w,h)
		
		if data.isActive then active[shape] = shape end		
	end
	
	for shape in pairs(active) do
		local neighbors   = hash:getNeighbors(shape)
		checkedPairs[shape] = {}
		collided[shape]     = {}
		local shape_type    = shape:type()
		
		for othershape in pairs(neighbors) do
			local othershape_type = othershape:type()
			
			if not (checkedPairs[othershape] and checkedPairs[othershape][shape]) then
				local hit,dx,dy = test_case[shape_type][othershape_type](shape,othershape:unpack())
								
				if hit then
					if oc then oc(shape,othershape,dx,dy) end
					collided[shape][othershape] = true
					
					if clu[shape] then clu[shape][othershape] = nil end
					if clu[othershape] then clu[othershape][shape] = nil end
				end
				
				checkedPairs[shape][othershape] = true
			end
		end
		
	end
	
	if ec then 
		local separatedPairs = clu
		
		for shape,collided in pairs(separatedPairs) do
			for othershape in pairs(collided) do
				ec(shape,othershape)
			end
		end
		
	end
	
	self.collideLastUpdate = collided
end

return class