local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

local queueteleport = missing("function", queue_on_teleport)
local scriptUrl = "https://raw.githubusercontent.com/gotham10/pvb/main/BEST/v4.lua"

if queueteleport then
	queueteleport([[repeat task.wait() until game:IsLoaded() pcall(function() loadstring(game:HttpGet("]] .. scriptUrl .. [["))() end)]])
end

pcall(function()
    loadstring(game:HttpGet(scriptUrl))()
end)
