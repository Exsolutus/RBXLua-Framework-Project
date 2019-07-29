
--||=======================================================--=======================================================||--
--||												 Framework Core													[=[-
--[[	Version Information:																						||--
--||		Version	0.4.0																							||--
--||		Date	07/15/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.4.0																							||--
--||		  [ 07/28/2019 ]																						||--
--||			Changes																								||--
--||			  -	Added builder load priority in init()															||--
--||				 ^	builders can require modules belonging to earlier-priority builders	(See Service builder)	||--
--||			Implementation																						||--
--||			  - getCallback(module, name)																		||--
--||				 ^	returns Service callback by name, used for Service self-access								||--
--||																												||--
--||		  [ 07/15/2019 ]																						||--
--||			Implementation																						||--
--||			  -	wrapGlobals()																					||--
--||				 ^	returns wrapped globals for use in module environments										||--
--||			  - getConstructor(module, name)																	||--
--||				 ^	returns DataType constructor by name, used for DataType self-construction					||--
--||																												||--
--||		  [ 07/09/2019 ]																						||--
--||			Implementation																						||--
--||			  -	init()																							||--
--||				 ^	framework initialization phase																||--
--||				 ^	loads all tagged builders																	||--
--||			  -	run()																							||--
--||				 ^	temporary implementation for testing														||--
--||			  - initBuilder(module)																				||--
--||				 ^  loads provided builder module and adds it to the registry									||--
--||				 ^	creates dedicated registry space for modules of this type									||--
--||			  - getBuilder(module)																				||--
--||				 ^	selects and returns a builder based on provided module's tags								]]--
--||																												]=]-
--||=======================================================--=======================================================||--

registry	= {												-- Framework module registry
	['builder'] = {};
}

local CollectionService	= game:GetService('CollectionService')

	-------------------------------------------------------  -------------------------------------------------------

--[[	Initialization Phase
	
--]]
function init()
	print(script.InitMsg.Value)
	print('. . . INITIALIZING')
	phase	= 'init'
	
	
	local builders = CollectionService:GetTagged('builder')	-- Load builders
	for i = 0, 9 do
		for j, builder in pairs(builders) do
			if CollectionService:HasTag(builder, 'priority '..i) then
				_G.init				= _G.init or {}
				_G.init.initBuilder	= initBuilder
				_G.init.wrapGlobals	= wrapGlobals
				require(builder)
				builders[j] = nil
			end
		end
	end
	_G.init = nil
end

--[[	Runtime Phase
	
--]]
function run()
	print('. . . RUNNING')
	phase 	= 'run'
	
	local services = CollectionService:GetTagged('service')	-- Load services
	for i, service in pairs(services) do
		if not ('ServiceTemplate' == service.Name) then
			wrappedRequire(service)
			coroutine.wrap(registry['service'][service.Name][1].Run)(registry['service'][service.Name][1])
		end
	end
end

	-------------------------------------------------------  -------------------------------------------------------

--[[	Builder Initialization
	
--]]
function initBuilder(module)
	local tag
	
	if not ('ModuleScript' == module.ClassName) then 			-- Validate
		error('Calling module must provide object reference') 
	end
	tag = string.lower(module.Name)
	
	if 'template' == tag or registry[tag] then 
		warn('Duplicate builders with derived tag "'..tag..'"')
		return function() end
	end
	
	registry[tag] = {}
	local function load(builder)
		registry.builder[tag] = builder
	end
	local function register(name, result)
		if registry[tag][name] then
			warn('Overwrites existing registry entry at ['..tag..']['..name..']')
		end
		registry[tag][name] = result
	end
	return load, register
end

--[[	Wrapped Module Require
	
--]]
function wrappedRequire(reference)
	_G.run 					= _G.run or {}
	_G.run.getBuilder 		= getBuilder
	_G.run.wrapGlobals		= wrapGlobals
	_G.run.getConstructor	= getConstructor
	_G.run.getEvent			= getEvent
	_G.run.getCallback		= getCallback
	require(reference)
	--_G.run = nil
end


--[[	Builder Accessor
	
--]]
function getBuilder(module)
	if not ('ModuleScript' == module.ClassName) then
		error('Calling module must provide self-reference') 
	end
	
	local builder
	local tags = CollectionService:GetTags(module)
	for k, v in pairs(tags) do
		builder = registry.builder[v]
		if builder then 
			return builder 
		end
	end
	
	error('Calling module has no valid tag')
end

--[[	DataType Self-Constructor Accessor
	Move into DataType builder later?
--]]
function getConstructor(module, name)
	if 'ModuleScript' ~= module.ClassName then
		error('Calling module must provide self-reference')
	end
	if not ('string' == type(name)) then
		error('Calling module must provide name string')
	end
	if CollectionService:HasTag(module, 'datatype') then
		return function(...)
			if registry['datatype'][module.Name][name] then
				return registry['datatype'][module.Name][name](...)
			else
				error('No constructor "'..name..'" found for '..module.Name)
			end
		end
	else
		error('Attempt to acquire datatype constructor on '..module.Name)
	end
end

--[[	Service Event Accessor
	Move into Service builder later?
--]]
function getEvent(module, name)
	if 'ModuleScript' ~= module.ClassName then
		error('Calling module must provide self-reference')
	end
	if not ('string' == type(name)) then
		error('Calling module must provide name string')
	end
	if CollectionService:HasTag(module, 'service') then
		return function(...)								-- event fire function
			if registry['service'][module.Name] then
				return registry['service'][module.Name][2](name, ...)
			else
				error('No callback "'..name..'" found for '..module.Name)
			end
		end
	else
		error('Attempt to acquire service callback on '..module.Name)
	end
end

--[[	Service Callback Accessor
	Move into Service builder later?
--]]
function getCallback(module, name)
	if 'ModuleScript' ~= module.ClassName then
		error('Calling module must provide self-reference')
	end
	if not ('string' == type(name)) then
		error('Calling module must provide name string')
	end
	if CollectionService:HasTag(module, 'service') then
		return function(...)								-- callback fire function
			if registry['service'][module.Name] then
				return registry['service'][module.Name][3](name, ...)
			else
				error('No callback "'..name..'" found for '..module.Name)
			end
		end
	else
		error('Attempt to acquire service callback on '..module.Name)
	end
end

--[[	Global Variable Wrapper
	
--]]
function wrapGlobals()
	--[[	Userdata Proxy Wrapper
		Wrap target userdata with proxy table
	]]--
	local function wrap(target, with)
		if type(target) == 'userdata' and type(with) == 'table' then
			local wrapper		= newproxy(true)
			local meta			= getmetatable(wrapper)
			meta.__index		= with
			meta.__tostring		= function() 
									return tostring(target) 
								end
			meta.__metatable	= 'The metatable is locked'
			setmetatable(with, {__index		= function(t, k)
									local default 	= target[k]
									local wrapfunc	= function(...) return default(default, ...) end
									return (type(default) == 'function' and wrapfunc) or default --]]
								end; })
			return wrapper
		else
			error('Unable to wrap '..target..' with '..with, 2)
		end
	end
	
	local _enum												-- Enum
	local custom_enums = {}
	do
		local stock 	= Enum:GetEnums()
		local enums		= stock
		local with 		= {}
		function with:refresh()
			enums = stock
			table.foreach(custom_enums, function(k, v) 
				with[k] = v 
				table.insert(enums, v)
			end)
			table.sort(enums, function(a, b) 
				return tostring(a) < tostring(b) 
			end)
		end
		function with:GetEnums()
			return enums
		end
		
		_enum = wrap(Enum, with)
	end
	
	local _game												-- game
	local custom_services = {}
	do
		local with = {}
		function with:GetService(s)
			local success, object	= pcall(game.GetService, game, s)
			return 	(success and object) or 
					(function()
						if s ~= nil and string.match(object, '\''..s..'\' is not a valid Service name') ~= nil then
							return custom_services[s] or error(object, 3)
						end
						error(object, 3)
					end)()
		end
		function with:FindService(s)
			local success, object	= pcall(game.FindService, game, s)
			return 	(success and object) or 
					(function()
						if s ~= nil and string.match(object, '\''..s..'\' is not a valid Service name') ~= nil then
							return custom_services[s] or error(object)
						end
						error(object)
					end)()
		end
		_game = wrap(game, with)
	end
	
	local _require											-- require
	do
		_require = function (reference)
			if 'string' == type(reference) then
					local iter 		= string.gmatch(reference, '[%w_]+')
					local prefix	= iter()
					if registry[prefix] then
						local name			= iter()
						if registry[prefix][name] then
							if 'enum' == prefix then
								custom_enums[name] = registry[prefix][name]
								_enum:refresh()
							elseif 'service' == prefix then
								custom_services[name] = registry[prefix][name][1]
							else
								return registry[prefix][name]
							end
						else
							local collection = CollectionService:GetTagged(prefix)
							for k, v in pairs(collection) do
								if 'ModuleScript' == v.ClassName and name == v.Name then
									wrappedRequire(v)
									if 'enum' == prefix then
										custom_enums[name] = registry[prefix][name]
										_enum:refresh()
									elseif 'service' == prefix then
										custom_services[name] = registry[prefix][name][1]
									else
										return registry[prefix][name]
									end
								end
							end
						end
					else
						error(prefix..' is not a supported module classification tag')
					end
			elseif 'userdata' == type(reference) then
				if not ('ModuleScript' == reference.ClassName) then
					error('Invalide module reference')
				end
				local tags = CollectionService:GetTags(reference)
				for k, v in pairs(tags) do
					if 'builder' == v then
						error('Attempt to register Builder module post-init')
					end
					if registry[v] then
						if not registry[v][reference.Name] then
							wrappedRequire(reference)
						end
						if 'enum' == v then
							custom_enums[reference.Name] = registry[v][reference.Name]
							_enum:refresh()
						elseif 'service' == v then
							custom_services[reference.Name] = registry[v][reference.Name][1]
						else
							return registry[v][reference.Name]
						end
					else
						warn('No supported module classification tag found on '..reference.Name)
						return require(reference)
					end
				end
			else
				error('Invalid module reference')
			end
		end
	end
	
	return _require, _enum, _game
end

	-------------------------------------------------------  -------------------------------------------------------
	
init()
run()

--||=======================================================--=======================================================||--
return