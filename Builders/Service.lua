local require, Enum, game	= _G.init.wrapGlobals()
local builder, register		= _G.init.initBuilder(script)
--||=======================================================--=======================================================||--
--||												Service Builder													[=[-
--[[	Version Information:																						||--
--||		Version	0.1.0																							||--
--||		Date	07/28/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.1.0																							||--
--||		  [ 07/09/2019 ]																						||--
--||			change note header																					||--
--||			  - change note																						||--
--||				 ^  change note details																			]]--
--||																												]=]-
--||=======================================================--=======================================================||--

local ScriptSignal = require (script.ScriptSignal)

builder (function(name)
	return function(definition)
		
		local properties	= {}
		local functions		= {}
		local events		= {}
		local callbacks		= {}
		
		definition(properties, functions, events, callbacks)
		
		for k, v in pairs(properties) do					-- Validate service defintion
			if 'function' == type(v) then --]]
				error('Malformed Service definition; Properties cannot be functions')
			end
			if 'table' == type(v) then
				local function rec_check(t)
					for k, v in pairs(t) do
						if type(v) == 'function' then --]]
							error('Malformed DataType definition; Table-type property must not contain functions')
						elseif type(v) == 'table' then
							rec_check(v)
						end
					end
				end
				rec_check(v)
			end
		end
		local has_run = false
		for k, v in pairs(functions) do
			if not 'function' == type(v) then --]]
				error('Malformed Service definition; Functions cannot be non-function values')
			end
			if 'Run' == k then
				has_run = true
			end
		end
		if not has_run then
			error('Malformed Service definition; Must include function :Run()', 2) --]]
		end
		for k, v in pairs(events) do
			if not 'function' == type(v) then --]]
				error('Malformed Service definition; Events cannot be non-function values')
			end
		end
		for k, v in pairs(callbacks) do
			if not 'function' == type(v) then --]]
				error('Malformed Service definition; Callbacks cannot be non-function values')
			end
		end
		
		local service = {}									-- Build service object
		for k, v in pairs(properties) do
			service[k] = v
		end
		for k, v in pairs(functions) do
			service[k] = v
		end
		local keys = {}
		for k, v in pairs(events) do
			local event	= ScriptSignal.new(k)
			service[k] 	= event
			keys[k] 	= event:Prime()()
		end
		local empty = function() end
		for k, v in pairs(callbacks) do
			service[k] = empty
		end
		local proxy 	= newproxy(true)
		local meta		= getmetatable(proxy)
		meta.__index	= function(t, k)
							if callbacks[k] then
								error(k..' is a callback member of '..t..'; you can only set the callback value, get is not available')
							else
								return service[k]
							end
						end
		meta.__newindex	= function(t, k, v)
							if callbacks[k] then
								service[k] = ('function' == type(v) and v) or empty --]]
							elseif properties[k] then
								service[k] = (type(v) == type(properties[k]) and v) or properties[k]
							else
								error(k..' is not a valid member of '..name)
							end
						end
		meta.__tostring		= function() return name end
		meta.__concat		= function(a, b) return tostring(a)..tostring(b) end
		meta.__metatable	= 'The metatable is locked'
		
		local function fireEvent(name, ...)
			if events[name] then
				service[name]:Fire(keys[name], ...)
			end
		end
		
		local function fireCallback(name, ...)
			if callbacks[name] then
				service[name](...)
			end
		end
		
		register(name, {proxy, fireEvent, fireCallback})
	end
end)

--||=======================================================--=======================================================||--
return true