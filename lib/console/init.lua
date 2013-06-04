local path   = ...
local output = require(path..'.output')
local input  = require(path..'.input')
local display= require(path..'.display')

local console = class 'Console'

function console.newOutput(...)
	return output(...)
end

function console.newInput(...)
	return input(...)
end

function console.newDisplay(...)
	return display(...)
end

return console
