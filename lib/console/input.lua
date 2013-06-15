local input = class 'Input'

function input:init(repeat_delay,repeat_interval,max_history)
	local t = self
	t.chars              = {}
	t.history            = {}
	t.max_history        = max_history or 20
	t.cursor_pos         = 1
	t.repeat_delay       = repeat_delay or 0.2
	t.repeat_interval    = repeat_interval or 0.05
	t.previous_index     = 0
	t.previous_remember  = false -- pressing up after flushing returns to previous index
	
	-- PRIVATE
	t._last_keypressed   = nil
	t._last_unicode      = nil
	t._remaining_delay   = t.repeat_delay
	t._remaining_interval= t.repeat_interval
end

-- #######################################
-- HOOKS
-- #######################################

local key_hooks = {
	kpenter   = function(self) input.flush(self) end,
	
	['return']= function(self) input.flush(self) end,
	
	backspace = function(self)
		self.cursor_pos = self.cursor_pos-1
		if not self.chars[self.cursor_pos] then self.cursor_pos = 1 return end
		table.remove(self.chars,self.cursor_pos)
	end,
	
	delete = function(self)
		table.remove(self.chars,self.cursor_pos)
	end,
	
	home = function(self)
		input.setCursorPos(self,1)
	end,
	
	['end'] = function(self)
		input.setCursorPos(self,-1)
	end,
	
	left = function(self)
		input.setCursorPos(self, input.getCursorPos(self)-1 )
	end,
	
	right = function(self)
		input.setCursorPos(self, input.getCursorPos(self)+1 )
	end,
	
	up = function(self)
		input.setPrevious(self, self.previous_index+1)
	end,
	
	down = function(self)
		local prev_index = self.previous_index
		if not input.setPrevious(self, prev_index-1) then
			input.clear(self)
			self.previous_index = 0
		end
	end,
}

-- #######################################
-- OVERRIDEABLE CALLBACKS
-- #######################################

function input:onFlush(str)
	
end

-- #######################################
-- USEFUL FUNCTIONS
-- #######################################

function input:clear()
	self.chars      = {}
	self.cursor_pos = 1
end

function input:flush()
	local str = table.concat(self.chars)
	if str ~= '' and str ~= self.history[1] then
		table.insert(self.history,1,str)
		local history_size = #self.history
		while history_size > self.max_history do
			table.remove(self.history) 
		end
	end
	if self.previous_remember then
		self.previous_index = math.max(self.previous_index-1,0)
	else self.previous_index = 0 end
	if self.onFlush then self:onFlush(str) end
	input.clear(self)
end

function input:setPrevious(index)
	local command    = self.history[index]
	if not command then return false end
	self.chars       = {}
	local cursor_pos = 1
	for char in command:gmatch '.' do
		cursor_pos = cursor_pos + 1
		table.insert(self.chars,char)
	end
	self.cursor_pos     = cursor_pos
	self.previous_index = index
	return true
end

function input:getChar(char_pos)
	if char_pos < 0 then char_pos = #self.chars+1+char_pos end
	return self.chars[char_pos]
end

function input:setCursorPos(cursor_pos)
	if cursor_pos < 0 then self.cursor_pos = #self.chars+2+cursor_pos return end 
	self.cursor_pos = math.min(#self.chars, math.max(cursor_pos,1))
end

function input:getCursorPos() return self.cursor_pos end

-- #######################################
-- LOVE CALLBACKS
-- #######################################

function input:keypressed(key,unicode)
	if key_hooks[key] then 
		key_hooks[key](self)
	elseif unicode > 31 and unicode < 127 then
		table.insert(self.chars,self.cursor_pos,string.char(unicode))
		self.cursor_pos = self.cursor_pos + 1
	end
	
	if self._last_keypressed ~= key then
		self._remaining_delay    = self.repeat_delay
		self._remaining_interval = self.repeat_interval
	end
	
	self._last_keypressed= key
	self._last_unicode   = unicode
end

function input:update(dt)
	if not (self._last_keypressed and 
		love.keyboard.isDown(self._last_keypressed) )then 
		
		self._remaining_delay   = self.repeat_delay
		self._remaining_interval= self.repeat_interval
		return 
	end
	self._remaining_delay = self._remaining_delay - dt
	if self._remaining_delay <= 0 then
		self._remaining_interval = self._remaining_interval - dt
		if self._remaining_interval <= 0 then
			self._remaining_interval = self.repeat_interval
			input.keypressed(self,self._last_keypressed,self._last_unicode)
		end
	end
end

return input