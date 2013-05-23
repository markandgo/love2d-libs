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
}

-- ##########################
-- MULTI
-- ##########################

module.maptools = {}
include(dir .. '.maptools',module.maptools)

module.collision = {}
include(dir .. '.collision',module.collision)

module.gui = {}
include(dir .. '.gui',module.gui)

module.managers = {}
include(dir .. '.managers',module.managers)

-- ##########################
-- INSTALLATION
-- ##########################

module.install = function()
	module.gamestate:register()
end

return module