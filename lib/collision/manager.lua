local spatialhash= include ((...):getFolderPath() .. 'spatialhash')
local box        = include ((...):getFolderPath() .. 'box')
local circle     = include ((...):getFolderPath() .. 'circle')
local manager    = class 'BoxCollisionManager'
local test_case  = {
	box   = {box= box.testBox,    circle= box.testCircle},
	circle= {box= circle.testBox, circle= circle.testCircle},
}

function manager.init(s,cell_size,onCollision,endCollision)
	s.shapes           = {}
	s.collideLastUpdate= {}
	s.spatialhash      = spatialhash.new(cell_size)
	s.onCollision      = onCollision
	s.endCollision     = endCollision
end

function manager:addShape(shape,type,group,noclip)
	self.shapes[shape] = {
		shape   = shape,
		isActive= type ~= 'passive', 
		groups  = (function() local t = {}; if group then t[group] = true end return t end)(),
		noclip  = noclip,
	}
	
end

function manager:removeShape(shape)
	self.shapes[shape] = nil
	self.spatialhash:unsetBox(shape)
end

function manager:group(name,shapes)
	for _,shape in pairs(shapes) do
		self.shapes[shape].groups[name] = true
	end
end

function manager:ungroup(name,shapes)
	for _,shape in pairs(shapes) do
		self.shapes[shape].groups[name] = nil
	end
end

function manager:getGroup(shape)
	local groups = self.shapes[shape].groups
	local group
	local recur
	recur = function()
		group = next(groups,group)
		if group then return group,recur() end
	end
	return recur()
end

function manager:clear()
	manager.init(self, self.spatialhash:getCellSize(), self.onCollision, self.endCollision)
end

function manager:setActive(shape,isActive)
	self.shapes[shape].isActive = isActive
end

function manager:isActive(shape)
	return self.shapes[shape].isActive
end

function manager:setNoClip(shape,bool)
	self.shapes[shape].noclip = bool
end

function manager:hasNoClip(shape)
	return self.shapes[shape].noclip
end

local isInGroup = function(shape_groups,othershape_groups)
	for group in pairs(shape_groups) do
		if othershape_groups[group] then return true end
	end
end

function manager:update(dt)
	local gd          = self.getDimensions
	local oc          = self.onCollision
	local ec          = self.endCollision
	local hash        = self.spatialhash
	local active      = {}
	local checkedPairs= {}
	local collided    = {}
	local clu         = self.collideLastUpdate
	local shapes      = self.shapes
	
	for shape,data in pairs(self.shapes) do
		local x,y,w,h = shape:bbox()
		hash:setBox(shape,x,y,w,h)
		
		if data.isActive and not data.noclip then active[shape] = shape end		
	end
	
	for shape in pairs(active) do
		local neighbors     = hash:getNeighbors(shape)
		checkedPairs[shape] = {}
		collided[shape]     = {}
		local shape_type    = shape:type()
		local shape_groups  = shapes[shape].groups
		
		for othershape in pairs(neighbors) do
			local othershape_type  = othershape:type()
			local os_data          = shapes[othershape]
			local os_groups        = os_data.groups
			local os_noclip        = os_data.noclip
			
			if not (checkedPairs[othershape] and 
				checkedPairs[othershape][shape] or 
				isInGroup(shape_groups,os_groups) or
				os_noclip) then
				
				local hit,dx,dy = test_case[shape_type][othershape_type](shape,othershape:unpack())
								
				if hit then
					if oc then oc(dt,shape,othershape,dx,dy) end
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
				ec(dt,shape,othershape)
			end
		end
		
	end
	
	self.collideLastUpdate = collided
end

return manager