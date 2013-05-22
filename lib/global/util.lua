local lfs = love.filesystem


include = function(path,moduleTable)
	path = path:removeUpDirectory():gsub('[\\%.]','/'):stripExcessSlash()
	
	if lfs.isFile(path..'.lua') then
		return require(path)
	end
	
	if lfs.isFile(path..'/init.lua') then
		return require(path)
	end
	
	moduleTable     = moduleTable or {}
	local filelist  = lfs.enumerate(path)
	for i = 1,#filelist do
		local filepath = path .. '/' .. filelist[i]
		if lfs.isFile(filepath) then
			local moduleName = filepath:match'([^/]+).lua$'
			if moduleName then
				moduleTable[moduleName] = require(path .. '.' .. moduleName)
			end
		elseif lfs.isDirectory(filepath) then
			local folder        = filelist[i]
			moduleTable[folder] = {}
			include(filepath,moduleTable)
		end
	end
	return moduleTable
end