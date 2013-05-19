local handlerMap = function(event,handlers,callback)
	for i = 1,#handlers do
		local handler = handlers[i]
		callback(event,handler)
	end
end

local delHandler = function(event,handler) 
	event[handler] = nil 
end

local addHandler = function(event,handler) event[handler] = handler end

event = {events = {}}

function event.register(name,...)
	local handlers  = {...}
	local events    = event.events
	events[name]    = events[name] or {}
	handlerMap(events[name],handlers,addHandler)
end

function event.remove(name,...)
	local event    = event.events[name]
	if not event then error 'Event is empty!' end
	local handlers = {...}
	handlerMap(event,handlers,delHandler)
	if not next(event) then event.events[name] = nil end
end

function event.clear(name)
	event.events[name] = nil
end

function event.clearAll()
	event.events = {}
end

function event.trigger(name,...)
	local event = event.events[name]
	if not event then return end
	for handler in pairs(event) do
		handler(...)
	end
end