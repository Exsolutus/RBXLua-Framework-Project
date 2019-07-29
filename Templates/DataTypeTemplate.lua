local datatype	= _G.run.getBuilder(script)
local new		= _G.run.getConstructor(script, 'new')
--||=======================================================--=======================================================||--
--||												DataType Template												[=[-
--[[	Version Information:																						||--
--||		Version	<major>.<minor>.<patch>																			||--
--||		Date	07/09/2019																						||--
--||																												]]--
--[[	Constructors:																								||--
--||	 -	new(property p)																							||--
--||																												||--
--||	Properties:																									||--
--||	 -	property <number>																						||--
--||																												||--
--||	Functions:																									||--
--||	 -	<DataType> :iterate()																					||--
--||																												||--
--||	Operators:																									||--
--||	 -	<string> :tostring()																					||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	<major>.<minor>.<patch>																			||--
--||		  [ 07/09/2019 ]																						||--
--||			  - change note header																				||--
--||				 ^  change note																					]]--
--||																												]=]-
--||=======================================================--=======================================================||--



datatype 'DataTypeTemplate' (function(constructors, properties, functions, operators)
	--------------------------------------------------------
	-- Constructors
	
	function constructors.new(p)
		return {Property = p}
	end
	
	--------------------------------------------------------
	-- Properties
	
	properties.Property = 0
	
	--------------------------------------------------------
	-- Functions
	
	function functions:iterator()
		return new(self.property + 1)
	end
	
	--------------------------------------------------------
	-- Operators
	
	function operators:__tostring()
		return ''..self.property
	end
	
end)

--||=======================================================--=======================================================||--
return true