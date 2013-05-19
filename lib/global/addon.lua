-- v0.80

-- ================
-- DRAW METHODS
-- ================

local lg = love.graphics

if love.graphics.isSupported('canvas') then
	local canvas  = lg.newCanvas(1,1)
	local canvasClass = getmetatable(canvas).__index
	canvasClass.draw  = lg.draw
end

local font  = lg.newFont(1)
local fontClass = getmetatable(font).__index
fontClass.draw  = function(self,...)
	local oldFont = lg.getFont() or lg.newFont(12)
	lg.setFont(self)
	lg.draw(self,...)
	lg.setFont(oldFont)
end

local image = lg.newImage(love.image.newImageData(1,1))
local imageClass = getmetatable(image).__index
imageClass.draw  = lg.draw

local particle = lg.newParticleSystem(image,1)
local pClass   = getmetatable(particle).__index
pClass.draw    = lg.draw

local q = lg.newQuad(0,0,1,1,1,1)
qClass       = getmetatable(q).__index
qClass.drawq = function(self,image,...)
	lg.drawq(image,self,...)
end

local b = lg.newSpriteBatch(image,1)
bClass       = getmetatable(b).__index
bClass.draw  = lg.draw