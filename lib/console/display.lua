-- #####################################
-- PRIVATE
-- #####################################

local path     = (...):match('^.+[%.\\/]') or ''
local fontpath = path:gsub('%.','/')..'/../assets/DejaVuSansMono.ttf'
local monoFont = love.graphics.newFont(fontpath:removeUpDirectory(),12)

local has_canvas_support = love.graphics.isSupported 'canvas'

local default_text_color = {255,255,255,255}
local default_bg_color   = {64,64,64,192}

local color_cache = {}

local wrapDraw = function(draw,...)
	local r,g,b,a  = love.graphics.getColor()
	love.graphics.setColor(255,255,255)
	local old_blend = love.graphics.getBlendMode()
	love.graphics.setBlendMode 'alpha'
	
	draw(...)
	
	love.graphics.setColor(r,g,b,a)
	love.graphics.setBlendMode(old_blend)
end

local drawChars = function(self,x,y)
	local old_font = love.graphics.getFont()
	love.graphics.setFont(self.font)
	local font_width = self.font_width
	local font_height = self.font_height
	x,y = x or 0,y or 0
	
	for col = 1,self.chars_width do
		local t = self.chars_matrix[col]
		local ox = (col-1)*font_width
		for row = 1,self.chars_height do
			local data = t and t[row]
			local char,text_color,bg_color
			if data then
				char = data.char
				text_color = data.text_color
				bg_color = data.bg_color
			end
			local oy = (row-1)*font_height
			love.graphics.setColor(bg_color or self.bg_color)
			love.graphics.rectangle('fill',x+ox,y+oy,font_width,font_height)
			if char then
				love.graphics.setColor(text_color)
				love.graphics.print(char,x,y,nil,nil,nil,-ox,-oy)
			end
		end
	end
	
	if old_font then love.graphics.setFont(old_font) end
end

local clearCanvas = function(self, x,y, width,height, bg_color)
	love.graphics.setCanvas(self.canvas)
		love.graphics.setScissor(x,y,width,height)
		self.canvas:clear()
		-- have to set canvas before scissor else weird offset
		love.graphics.setScissor()
		if bg_color then 
			love.graphics.setColor(bg_color)
			love.graphics.rectangle('fill',x,y,width,height)
		end
	love.graphics.setCanvas()
end

local proxyClearCanvas = function(self, x,y, width,height, bg_color)
	wrapDraw(clearCanvas,self, x,y, width,height, bg_color)
end

local drawCharToCanvas = function(self,data,col,row)
	local text_color = data.text_color
	local bg_color   = data.bg_color
	
	local x,y = (col-1)*self.font_width, (row-1)*self.font_height
	clearCanvas(self, x,y, self.font_width,self.font_height,bg_color)
	
	love.graphics.setCanvas(self.canvas)
		love.graphics.setColor(text_color)
		love.graphics.print(data.char,x,y)
	love.graphics.setCanvas()
end

local proxyDrawCharToCanvas = function(self,data,col,row)
	wrapDraw(drawCharToCanvas,self,data,col,row)
end

local draw = function(self,x,y)
	if has_canvas_support then
		if not self.canvas then
			self.canvas = love.graphics.newCanvas(self.font_width*self.chars_width, self.font_height*self.chars_height)
			self.canvas:renderTo(function()
				drawChars(self)
			end)
		end
		love.graphics.setBlendMode 'premultiplied'
		love.graphics.draw(self.canvas,x,y)
	else
		drawChars(self,x,y)
	end
end

local proxyDraw = function(self,x,y)
	wrapDraw(draw,self,x,y)
end

local assertBounds = function(x,y,x2,y2,cw,ch)
	if not (x <= x2 and y <= y2) then error 'Lower bounds must be less than or equal to upper bounds!' end
	if not (x > 0 and y > 0) then error 'Lower bounds must be greater than zero!' end
	if not (x2 <= cw and y2 <= ch) then error 'Upper bounds must be less than or equal to width/height!' end
end

local getColor = function(rgba)
	local r,g,b,a = rgba[1],rgba[2],rgba[3],rgba[4] or 255
	if not (r and g and b) then error 'Missing rgb value(s)!' end
	local color_index = r..','..g..','..b..','..a
	local color = color_cache[color_index]
	if not color then color = {r,g,b,a}; color_cache[color_index] = color end
	return color
end

local copyColor = function(rgba,t)
	if t then
		for i = 1,4 do
			t[i] = rgba[i] or 255
		end
		return
	end
	return {rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255}
end

-- #####################################
-- CLASS
-- #####################################

local display = class 'Display'

function display:init(chars_width,chars_height, font, text_color,bg_color)
	assert(chars_width > 0 and chars_height > 0, 'Display must have width & height greater than 0!')
	
	local t = self
	t.chars_height= chars_height
	t.chars_width = chars_width
	t.font        = font or monoFont
	t.text_color  = copyColor(text_color or default_text_color)
	t.bg_color    = copyColor(bg_color or default_bg_color)
	t.chars_matrix= {}
	t.font_width  = t.font:getWidth 'a'
	t.font_height = t.font:getHeight()
	t.canvas      = nil
end

-- #####################################
-- GETTERS
-- #####################################

function display:getChar(x,y)
	local data = self.chars_matrix[x] and self.chars_matrix[x][y]
	if data then return data.char,data.text_color,data.bg_color end
end

function display:getSize()
	return self.chars_width,self.chars_height
end

function display:getFont()
	return self.font,self.font_width,self.font_height
end

function display:getDefaultColors()
	return self.text_color,self.bg_color
end

function display:iterate(x,y,x2,y2)
	local cw  = self.chars_width
	local ch  = self.chars_height
	x,y       = x or 1,y or 1
	x2,y2     = x2 or cw,y2 or ch
	
	assertBounds(x,y,x2,y2,cw,ch)
	
	local xi,yi  = x-1,y
	return function(self,_)
		while true do
			xi = xi+1
			if xi > x2 then yi = yi + 1; xi = x end
			if yi > y2 then return end
			
			return xi,yi,display.getChar(self,xi,yi)
		end
	end,self,nil
end

-- #####################################
-- SETTERS
-- #####################################

function display:setSize(width,height)
	self.chars_width,self.chars_height = width,height
	self.canvas = nil
end

function display:setFont(font)
	self.font = font 
	self.font_height = font:getHeight()
	self.font_width  = font:getWidth 'a'
	self.canvas = nil
end

function display:setDefaultColors(text_color,bg_color)
	copyColor(text_color or default_text_color, self.text_color)
	copyColor(bg_color or default_bg_color, self.bg_color)
	self.canvas  = nil
end

-- #####################################
-- MAIN
-- #####################################

function display:write(str,x,y, text_color,bg_color)
	str       = tostring(str)
	x,y       = x or 1,y or 1
	
	if x > self.chars_width or y > self.chars_height then 
		error 'Writing out of display bound!' 
	end
	
	local len = #str
	local curr_index = 1
	local curr_x,curr_y = x,y
	local matrix = self.chars_matrix
	
	if has_canvas_support then
		local old_font = love.graphics.getFont()
		love.graphics.setFont(self.font)
	end
	
	while curr_index < len+1 do
		local char = str:sub(curr_index,curr_index)
		matrix[curr_x] = matrix[curr_x] or {}
		
		local data = matrix[curr_x][curr_y]
		if not data then data = {}; matrix[curr_x][curr_y] = data end
		
		data.char       = char 
		data.text_color = text_color and getColor(text_color) or self.text_color 
		data.bg_color   = bg_color and getColor(bg_color) or self.bg_color
		
		if self.canvas then proxyDrawCharToCanvas(self,data,curr_x,curr_y) end
		
		curr_x = curr_x+1
		if curr_x > self.chars_width then 
			curr_y = curr_y+1; curr_x = 1 
		end
		if curr_y > self.chars_height then break end
		curr_index = curr_index + 1
	end
	
	if has_canvas_support then
		if old_font then love.graphics.setFont(old_font) end
	end
end

function display:clear(x,y,x2,y2)
	local cw  = self.chars_width
	local ch  = self.chars_height
	x,y       = x or 1,y or 1
	x2,y2     = x2 or cw,y2 or ch
	
	assertBounds(x,y,x2,y2,cw,ch)
	
	for x = x,x2 do
		if x > cw then break end
		
		local t = self.chars_matrix[x]
		
		for y = y,y2 do 
			if y > ch then break end
			
			local data = t and t[y]
			if data then t[y] = nil end
		end
	end
	if self.canvas then 
		proxyClearCanvas(self,0,0,cw*self.font_width,ch*self.font_height, self.bg_color)
	end
end

function display:draw(x,y)
	proxyDraw(self,x,y)
end

return display
