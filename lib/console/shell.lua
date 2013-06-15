local path   = (...):match('^.+[%.\\/]') or ''
local output = require(path..'output')
local input  = require(path..'input')
local display= require(path..'display')

local shell = class 'Shell'

function shell:init(input,output,display)
	self.prompt = self.prompt or '>'
	self.input  = input or self.input
	self.output = output or self.output
	self.display= display or self.display
	self._env   = setmetatable(
	{print = function(...) shell.print(self,...) end,},
	{__index = _G,__newindex = _G})

	-- setup input callback
	
	function self.input.onFlush(input,str)
		if self.onFlush then self:onFlush(str) end
	end
end

function shell:onFlush(str)
	self.output:write(self.prompt..str)
	str = str:gsub('^=','return '):gsub('^return%s+(.*)','print(%1)')
	local func,err = loadstring(str)
	if func then 
		setfenv(func,self._env)
		local ok,err = pcall(func)
		if err then self.output:write(err) end
	else 
		self.output:write(err) 
	end
end

function shell:print(...)
	local count = select('#',...)
	local list  = {...}
	for i = 1,count do
		list[i] = tostring(list[i])
	end
	local str = table.concat(list,(' '):rep(4))
	self.output:write(str)
end

function shell:keypressed(key,unicode)
	self.input:keypressed(key,unicode)
end

function shell:update(dt)
	local input,output,display = self.input,self.output,self.display
	input:update(dt)
	local w,h       = display:getSize()
	local input_str = (self.prompt or '')..table.concat(input.chars)
	
	local curr_row

	curr_row = h
	local input_rows = math.max(math.ceil(#input_str/w),1)
	while input_rows > h do
		input_str        = input_str:sub(w+1)
		local input_rows = math.max(math.ceil(#input_str/w),1)
	end
	curr_row = curr_row+1-input_rows
	
	display:clear()
	display:write(input_str,1,curr_row)
	
	output:resize(w)
	for line in output:iterate(true) do
		curr_row   = curr_row-1
		if curr_row > 0 then display:write(line,1,curr_row) end
	end
end

function shell:draw(x,y)
	self.display:draw(x,y)
end

return shell