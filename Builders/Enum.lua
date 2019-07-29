local builder, register = _G.init.initBuilder(script)
--||=======================================================--=======================================================||--
--||												  Enum Builder													[=[-
--[[	Version Information:																						||--
--||		Version	0.1.0																							||--
--||		Date	07/10/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.1.0																							||--
--||		  [ 07/10/2019 ]																						||--
--||			Implementation																						||--
--||			  - Supplies builder function for Enum modules														]]--
--||																												]=]-
--||=======================================================--=======================================================||--

builder (function(name)
	
	return function(definition)
		local has_enumitem = false							-- Validate enum definition
		for k, v in pairs(definition) do
			if type(k) ~= 'number' or type(v) ~= 'string' then
				error('Malformed Enum definition; See EnumTemplate module for format guide')
			end
			has_enumitem = true
		end
		if not has_enumitem then
			error('Malformed Enum definition; See EnumTemplate module for format guide')
		end
		
		local function makeEnumItem(name, value, enumType)	-- EnumItem generator
			local enumItem		= newproxy(true)
			local meta			= getmetatable(enumItem)
			meta.__index		= {	Name = name;
									Value = value;
									EnumType = enumType; }
			meta.__newindex		= function(t, k, v) 
									error(k..' cannot be assigned to', 4) 
								end
			meta.__tostring		= function() 
									return 'Enum.'..enumType..'.'..name 
								end
			meta.__metatable	= 'The metatable is locked'
			return enumItem
		end
		
		local enum			= newproxy(true)				-- Generate new Enum object
		local meta			= getmetatable(enum)
		meta.__tostring		= function() 
								return name 
							end
		meta.__concat		= function(t, v) 
								return name..v 
							end
		meta.__index		= {}
		local enumitems		= {}
		table.foreach(definition, function(k, v) 			-- Generate EnumItems
			meta.__index[v] = makeEnumItem(v, k, enum)
			enumitems[k]	= meta.__index[v]
		end)
		function meta.__index:GetEnumItems()
			return {unpack(enumitems)}
		end
		meta.__metatable	= 'The metatable is locked'
		
		register(name, enum)
	end
	
end)

--||=======================================================--=======================================================||--
return true