local output = class 'Output'

function output:init(chars_width,max_lines)
	self.lines       = {}
	self.max_lines   = max_lines or 100
	self.chars_width = chars_width or math.huge
end

function output:resize(chars_width)
	chars_width = chars_width or self.chars_width
	if chars_width == self.chars_width then return end
	self.lines      = {}
	local str_cache = {}
	for index,line in ipairs(self.lines) do
		local nextline = self.lines[index+1]
		if nextline and nextline.wrapped or line.wrapped then
			table.insert(str_cache,line)
		else
			if next(str_cache) then
				local str = table.concat(str_cache)
				str_cache = {} 
				output.write(self,str)
			end
			output.write(self,line)
		end
	end
end

function output:write(str)
	for line in str:lines() do
		local count = 1
		repeat
			local newline = line:sub(1,self.chars_width)
			if count == 2 then newline = {str = newline,wrapped = true} end
			table.insert(self.lines,newline)
			line  = line:sub(self.chars_width+1)
			count = count + 1
		until line == ''
	end
	
	local lines = #self.lines
	while lines > self.max_lines do
		lines = lines - 1
		table.remove(self.lines,1)
	end
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

return output
