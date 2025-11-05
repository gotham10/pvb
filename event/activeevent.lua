local wl = {"User1","User2","User3"}
local p = game.Players.LocalPlayer
if not table.find(wl,p.Name) then return end

local b = p.PlayerGui.Main.AutoSell.Frame.Limited.TextButton
local rem = game.ReplicatedStorage.Remotes.AutoSell
local ws = game.Workspace

local function getGradients()
	local g = {}
	for _, v in pairs(b:GetDescendants()) do
		if v:IsA("UIGradient") then
			g[v.Name] = v
		end
	end
	return g
end

local function updateAutoSell()
	local e = ws:GetAttribute("ActiveEvents") or ""
	local g = getGradients()
	local s = g.selected and g.selected.Enabled
	local u = g.unselected and g.unselected.Enabled
	if not string.find(e, "HalloweenEvent") then
		if s then
			rem:FireServer("Limited")
		end
	else
		if u then
			rem:FireServer("Limited")
		end
	end
end

updateAutoSell()

ws.AttributeChanged:Connect(function(attr)
	if attr == "ActiveEvents" then
		updateAutoSell()
	end
end)

task.spawn(function()
	while task.wait(1) do
		updateAutoSell()
	end
end)
