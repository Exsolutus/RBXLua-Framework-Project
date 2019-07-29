local require, Enum, game	= _G.run.wrapGlobals()
local datatype				= _G.run.getBuilder(script)
local new					= _G.run.getConstructor(script, 'new')
--||=======================================================--=======================================================||--
--||												  ScriptSignal													[=[-
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

local ScriptConnection = require (script.Parent.ScriptConnection)

datatype 'ScriptSignal' (function(constructors, properties, functions, operators)
	--------------------------------------------------------
	-- Constructors
	
	function constructors.new(name)
		return {Name = name}
	end
	
	--------------------------------------------------------
	-- Properties
	
	properties.Name = 'ScriptSignal';
	
	--------------------------------------------------------
	-- Functions
	
	function functions:Connect(func)
		if not self.Connect then 
			error('Connect is not a valid member of '..self, 2) 
		end
		
		local connection = ScriptConnection.new()
		connection:SetDisconnect(function(c)
			connected[c] = nil 
		end)
		connected[connection] = func

		return connection
	end
	
	function functions:Wait()
		if not self.Wait then 
			error('Wait is not a valid member of '..self, 2) 
		end

		local thread = coroutine.running()
		table.insert(waiting, thread)
		coroutine.yield()
	end
	
	function functions:Prime()
		local db
		return function()
			if db or not self.Prime then					-- Block access after first
				error('Prime is not a valid member of '..self, 2) 
			end
			db = true
			
			connected	= {}
			waiting		= {}
			lock		= math.random()
			return lock
		end
	end
	
	function functions:Fire(key, ...)
		if (not lock == key) or (not self.Fire) then		-- Block access without lock/key match
			error('Fire is not a valid member of '..self, 2)
		end

		for k, v in pairs(connected) do						-- Call connected functions in new threads
			coroutine.wrap(v)()
		end
		for k, v in pairs(waiting) do						-- Resume waiting threads
			coroutine.resume(v)
		end
	end
	
	--------------------------------------------------------
	-- Operators
	
	function operators:__tostring()
		return 'Signal '..self.Name
	end
	
	function operators:__concat(v)
		return tostring(self)..tostring(v)
	end
	
end)

--||=======================================================--=======================================================||--
return true