local builder, register = _G.init.initBuilder(script)
--||=======================================================--=======================================================||--
--||												 Library Builder												[=[-
--[[	Version Information:																						||--
--||		Version	0.1.0																							||--
--||		Date	07/09/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.1.0																							||--
--||		  [ 07/09/2019 ]																						||--
--||			Implementation																						||--
--||			  - Supplies builder function for Library modules													]]--
--||																												]=]-
--||=======================================================--=======================================================||--

builder (function(name)
	
	return function(definition)
		local is_empty = true								-- Validate library definition
		for k, v in pairs(definition) do
			is_empty = false
			break
		end
		if is_empty then 
			error('Malformed Library definition; Must contain at least one constant or one function', 3) --]]
		end
		
		local library = {}									-- Build library table
		local meta		= {
			__index		= {};
			__newindex	= function(t, k, v) 
							error('Attempt to modify a readonly table', 2) 
						end;
			__metatable	= 'The metatable is locked';
		}
		setmetatable(library, meta)
		for k, v in pairs(definition) do
			meta.__index[k]	= v
		end
		
		register(name, library)
	end
	
end)

--||=======================================================--=======================================================||--
return true