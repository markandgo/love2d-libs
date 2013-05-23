local __settings = {__index = function(t,k) rawset(t,k,{}) return t[k] end,__mode= 'k'}

local t   = class 'group'
t.__call  = function(self,name) return t.getLayer(self,name) end

function t:init()
	self.layerByOrder= {}
	self.layerByName = {}
	self.settings    = setmetatable({},__settings)
	self.x           = 0
	self.y           = 0
end

function t:insert(name,layer,xtransfactor,ytransfactor,isDrawable)
	xtransfactor= xtransfactor or 1
	ytransfactor= ytransfactor or xtransfactor
	
	table.insert(self.layerByOrder,layer)
	self.layerByName[name] = layer
	
	local t        = self.settings[layer]
	t.isDrawable   = isDrawable == nil and true or isDrawable
	t.xtransfactor = xtransfactor
	t.ytransfactor = ytransfactor
	t.name         = name
end

function t:getLayer(name)
	return self.layerByName[name]
end

function t:remove(name)
	local layer = self.layerByName[name]
	self.layerByName[name] = nil
	for i,l in ipairs(self.layerByOrder) do
		if l == layer then table.remove(self.layerByOrder,i) return end
	end
end

function t:swap(name1,name2)
	local layer1,layer2 = self.layerByName[name1], self.layerByName[name2]
	local l1,l2
	for i,layer in ipairs(self.layerByOrder) do
		if layer == layer1 then l1 = i elseif layer == layer2 then l2 = i end
	end
	local order = self.layerByOrder
	order[l1],order[l2] = order[l2],order[l1]
end

local directions = {
	down = function(index,order) order[index-1],order[index] = order[index],order[index-1] end, 
	up   = function(index,order) order[index+1],order[index] = order[index],order[index+1] end, 
	front= function(index,order) table.insert(order, table.remove(order,index) )           end, 
	back = function(index,order) table.insert(order, 1, table.remove(order,index) )        end,  
}

function t:move(name,direction)
	local layer = self.layerByName[name]
	local order = self.layerByOrder
	local j
	for i,l in ipairs(order) do
		if l == layer then j = i break end
	end
	
	directions[direction](j,order)
end

function t:sort(func)
	table.sort(self.layerByOrder,func)
end

function t:totalLayers()
	return #self.layerByOrder
end

function t:setDrawable(name,bool)
	if bool == nil then error('expected true or false for drawable') end
	local layer = self.layerByName[name]
	self.settings[layer].isDrawable = bool
end

function t:isDrawable(name)
	local layer = self.layerByName[name]
	return self.settings[layer].isDrawable
end

function t:translate(dx,dy)
	self.x,self.y = self.x+dx,self.y+dy
end

function t:setTranslation(x,y)
	self.x,self.y = x,y
end

function t:getTranslation()
	return self.x,self.y
end

function t:setTransFactors(name,xfactor,yfactor)
	local layer = self.layerByName[name]
	self.settings[layer].xtransfactor = xfactor
	self.settings[layer].ytransfactor = yfactor or xfactor
end

function t:getTransFactors(name)
	local layer    = self.layerByName[name]
	local settings = self.settings[layer]
	return settings.xtransfactor, settings.ytransfactor
end

function t:callback(name,...)
	if name == 'draw' then return t.draw(self,...) end
	for i,layer in ipairs(self.layerByOrder) do
		if layer[name] then layer[name](layer,...) end
	end
end

function t:draw(...)
	local settings = self.settings
	for i,layer in ipairs(self.layerByOrder) do
		love.graphics.push()
			local xfactor = settings[layer].xtransfactor
			local yfactor = settings[layer].ytransfactor
			local dx,dy   = xfactor*self.x, yfactor*self.y
			love.graphics.translate(dx,dy)
			if settings[layer].isDrawable then
				if layer.draw then layer:draw(...) end
			end
		love.graphics.pop()
	end
end

return t