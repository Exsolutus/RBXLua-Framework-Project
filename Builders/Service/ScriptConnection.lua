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



datatype 'ScriptConnection' (function(constructors, properties, functions, operators)
	--------------------------------------------------------
	-- Constructors
	
	function constructors.new()
		return
	end
	
	--------------------------------------------------------
	-- Properties
	
	properties.Connected = true
	
	--------------------------------------------------------
	-- Functions
	
	function functions:Disconnect()
		disconnect_func(self)
		self.Connected = false
	end
	
	local db
	function functions:SetDisconnect(func)
		if db or not self.SetDisconnect then		-- Block access after first
			error('GetFire is not a valid member of '..self, 2) 
		end
		db = true
		
		disconnect_func = func
	end
	
	--------------------------------------------------------
	-- Operators
	
	function operators:__tostring()
		return 'Connection'
	end
	
	function operators:__concat(a, b)
		return tostring(a)..tostring(b)
	end
	
end)

--||=======================================================--=======================================================||--
return true