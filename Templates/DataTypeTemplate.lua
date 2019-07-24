local datatype, new = _G.run.getBuilder(script), _G.run.getOwnConstructor(script)
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



datatype 'DataTypeTemplate' {
	--------------------------------------------------------
	-- Properties
	
	property = 0;
	
	--------------------------------------------------------
	-- Functions
	
	iterate = function(self)
		return new(self.property + 1)
	end
	
	--------------------------------------------------------
} (function(constructor, operator)	------------------------
	--------------------------------------------------------
	-- Constructors
	
	function constructor.new(p)
		return {property = p}
	end
	
	--------------------------------------------------------
	-- Operators
	
	function operator:__tostring()
		return ''..self.property
	end
	
end)

--||=======================================================--=======================================================||--
return true