
--||=======================================================--=======================================================||--
--||												 Framework Core													[=[-
--[[	Version Information:																						||--
--||		Version	0.4.0																							||--
--||		Date	07/15/2019																						||--
--||																												]]--
--[[	Change Log:																									||--
--||		Version	0.4.0																							||--
--||		  [ 07/15/2019 ]																						||--
--||			Implementation																						||--
--||			  -	wrapGlobals()																					||--
--||				 ^	returns wrapped globals for use in module environments										||--
--||																												||--
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
local require = require

	-------------------------------------------------------  -------------------------------------------------------

--[[	Initialization Phase
	
--]]
function init()
	print(script.InitMsg.Value)
	print('. . . INITIALIZING')
	phase	= 'init'
	
	CollectionService = game:GetService('CollectionService')
															-- Load builders
	local builders = CollectionService:GetTagged('builder')
	for i, builder in pairs(builders) do
		if 'Builder' ~= builder.Name then
			_G.init				= _G.init or {}
			_G.init.initBuilder	= initBuilder
			require(builder)
		end
	end
	_G.init = nil
	
	require = wrappedRequire
end

--[[	Runtime Phase
	
--]]
function run()
	print('. . . RUNNING')
	phase 	= 'run'
	

	require(game.ServerScriptService.DevelopmentSuite.Storage.LibraryTest)
	registry['library']['LibraryTest'].test_funct()
end

	-------------------------------------------------------  -------------------------------------------------------

--[[	Builder Initialization
	
--]]
function initBuilder(module)
	local tag
	
	if not 'ModuleScript' == module.ClassName then 			-- Validate
		error('Calling module must provide object reference') 
	end
	tag = string.lower(module.Name)
	
	if 	'template' == tag or registry[tag] then 
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
local _require = require
function wrappedRequire(reference)
	_G.run 				= _G.run or {}
	_G.run.getBuilder 	= getBuilder
	_G.run.wrapGlobals	= wrapGlobals
	_require(reference)
end


--[[	Builder Accessor
	
--]]
function getBuilder(module)
	if not 'ModuleScript' == module.ClassName then
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
	
	--	Wrap Enums object with custom enum support
	local _enum
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
	
	--[[	Registry Entry Accessor
		
	]]--
	local _require
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
							end
							return registry[prefix][name]
						else
							local collection = CollectionService:GetTagged(prefix)
							for k, v in pairs(collection) do
								if 'ModuleScript' == v.ClassName and name == v.Name then
									require(v)
									if 'enum' == prefix then
										custom_enums[v.Name] = registry[prefix][name]
										_enum:refresh()
									end
									return registry[prefix][name]
								end
							end
						end
					else
						error(prefix..' is not a supported module classification tag')
					end
			elseif 'userdata' == type(reference) then
				if not 'ModuleScript' == reference.ClassName then
					error('Invalide module reference')
				end
				local tags = CollectionService:GetTags(reference)
				for k, v in pairs(tags) do
					if 'builder' == v then
						error('Attempt to register Builder module post-init')
					end
					if registry[v] then
						if not registry[v][reference.Name] then
							require(reference)
						end
						if 'enum' == v then
							custom_enums[reference.Name] = registry[v][reference.Name]
							_enum:refresh()
						end
						return registry[v][reference.Name]
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
	
	return _require, _enum
end



	-------------------------------------------------------  -------------------------------------------------------
	
init()
run()

--||=======================================================--=======================================================||--
return
