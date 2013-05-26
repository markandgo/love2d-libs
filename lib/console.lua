local path     = (...):match('^.+[%.\\/]') or ''
local fontpath = path:gsub('%.','/')..'/assets/DejaVuSansMono.ttf'
local monoFont = love.graphics.newFont(fontpath,12)

local console = class 'console'

function console:init(chars_width,chars_height, history_size, color,font)
	local t = self
	t.history_size= history_size or 100
	t.history     = {}
	t.color       = color or {255,255,255}
	t.font        = font or monoFont
	t.chars_height= chars_height or 25
	t.chars_width = chars_width or 80
	t.row_start   = nil
end

function console.setWindow(row_start,)

end


function console.print(console,...)
	local history_size= console.history_size
	local history     = console.history
	local chars_width = console.chars_width

	local messages = {...}
	for i,msg in ipairs(messages) do
		messages[i] = tostring(msg)
	end
	
	local str = table.concat(messages,'   ')
	
	for row in str:lines() do
		while #row > chars_width do
			table.insert(history,row:sub(1,chars_width))
			row = row:sub(chars_width+1)
		end
		table.insert(history,row)
	end
	
	while #history > history_size do table.remove(history,1) end
end

function console.clear(console)
	console.history = {}
end

function console.draw(console,x,y)
	x,y = x or 0,y or 0
	
	local r,g,b,a     = love.graphics.getColor()
	local oldFont     = love.graphics.getFont()
	local fontHeight  = console.font:getHeight()
	local history     = console.history
	local chars_height= console.chars_height
	local row_start   = console.row_start or math.max(#history-chars_height+1,1)
	
	love.graphics.setFont(console.font)
	love.graphics.setColor(unpack(console.color))
	
	local rowcount = 0
	for i = row_start,row_start+chars_height-1 do
		local row = history[i]
		if not row then break end
		love.graphics.print(row,x,y+rowcount*fontHeight)
		rowcount  = rowcount+1
	end
end

return console