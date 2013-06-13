local output = class 'Output'

function output:init(chars_width,max_size)
	self.lines       = {}
	self.max_size    = max_size or 100
	self.buffer_size = 0
	self.chars_width = chars_width or math.huge
end

function output:write(str)
	for line in str:lines() do
		repeat
			local newline = line:sub(1,self.chars_width)
			table.insert(self.lines,newline)
			line = line:sub(self.chars_width+1)
		until line == ''
	end
	
	local len = #str
	local new_buffer_size = self.buffer_size+len
	while new_buffer_size > self.max_size do
		new_buffer_size = new_buffer_size - #table.remove(self.lines,1)
	end
	self.buffer_size = new_buffer_size
end

function output:getLine(row)
	if row < 0 then row = #self.lines+1+row end
	return self.lines[row]
end

function output:iterate(reverseOrder)
	local lines = self.lines
	local index = reverseOrder and #lines or 1
	local delta = reverseOrder and -1 or 1
	return function()
		local line = lines[index]
		index = index + delta
		return line
	end
end

function output:getLineCount()
	return #self.lines
end

function output:getBufferSize()
	return self.buffer_size
end

function output:getMaxSize()
	return self.max_size
end

function output:setMaxSize(max_size)
	self.max_size = max_size or 100
end

function output:setWidth(chars_width)
	self.chars_width = chars_width
end

function output:getWidth()
	return self.chars_width
end

return output
