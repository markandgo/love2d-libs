-- http://lua-users.org/wiki/SplitJoin
function string:explode(sep,isPattern)
	local sep, fields = sep or isPattern and '[^%s]+' or '%s',{}
	local pattern     = isPattern and sep or string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function string:getPathComponents()
	local dir,name,ext = self:match('^(.-)([^\\/]-)%.?([^\\/%.]*)$')
	if #name == 0 then name = ext; ext = '' end
	return dir,name,ext
end

function string:removeUpDirectory()
	while self:find('%.%.[\\/]+') do
		self = self:gsub('[^\\/]*[\\/]*%.%.[\\/]+','')
	end
	return self
end

function string:stripExcessSlash()
	return self:gsub('[\\/]+','/'):match('^/?(.*)')
end

function string:getFolderPath()
	return self:match('^(.-)[^%.\\/]*$')
end

function string:lines()
	local index = 1
	local len   = #self
	return function()
		if index > len then return end
		local i,j,line = self:find( '([^\r\n]*)\r?\n?', index )
		index = j+1
		return line
	end
end