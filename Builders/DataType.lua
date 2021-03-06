local builder, register = _G.init.initBuilder(script)
--||=======================================================--=======================================================||--
--||												DataType Builder												[=[-
--[[	Version Information:																						||--
--||		Version	0.1.0																							||--
--||		Date	07/18/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.1.0																							||--
--||		  [ 07/28/2019 ]																						||--
--||			Changes																								||--
--||			  - Restructured for new module format																||--
--||																												||--
--||		  [ 07/18/2019 ]																						||--
--||			Implementation																						||--
--||			  - Supplies builder function for DataType modules													]]--
--||																												]=]-
--||=======================================================--=======================================================||--

builder (function(name)
	
	return function(definition)
		
		local constructors	= {}
		local properties	= {}
		local functions		= {}
		local operators		= {}
		
		definition(constructors, properties, functions, operators)
		
		local has_constructor = false						-- Validate datatype definition
		for k, v in pairs(constructors) do
			if type(v) ~= 'function' then --]]
				error('Malformed DataType definition; Constructors must be functions')
			end
			has_constructor = true
		end
		if not has_constructor then 
			error('Malformed DataType definition; Must provide at least one constructor') 
		end
		for k, v in pairs(properties) do
			if 'function' == type(v) then
				error('Malformed DataType definition; Properties cannot be functions')
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
		for k, v in pairs(functions) do
			if not 'function' == type(v) then
				error('Malformed DataType definition; Functions cannot be non-function values')
			end
		end
		for k, v in pairs(operators) do
			if k == '__index' then
				error('Malformed DataType definition; __index is protected')
			end
			if k == '__newindex' then
				error('Malformed DataType definition; __newindex is protected')
			end
			if k == '__metatable' then
				error('Malformed DataType definition; __metatable is protected')
			end
			if type(v) ~= 'function' then --]]
				error('Malformed DataType definition; Operators must be functions')
			end
		end
		
		local prototype = {}								-- Build prototype object
		for k, v in pairs(properties) do
			prototype[k] = v
		end
		for k, v in pairs(functions) do
			prototype[k] = v
		end
		
		local function fromPrototype(constructed)		-- DataType object factory
			local datatype	= setmetatable({}, {__index 	= prototype;
												__metatable = 'The metatable is locked';})
			for k, v in pairs(constructed) do
				if properties[k] then
					datatype[k] = v
				end
			end
			local proxy		= newproxy(true)
			local meta		= getmetatable(proxy)
			meta.__index	= datatype
			meta.__newindex	= function(t, k, v)
								error(k..' cannot be assigned to')
							end
			meta.__concat	= operators.__concat;
			meta.__unm		= operators.__unm;
			meta.__add		= operators.__add;
			meta.__sub		= operators.__sub;
			meta.__mul		= operators.__mul;
			meta.__div		= operators.__div;
			meta.__mod		= operators.__mod;
			meta.__pow		= operators.__pow;
			meta.__tostring	= operators.__tostring;
			meta.__eq		= operators.__eq;
			meta.__lt		= operators.__lt;
			meta.__le		= operators.__le;
			meta.__metatable	= 'The metatable is locked';
			
			return proxy
		end
		
		local datatype_constructors	= {}					-- Make datatype constructor table
		for k, v in pairs(constructors) do
			datatype_constructors[k] 	= function(...)
											return fromPrototype(v(...) or {})
										end
		end
		
		register(name, datatype_constructors)		
	end
	
end)

--||=======================================================--=======================================================||--
return true