local enter = {
	kpenter   = true,
	['return']= true,
}

local endKeypress = function(self)
	self.remaining_delay    = self.repeat_delay
	self.remaining_interval = self.repeat_interval
	self.last_keypressed    = nil
	self.last_unicode       = nil
end

local input = class 'Input'

function input:init(repeat_delay,repeat_interval)
	local t = self
	t.chars             = {}
	t.cursor_pos        = 1
	t.repeat_delay      = repeat_delay or 0.2
	t.repeat_interval   = repeat_interval or 0.05
	t.last_keypressed   = nil
	t.last_unicode      = nil
	t.remaining_delay   = t.repeat_delay
	t.remaining_interval= t.repeat_interval
end

function input:onFlush(str)
	
end

function input:clear()
	endKeypress(self)
	self.cursor_pos = 1
end

function input:iterate()
	return ipairs(self.chars)
end

function input:getString()
	return table.concat(self.chars)
end

function input:getLength()
	return #self.chars
end

function input:getChar(char_pos)
	if char_pos < 0 then char_pos = #self.chars+1+char_pos end
	return self.chars[char_pos]
end

function input:setCursorPos(cursor_pos)
	if cursor_pos < 0 then self.cursor_pos = #self.chars+2+cursor_pos return end 
	self.cursor_pos = math.min(#self.chars, math.max(cursor_pos,1))
end

function input:getCursorPos()
	return self.cursor_pos
end

function input:keypressed(key,unicode)
	if enter[key] then
		local str = table.concat(self.chars)
		self:onFlush(str)
		input.init(self,self.repeat_delay,self.repeat_interval)
	elseif key == 'backspace' then
		self.cursor_pos = self.cursor_pos-1
		if not self.chars[self.cursor_pos] then self.cursor_pos = 1 return end
		table.remove(self.chars,self.cursor_pos)
	elseif key == 'delete' then
		table.remove(self.chars,self.cursor_pos)
	elseif key == 'home' then
		input.setCursorPos(self,1)
	elseif key == 'end' then
		input.setCursorPos(self,-1)
	elseif unicode > 31 and unicode < 127 then
		table.insert(self.chars,self.cursor_pos,string.char(unicode))
		self.cursor_pos = self.cursor_pos + 1
	end
	
	if self.last_unicode ~= unicode then
		self.remaining_delay    = self.repeat_delay
		self.remaining_interval = self.repeat_interval
	end
	
	self.last_keypressed= key
	self.last_unicode   = unicode
end

function input:keyreleased(key)
	if key == self.last_keypressed then
		endKeypress(self)
	end
end

function input:update(dt)
	if not self.last_keypressed then return end
	self.remaining_delay = self.remaining_delay - dt
	if self.remaining_delay <= 0 then
		self.remaining_interval = self.remaining_interval - dt
		if self.remaining_interval <= 0 then
			self.remaining_interval = self.repeat_interval
			input.keypressed(self,self.last_keypressed,self.last_unicode)
		end
	end
end

return input