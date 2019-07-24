local builder, register = _G.init.initBuilder(script)
--||=======================================================--=======================================================||--
--||												DataType Builder												[=[-
--[[	Version Information:																						||--
--||		Version	0.1.0																							||--
--||		Date	07/18/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.1.0																							||--
--||		  [ 07/18/2019 ]																						||--
--||			Implementation																						||--
--||			  - Supplies builder function for DataType modules													]]--
--||																												]=]-
--||=======================================================--=======================================================||--

builder (function(name)
	
	return function(definition)								-- Builder 1/2
		
		local properties	= {}
		local functions		= {}
		local constructors	= {}
		local operators		= {}
		
		for k, v in pairs(definition) do
			if type(v) == 'function' then --]]				-- Index is function definition
				functions[k] = v
			else 											-- Index is property definition
				if type(v) == 'table' then					-- Validate table-type property
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
				properties[k] = v
			end	--]]
		end
		
		return function(definition)							-- Builder 2/2
			definition(constructors, operators)
			
			local has_constructor = false					-- Validate datatype definition
			for k, v in pairs(constructors) do
				if type(v) ~= 'function' then --]]
					error('Malformed DataType definition; Constructors must be functions')
				end
				has_constructor = true
			end
			if not has_constructor then 
				error('Malformed DataType definition; Must provide at least one constructor') 
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
			
			local prototype = {}							-- Build prototype object
			for k, v in pairs(properties) do
				prototype[k] = v
			end
			for k, v in pairs(functions) do
				prototype[k] = v
			end
			
			local function buildFromPrototype(constructed)	-- DataType object factory
				local datatype	= setmetatable({}, {__index 	= prototype;
													__metatable = 'The metatable is locked';})
				for k, v in pairs(constructed) do
					if properties[k] then
						datatype[k] = v
					end
				end
				local proxy		= newproxy(true)
				local meta		= getmetatable(proxy)
				meta.__index		= datatype
				meta.__newindex		= function(t, k, v)
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
			
			local datatype_constructors	= {}				-- Make datatype constructor table
			for k, v in pairs(constructors) do
				datatype_constructors[k] 	= function(...)
												return buildFromPrototype(v(...) or {})
											end
			end
			
			register(name, datatype_constructors)
		end
		
	end
	
end)

--||=======================================================--=======================================================||--
return true