local global_container
do
	local finder_code, global_container_obj = (function()
		local globalenv = getgenv and getgenv() or _G or shared
		local globalcontainer = globalenv.globalcontainer
		if not globalcontainer then
			globalcontainer = {}
			globalenv.globalcontainer = globalcontainer
		end
		local genvs = { _G, shared }
		if getgenv then
			table.insert(genvs, getgenv())
		end
		local calllimit = 0
		do
			local function determineCalllimit()
				calllimit = calllimit + 1
				determineCalllimit()
			end
			pcall(determineCalllimit)
		end
		local function isEmpty(dict)
			for _ in next, dict do
				return
			end
			return true
		end
		local depth, printresults, hardlimit, query, antioverflow, matchedall
		local function recurseEnv(env, envname)
			if globalcontainer == env then
				return
			end
			if antioverflow[env] then
				return
			end
			antioverflow[env] = true
			depth = depth + 1
			for name, val in next, env do
				if matchedall then
					break
				end
				local Type = type(val)
				if Type == "table" then
					if depth < hardlimit then
						recurseEnv(val, name)
					end
				elseif Type == "function" then
					name = string.lower(tostring(name))
					local matched
					for methodname, pattern in next, query do
						if pattern(name, envname) then
							globalcontainer[methodname] = val
							if not matched then
								matched = {}
							end
							table.insert(matched, methodname)
							if printresults then
								print(methodname, name)
							end
						end
					end
					if matched then
						for _, methodname in next, matched do
							query[methodname] = nil
						end
						matchedall = isEmpty(query)
						if matchedall then
							break
						end
					end
				end
			end
			depth = depth - 1
		end
		local function finder(Query, ForceSearch, CustomCallLimit, PrintResults)
			antioverflow = {}
			query = {}
			do
				local function Find(String, Pattern)
					return string.find(String, Pattern, nil, true)
				end
				for methodname, pattern in next, Query do
					if not globalcontainer[methodname] or ForceSearch then
						if not Find(pattern, "return") then
							pattern = "return " .. pattern
						end
						query[methodname] = loadstring(pattern)
					end
				end
			end
			depth = 0
			printresults = PrintResults
			hardlimit = CustomCallLimit or calllimit
			recurseEnv(genvs)
			do
				local env = getfenv()
				for methodname in next, Query do
					if not globalcontainer[methodname] then
						globalcontainer[methodname] = env[methodname]
					end
				end
			end
			hardlimit = nil
			depth = nil
			printresults = nil
			antioverflow = nil
			query = nil
		end
		return finder, globalcontainer
	end)()
	global_container = global_container_obj
	finder_code({
		getscriptbytecode = 'string.find(...,"get",nil,true) and string.find(...,"bytecode",nil,true)',
		hash = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"hash")and c(string.lower(tostring(a[2])),"crypt")'
	}, true, 10)
end

local getscriptbytecode = global_container.getscriptbytecode
local sha384
if global_container.hash then
	sha384 = function(data)
		return global_container.hash(data, "sha384")
	end
end
if not sha384 then
	pcall(function()
		local require_online = (function()
			local RequireCache = {}
			local function ARequire(ModuleScript)
				local Cached = RequireCache[ModuleScript]
				if Cached then
					return Cached
				end
				local Source = ModuleScript.Source
				local LoadedSource = loadstring(Source)
				local fenv = getfenv(LoadedSource)
				fenv.script = ModuleScript
				fenv.require = ARequire
				local Output = LoadedSource()
				RequireCache[ModuleScript] = Output
				return Output
			end
			local function ARequireController(AssetId)
				local ModuleScript = game:GetObjects("rbxassetid://" .. AssetId)[1]
				return ARequire(ModuleScript)
			end
			return ARequireController
		end)()
		if require_online then
			sha384 = require_online(4544052033).sha384
		end
	end)
end

local decompile = decompile
local setclipboard = setclipboard
local genv = getgenv()
if not genv.scriptcache then
	genv.scriptcache = {}
end
local ldeccache = genv.scriptcache

local can_write_file, writefile_func = pcall(function() return writefile end)
local can_make_folder, make_folder_func = pcall(function() return makefolder or makedir end)
local is_folder_func = isfolder or function() return false end

local game_name_success, product_info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
local game_name = (game_name_success and product_info.Name) or "UnknownGame"
game_name = game_name:gsub("[^%w_]", "")

local version = 1
while is_folder_func(string.format("Games/%s/V%d", game_name, version)) do
	version = version + 1
end
local execution_folder = string.format("Games/%s/V%d", game_name, version)

if can_write_file and can_make_folder and type(make_folder_func) == 'function' then
	pcall(make_folder_func, "Games")
	pcall(make_folder_func, string.format("Games/%s", game_name))
	pcall(make_folder_func, execution_folder)
end

local StatusGui = Instance.new("ScreenGui")
local StatusText = Instance.new("TextLabel")
local function updateStatus(text, color)
	if StatusText and StatusText.Parent then
		StatusText.Text = text
		StatusText.TextColor3 = color or Color3.new(1, 1, 1)
	end
end

local function setupStatusGui()
	StatusGui.DisplayOrder = 2e9
	pcall(function() StatusGui.OnTopOfCoreBlur = true end)
	StatusText.BackgroundTransparency = 1
	StatusText.Font = Enum.Font.Code
	StatusText.AnchorPoint = Vector2.new(1, 0)
	StatusText.Position = UDim2.new(1, -10, 0, 10)
	StatusText.Size = UDim2.new(0.5, 0, 0, 20)
	StatusText.TextColor3 = Color3.new(1, 1, 1)
	StatusText.TextSize = 16
	StatusText.TextStrokeTransparency = 0.5
	StatusText.TextXAlignment = Enum.TextXAlignment.Right
	StatusText.TextYAlignment = Enum.TextYAlignment.Top
	StatusText.Parent = StatusGui
	local function randomString()
		local length = math.random(10, 20)
		local randomarray = table.create(length)
		for i = 1, length do
			randomarray[i] = string.char(math.random(32, 126))
		end
		return table.concat(randomarray)
	end
	if global_container.gethui then
		StatusGui.Name = randomString()
		StatusGui.Parent = global_container.gethui()
	elseif global_container.protectgui then
		StatusGui.Name = randomString()
		global_container.protectgui(StatusGui)
		StatusGui.Parent = game:GetService("CoreGui")
	else
		StatusGui.Name = randomString()
		StatusGui.Parent = game:GetService("CoreGui")
	end
end

local function decompileAllScripts()
	local function construct_TimeoutHandler(timeout, func, timeout_return_value)
		return function(...)
			local args = { ... }
			if not func then
				return false, "Function is nil"
			end
			if timeout < 0 then
				return pcall(func, table.unpack(args))
			end
			local thread = coroutine.running()
			local timeoutThread, isCancelled
			timeoutThread = task.delay(timeout, function()
				isCancelled = true
				coroutine.resume(thread, nil, timeout_return_value)
			end)
			task.spawn(function()
				local success, result = pcall(func, table.unpack(args))
				if isCancelled then
					return
				end
				task.cancel(timeoutThread)
				while coroutine.status(thread) ~= "suspended" do
					task.wait()
				end
				coroutine.resume(thread, success, result)
			end)
			return coroutine.yield()
		end
	end

	function getScriptSource(scriptInstance, timeout)
		if not (decompile and getscriptbytecode and sha384) then
			return false, "Error: Required functions are missing."
		end
		local decompileTimeout = timeout or 10
		local getbytecode_h = construct_TimeoutHandler(3, getscriptbytecode)
		local decompiler_h = construct_TimeoutHandler(decompileTimeout, decompile, "-- Decompiler timed out after " .. tostring(decompileTimeout) .. " seconds.")
		local success, bytecode = getbytecode_h(scriptInstance)
		local hashed_bytecode
		local cached_source
		if success and bytecode and bytecode ~= "" then
			hashed_bytecode = sha384(bytecode)
			cached_source = ldeccache[hashed_bytecode]
		elseif success then
			return true, "-- The script is empty."
		else
			return false, "-- Failed to get bytecode."
		end
		if cached_source then
			return true, cached_source
		end
		local decompile_success, decompiled_source = decompiler_h(scriptInstance)
		local output
		if decompile_success and decompiled_source then
			output = string.gsub(decompiled_source, "\0", "\\0")
		else
			output = "--[[ Failed to decompile. Reason: " .. tostring(decompiled_source) .. " ]]"
		end
		if output:match("^%s*%-%- Decompiled with") then
			local first_newline = output:find("\n")
			if first_newline then
				output = output:sub(first_newline + 1)
			else
				output = ""
			end
			output = output:gsub("^%s*\n", "")
		end
		if hashed_bytecode then
			ldeccache[hashed_bytecode] = output
		end
		return true, output
	end

	local ALL_SCRIPTS_DATA = {}
	local SCRIPTS_TO_DECOMPILE = {}
	local SERVICES_TO_SCAN = {
		game:GetService("Workspace"),
		game:GetService("Players"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ReplicatedFirst"),
		game:GetService("StarterGui"),
		game:GetService("StarterPlayer"),
		game:GetService("Lighting"),
		game:GetService("SoundService")
	}
	local IGNORE_LIST = {
		["CoreGui"] = true,
		["CorePackages"] = true,
		["CoreScripts"] = true,
		["RobloxPluginGuiService"] = true
	}
	local discoverScripts
	discoverScripts = function(instance)
		if IGNORE_LIST[instance.Name] then
			return
		end
		local success, isScript = pcall(function() return instance:IsA("LuaSourceContainer") end)
		if success and isScript then
			table.insert(SCRIPTS_TO_DECOMPILE, instance)
		end
		local success_children, children = pcall(function() return instance:GetChildren() end)
		if success_children and children then
			for _, child in ipairs(children) do
				discoverScripts(child)
			end
		end
	end

	updateStatus("Initializing decompiler...", Color3.new(1, 1, 0))
	if not (decompile and getscriptbytecode and sha384) then
		updateStatus("Error: Missing required functions.", Color3.new(1, 0.2, 0.2))
		task.wait(5)
		StatusGui:Destroy()
		return
	end
	
	updateStatus("Scanning game for scripts...", Color3.new(0.5, 1, 0.5))
	task.wait() 
	
	for _, service in ipairs(SERVICES_TO_SCAN) do
		discoverScripts(service)
	end

	local total_scripts = #SCRIPTS_TO_DECOMPILE
	updateStatus(string.format("Found %d scripts. Starting decompile...", total_scripts), Color3.new(0.5, 1, 0.5))
	task.wait(1.5)

	if total_scripts == 0 then
		updateStatus("No scripts were found to decompile.", Color3.new(1, 1, 0))
		task.wait(5)
		return
	end

	for i, scriptInstance in ipairs(SCRIPTS_TO_DECOMPILE) do
		local path = scriptInstance:GetFullName()
		updateStatus(string.format("Decompiling (%d/%d): %s", i, total_scripts, path), Color3.new(0.9, 0.9, 0.9))
		task.wait()
		
		local source_success, source_code = getScriptSource(scriptInstance)
		if source_success then
			table.insert(ALL_SCRIPTS_DATA, { path = path, code = source_code })
		else
			table.insert(ALL_SCRIPTS_DATA, { path = path, code = "--[[ DECOMPILATION FAILED: " .. tostring(source_code) .. " ]]--" })
		end
	end
	
	updateStatus("Crawl finished. Compiling results...", Color3.new(1, 1, 0))
	task.wait(1)

	table.sort(ALL_SCRIPTS_DATA, function(a, b) return a.path < b.path end)
	local output_parts = {}
	for _, data in ipairs(ALL_SCRIPTS_DATA) do
		local formatted_entry = string.format("-- Path: %s\n--[=[\n%s\n--]=]", data.path, data.code)
		table.insert(output_parts, formatted_entry)
	end
	local final_output = table.concat(output_parts, "\n\n")
	
	if can_write_file and type(writefile_func) == "function" then
		local file_name = string.format("%s/ClientScriptDump.txt", execution_folder)
		writefile_func(file_name, final_output)
		updateStatus(string.format("SUCCESS: Scripts saved to %s", file_name), Color3.new(0.3, 1, 0.3))
	elseif setclipboard then
		setclipboard(final_output)
		updateStatus("SUCCESS: Scripts copied to clipboard.", Color3.new(0.3, 1, 0.3))
	else
		updateStatus("FAILURE: Could not save or copy.", Color3.new(1, 0.2, 0.2))
	end
end

task.spawn(function()
	setupStatusGui()
	pcall(decompileAllScripts)
	task.wait(10)
	if StatusGui and StatusGui.Parent then
		StatusGui:Destroy()
	end
end)
