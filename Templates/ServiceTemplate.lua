local require, Enum, game	= _G.run.wrapGlobals()
local service 				= _G.run.getBuilder(script)
local ExampleEvent			= _G.run.getEvent(script, 'ExampleEvent')
local ExampleCallback		= _G.run.getCallback(script, 'ExampleCallback')
--||=======================================================--=======================================================||--
--||												Service Template												[=[-
--[[	Version Information:																						||--
--||		Version	<major>.<minor>.<patch>																			||--
--||		Date	07/09/2019																						||--
--||																												]]--
--[[	Constants:																									||--
--||	  -	const = 0																								||--
--||																												||--
--||	Functions:																									||--
--||	  - <nil> funct()																							||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	<major>.<minor>.<patch>																			||--
--||		  [ 07/09/2019 ]																						||--
--||			  - change note header																				||--
--||				 ^  change note																					]]--
--||																												]=]-
--||=======================================================--=======================================================||--



service 'ServiceTemplate' (function(properties, functions, events, callbacks)
	--------------------------------------------------------
	-- Properties
	
	properties.Property = 0
	
	--------------------------------------------------------
	-- Functions
	
	function functions:ExampleFunction()
		print('Example function in '..self)
	end
		
	function functions:Run()
		print('Starting '..script.Name)
	end
	
	--------------------------------------------------------
	-- Events
	
	function events.ExampleEvent() end
	
	--------------------------------------------------------
	-- Callbacks
	
	function callbacks.ExampleCallback() end
	
end)

--||=======================================================--=======================================================||--
return true