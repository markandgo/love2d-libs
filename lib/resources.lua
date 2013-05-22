local weakValue = {__mode = 'v'}
local autoTable = {__index = function(t,k) rawset(t,k, setmetatable({},weakValue) ) return t[k] end}

local res = {
	audio = setmetatable({},weakValue),
	image = setmetatable({},weakValue),
	font  = setmetatable({},autoTable),
}

function res.loadImage(filename)
	filename = filename:stripExcessSlash()
	if res.image[filename] then return res.image[filename] end
	local image        = love.graphics.newImage(filename)
	res.image[filename]= image
	return image
end

function res.loadAudio(filename,type)
	filename = filename:stripExcessSlash()
	if res.audio[filename] then return res.audio[filename] end
	local audio        = love.audio.newSource(filename,type)
	res.audio[filename]= audio
	return audio
end

function res.loadFont(filename,arg2)
	filename = filename:stripExcessSlash()
	if type(arg2) ~= 'string' then
		local size = arg2
		local font = res.font[filename][size] or love.graphics.newFont(filename,size)
		res.font[filename][size] = font
		
		return font
	end
	
	local glyphs = arg2
	local font   = res.font[filename].image or love.graphics.newImageFont(filename,glyphs)
	res.font[filename].image = font
	
	return font
end

return res