local dir = ...

-- ##########################
-- GLOBALS
-- ##########################

require(dir .. '.global.addon')
require(dir .. '.global.class')
require(dir .. '.global.event')
require(dir .. '.global.serialize')
require(dir .. '.global.state')
require(dir .. '.global.string+')
require(dir .. '.global.util')
require(dir .. '.global.vector')
require(dir .. '.global.utf8')

-- ##########################
-- SINGLE
-- ##########################

local module = {
	animation= require(dir .. '.animation'),
	camera   = require(dir .. '.camera'),
	easing   = require(dir .. '.easing'),
	gamestate= require(dir .. '.gamestate'),
	timer    = require(dir .. '.timer'),
	resources= require(dir .. '.resources'),
	group    = require(dir .. '.group'),
	install  = require(dir .. '.install'),
}

-- ##########################
-- MULTI
-- ##########################

module.maptools = include(dir .. '.maptools')
module.collision= include(dir .. '.collision')
module.gui      = include(dir .. '.gui')
module.managers = include(dir .. '.managers')
module.console  = include(dir .. '.console')

return module
