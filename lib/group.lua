local t   = class 'group'
t.__call  = function(self,name) return t.members[name] end

function t:init()
	self.members     = {}
	self.membercount = 0
end

function t:add(object,name)
	local key = name or object
	if self.members[key] then return end
	self.members[key]= object
	self.membercount = self.membercount+1
end

function t:remove(name)
	local members = self.members
	if not members[name] then return end
	local obj       = members[name]
	members[name]   = nil
	self.membercount= self.membercount-1
	return obj
end

function t:total()
	return self.membercount
end

function t:pairs()
	return pairs(self.members)
end

function t:callback(callback_name,...)
	for name,object in pairs(self.members) do
		if object[callback_name] then object[callback_name](object,...) end
	end
end

return t