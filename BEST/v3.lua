local HttpService = game:GetService("HttpService")
local FILE_NAME = "config.json"

_G.Config = nil
_G.ScriptManager = _G.ScriptManager or { Connections = {}, Threads = {} }

local function loadConfig()
	if isfile and isfile(FILE_NAME) then
		local success, result = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
		if success and result then
			_G.Config = result
		end
	end
end

local function saveConfig()
	if writefile then
		pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(_G.Config)) end)
	end
end

loadConfig()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("Main")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local function cleanup(key)
	if _G.ScriptManager.Connections[key] then
		for _, conn in ipairs(_G.ScriptManager.Connections[key]) do
			if conn.Connected then conn:Disconnect() end
		end
	end
	_G.ScriptManager.Connections[key] = {}
	if _G.ScriptManager.Threads[key] then
		task.cancel(_G.ScriptManager.Threads[key])
	end
	_G.ScriptManager.Threads[key] = nil
end

local function runSeedBuyer()
	cleanup("SeedBuyer")
	if not _G.Config.AutoSeedBuyer then return end
	local connections = {}
	_G.ScriptManager.Connections["SeedBuyer"] = connections
	local buyRemote = Remotes:WaitForChild("BuyItem", 5)
	local seedsGui = MainGui:WaitForChild("Seeds", 5)
	if not seedsGui or not buyRemote then return end
	local scrolling = seedsGui.Frame:WaitForChild("ScrollingFrame", 5)
	if not scrolling then return end
	local restockLabel = seedsGui:WaitForChild("Restock", 5)
	local function isIgnored(inst) return not inst or inst.Name == "Padding" or inst:IsA("UIPadding") or inst:IsA("UIListLayout") end
	local function findStockLabel(frame)
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then return v end
		end
		return nil
	end
	local function parseStock(text)
		if not text then return 0 end
		return tonumber(text:match("x%s*(%d+)") or text:match("(%d+)")) or 0
	end
	local function canBuy(seedName)
		local seedInfo = _G.Config.seedRegistryTable[seedName]
		return seedInfo and seedInfo.Price and seedInfo.Price >= _G.Config.SEED_MIN_PRICE
	end
	local function attemptBuy(seedName)
		return pcall(function() buyRemote:FireServer(seedName) end)
	end
	local processedFrames = {}
	local function processFrame(frame)
		if isIgnored(frame) or processedFrames[frame] then return end
		local seedName = frame.Name
		if not canBuy(seedName) then processedFrames[frame] = true return end
		local stockLabel = findStockLabel(frame)
		if not stockLabel then return end
		processedFrames[frame] = true
		local function onStockChanged()
			while _G.Config.AutoSeedBuyer do
				if parseStock(stockLabel.Text) > 0 then
					if not attemptBuy(seedName) then break end
				else
					break
				end
				task.wait()
			end
		end
		table.insert(connections, stockLabel:GetPropertyChangedSignal("Text"):Connect(onStockChanged))
		task.spawn(onStockChanged)
	end
	local function scanAll()
		for _, child in ipairs(scrolling:GetChildren()) do if not isIgnored(child) then processFrame(child) end end
	end
	table.insert(connections, scrolling.ChildAdded:Connect(function(child)
		if _G.Config.AutoSeedBuyer and not isIgnored(child) then processFrame(child) end
	end))
	if restockLabel then
		local function parseTime(t)
			if not t then return 0 end
			local mm, ss = t:match("(%d+):(%d+)")
			return (mm and ss and (tonumber(mm) * 60 + tonumber(ss))) or tonumber(t:match("(%d+)")) or 0
		end
		local lastSeconds = parseTime(restockLabel.Text)
		table.insert(connections, restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
			if not _G.Config.AutoSeedBuyer then return end
			local s = parseTime(restockLabel.Text)
			if s > lastSeconds then task.wait(0.5) scanAll() end
			lastSeconds = s
		end))
	end
	task.wait(1)
	scanAll()
end

local function runGearBuyer()
	cleanup("GearBuyer")
	if not _G.Config.AutoGearBuyer then return end
	local connections = {}
	_G.ScriptManager.Connections["GearBuyer"] = connections
	local buyRemote = Remotes:FindFirstChild("BuyGear")
	local gearsGui = MainGui:FindFirstChild("Gears")
	if not gearsGui or not buyRemote then return end
	local scrolling = gearsGui:FindFirstChild("Frame") and gearsGui.Frame:FindFirstChild("ScrollingFrame")
	if not scrolling then return end
	local restockLabel = gearsGui:FindFirstChild("Restock") or gearsGui.Frame:FindFirstChild("Restock")
	local function isIgnored(i) return not i or i.Name == "Padding" or i:IsA("UIPadding") or i:IsA("UIListLayout") end
	local function findStockLabel(frame)
		if not frame then return nil end
		local direct = frame:FindFirstChild("Stock") or frame:FindFirstChild("StockValue")
		if direct and direct:IsA("TextLabel") then return direct end
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then return v end
		end
		return nil
	end
	local function parseStock(text) return text and (tonumber(text:match("x%s*(%d+)") or text:match("(%d+)")) or 0) or 0 end
	local function canBuy(gearName)
		if not gearName or gearName == "" then return false end
		local gearInfo = _G.Config.gearRegistryTable[gearName]
		return gearInfo and gearInfo.Price and gearInfo.Price >= _G.Config.GEAR_MIN_PRICE
	end
	local function attemptBuy(gearName)
		if pcall(function() buyRemote:FireServer(gearName) end) then return true end
		task.wait(0.15)
		if pcall(function() buyRemote:FireServer({ Name = gearName }) end) then return true end
		task.wait(0.15)
		return pcall(function() buyRemote:FireServer({ ID = gearName }) end)
	end
	local processedFrames = {}
	local function processFrame(frame)
		if isIgnored(frame) or processedFrames[frame] then return end
		local gearName = frame.Name
		if not canBuy(gearName) then processedFrames[frame] = true return end
		local stockLabel = findStockLabel(frame)
		if not stockLabel then return end
		processedFrames[frame] = true
		local function onStockChanged()
			while _G.Config.AutoGearBuyer do
				if parseStock(stockLabel.Text) > 0 then
					if not attemptBuy(gearName) then break end
				else
					break
				end
				task.wait()
			end
		end
		table.insert(connections, stockLabel:GetPropertyChangedSignal("Text"):Connect(onStockChanged))
		task.spawn(onStockChanged)
	end
	local function scanAll()
		for _, child in ipairs(scrolling:GetChildren()) do if not isIgnored(child) then processFrame(child) end end
	end
	table.insert(connections, scrolling.ChildAdded:Connect(function(child)
		if _G.Config.AutoGearBuyer and not isIgnored(child) then processFrame(child) end
	end))
	if restockLabel then
		local function parseTime(t)
			if not t then return 0 end
			local mm, ss = t:match("(%d+):(%d+)")
			return (mm and ss and (tonumber(mm) * 60 + tonumber(ss))) or tonumber(t:match("(%d+)")) or 0
		end
		local lastSeconds = parseTime(restockLabel.Text)
		table.insert(connections, restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
			if not _G.Config.AutoGearBuyer then return end
			local s = parseTime(restockLabel.Text)
			if s > lastSeconds then task.wait(0.5) scanAll() end
			lastSeconds = s
		end))
	end
	scanAll()
end

local function runAutoBrainrot()
	cleanup("AutoBrainrot")
	if not _G.Config.AutoBrainrot then return end
	local equipRemote = Remotes:FindFirstChild("EquipBestBrainrots") or Remotes:FindFirstChild("EquipBest")
	_G.ScriptManager.Threads["AutoBrainrot"] = task.spawn(function()
		while _G.Config.AutoBrainrot do
			pcall(function()
				local playerPlot
				for _, plot in ipairs(Workspace.Plots:GetChildren()) do
					if plot:GetAttribute("Owner") == LocalPlayer.Name then playerPlot = plot break end
				end
				if playerPlot then
					if equipRemote then equipRemote:FireServer() end
					task.wait(1)
					if playerPlot:FindFirstChild("Brainrots") then
						for _, brainrot in ipairs(playerPlot.Brainrots:GetChildren()) do
							if brainrot:FindFirstChild("Hitbox") and brainrot.Hitbox:FindFirstChild("ProximityPrompt") then
								local prompt = brainrot.Hitbox.ProximityPrompt
								if prompt.Enabled then prompt:InputHoldBegin() prompt:InputHoldEnd() end
							end
						end
					end
				end
			end)
			task.wait(_G.Config.AutoBrainrotWait or 60)
		end
	end)
end

local function runAutoAcceptGifts()
	cleanup("AutoAcceptGifts")
	if not _G.Config.AutoAcceptGifts then return end
	local acceptGiftRemote = Remotes:WaitForChild("AcceptGift")
	local giftItemRemote = Remotes:WaitForChild("GiftItem")
	table.insert(_G.ScriptManager.Connections["AutoAcceptGifts"], giftItemRemote.OnClientEvent:Connect(function(giftPayload)
		if _G.Config.AutoAcceptGifts and type(giftPayload) == "table" and giftPayload.ID then
			acceptGiftRemote:FireServer({ ID = giftPayload.ID })
		end
	end))
end

local function runAntiAFK()
	cleanup("AntiAFK")
	if not _G.Config.AntiAFK then return end
	table.insert(_G.ScriptManager.Connections["AntiAFK"], LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end))
end

local function runShopTimer()
	pcall(function() if PlayerGui:FindFirstChild("ShopRestockUI") then PlayerGui.ShopRestockUI:Destroy() end end)
	cleanup("ShopTimer")
	if not _G.Config.ShowShopTimer then return end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopRestockUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = PlayerGui
	local label = Instance.new("TextLabel")
	label.Parent = screenGui
	label.AnchorPoint = Vector2.new(0, 1)
	label.Position = UDim2.new(0.0015, 0, 1.005, -5)
	label.Size = UDim2.new(0.1, 0, 0.03, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Bottom
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = screenGui
	uiScale.Scale = 0.8
	table.insert(_G.ScriptManager.Connections["ShopTimer"], RunService.RenderStepped:Connect(function()
		uiScale.Scale = Workspace.CurrentCamera.ViewportSize.Y < 700 and 0.7 or 0.8
	end))
	_G.ScriptManager.Threads["ShopTimer"] = task.spawn(function()
		while _G.Config.ShowShopTimer do
			pcall(function()
				local restockTime = Workspace:GetAttribute("NextSeedRestock")
				if type(restockTime) == "number" and restockTime > 0 then
					label.Text = string.format("Shop Restocks in: %d:%02d", math.floor(restockTime / 60), restockTime % 60)
				else
					label.Text = "Shop Restocks in: --:--"
				end
			end)
			task.wait(1)
		end
	end)
end

local function runSafeLocation()
	cleanup("SafeLocation")
	local targetPosition = Vector3.new(-197, 13, 1055)
	if _G.Config.SafeLocation then
		 table.insert(_G.ScriptManager.Connections["SafeLocation"], RunService.Heartbeat:Connect(function()
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - targetPosition).Magnitude > 10 then hrp.CFrame = CFrame.new(targetPosition) end
		end))
	end
end

local function runOPlessLag()
	cleanup("OPlessLag")
	if not _G.Config.OPlessLag then return end
	local function safeDestroy(inst) pcall(function() if inst and inst.Parent and not inst:IsA("Terrain") then inst:Destroy() end end) end
	_G.ScriptManager.Threads["OPlessLag"] = task.spawn(function()
		while _G.Config.OPlessLag do
			local myPlotName
			if Workspace:FindFirstChild("Plots") then
				for _, f in ipairs(Workspace.Plots:GetChildren()) do
					if f:GetAttribute("Owner") == LocalPlayer.Name then myPlotName = f.Name else safeDestroy(f) end
				end
			end
			if Workspace:FindFirstChild("Map") then
				for _, v in ipairs(Workspace.Map:GetChildren()) do
					if not table.find({"IslandPortal", "Barriers", "CentralIsland"}, v.Name) then safeDestroy(v) end
				end
				 if Workspace.Map:FindFirstChild("CentralIsland") then
					for _, inst in ipairs(Workspace.Map.CentralIsland:GetDescendants()) do if inst:IsA("Model") or inst:IsA("MeshPart") then safeDestroy(inst) end end
				end
			end
			 for _, v in ipairs(Workspace:GetChildren()) do
				if (v:IsA("Model") or v:IsA("BasePart") or v:IsA("MeshPart")) and not table.find({"Map", "Plots", "Players", "ScriptedMap"}, v.Name) then safeDestroy(v) end
			end
			if Workspace:FindFirstChild("Players") then
				for _, m in ipairs(Workspace.Players:GetChildren()) do if m.Name ~= LocalPlayer.Name then safeDestroy(m) end end
			end
			if Workspace:FindFirstChild("ScriptedMap") then
				local sm = Workspace.ScriptedMap
				for _, v in ipairs(sm:GetChildren()) do if table.find({"BrainrotCollisions","Brainrots","BuildingStores","Countdowns","NPCs","Placing","Secrets","Leaderboards"}, v.Name) then safeDestroy(v) end end
				if sm:FindFirstChild("MissionBrainrots") and myPlotName then
					for _, m in ipairs(sm.MissionBrainrots:GetChildren()) do if tostring(m:GetAttribute("Plot")) ~= tostring(myPlotName) then safeDestroy(m) end end
				end
			end
			task.wait(1)
		end
	end)
end

local SettingsFrame = MainGui:WaitForChild("Settings"):WaitForChild("Frame")
local ScrollingFrame = SettingsFrame:WaitForChild("ScrollingFrame")
local templateSetting = ScrollingFrame:WaitForChild("SFX")
local fpsCounterSetting = ScrollingFrame:WaitForChild("FPSCounter")
if not templateSetting or not fpsCounterSetting then return end

for _, name in ipairs({"AdminSeparator", "AdminSettingsTitle", "AutoAcceptGifts", "AutoSeedBuyer", "AutoGearBuyer", "AutoBrainrot", "AntiAFK", "ShowShopTimer", "SafeLocation", "OPlessLag", "SEED_MIN_PRICE", "GEAR_MIN_PRICE", "AutoBrainrotWait", "Whitelist", "SeedRegistry", "GearRegistry", "WhitelistEditor", "SeedRegistryEditor", "GearRegistryEditor"}) do
	local old = ScrollingFrame:FindFirstChild(name)
	if old then old:Destroy() end
end

local baseLayout = fpsCounterSetting.LayoutOrder + 1
local separator = Instance.new("Frame")
separator.Name = "AdminSeparator"
separator.Parent = ScrollingFrame
separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator.BackgroundTransparency = 0.6
separator.BorderSizePixel = 0
separator.Size = UDim2.new(1, -40, 0, 3)
separator.LayoutOrder = baseLayout
Instance.new("UICorner", separator).CornerRadius = UDim.new(1, 0)

local adminTitle = Instance.new("TextLabel")
adminTitle.Name = "AdminSettingsTitle"
adminTitle.Parent = ScrollingFrame
adminTitle.Text = "Admin Settings"
adminTitle.BackgroundTransparency = 1
adminTitle.Size = UDim2.new(1, -40, 0, 40)
adminTitle.Font = Enum.Font.GothamBold
adminTitle.TextSize = 28
adminTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
adminTitle.LayoutOrder = baseLayout + 1
local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(0, 0, 0)
outline.Thickness = 1
outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
outline.Parent = adminTitle

local currentLayout = baseLayout + 2
local function createToggle(name, configKey, updateFunc)
	local setting = templateSetting:Clone()
	setting.Name = configKey
	setting.LayoutOrder = currentLayout
	currentLayout = currentLayout + 1
	setting.Parent = ScrollingFrame
	local title = setting:FindFirstChild("Title") or setting:FindFirstChildWhichIsA("TextLabel")
	if title then title.Text = name end
	local desc = setting:FindFirstChild("Username")
	if desc then desc.Text = "Toggle " .. name end
	local btnFrame = setting:WaitForChild("Button")
	local onInd = btnFrame:WaitForChild("on")
	local offInd = btnFrame:WaitForChild("off")
	local status = btnFrame:WaitForChild("DisplayName")
	local clickBtn = btnFrame:WaitForChild("TextButton")
	local function updateVis()
		onInd.Enabled = _G.Config[configKey]
		offInd.Enabled = not _G.Config[configKey]
		status.Text = _G.Config[configKey] and "On" or "Off"
	end
	updateVis()
	clickBtn.MouseButton1Click:Connect(function()
		_G.Config[configKey] = not _G.Config[configKey]
		updateVis()
		saveConfig()
		if updateFunc then updateFunc() end
	end)
end

local function createInput(name, configKey, inputType)
	local setting = templateSetting:Clone()
	setting.Name = configKey
	setting.LayoutOrder = currentLayout
	currentLayout = currentLayout + 1
	setting.Parent = ScrollingFrame
	local title = setting:FindFirstChild("Title") or setting:FindFirstChildWhichIsA("TextLabel")
	if title then title.Text = name end
	local desc = setting:FindFirstChild("Username")
	if desc then desc:Destroy() end
	local oldBtn = setting:FindFirstChild("Button")
	if oldBtn then oldBtn:Destroy() end
	local valueFrame = Instance.new("Frame")
	valueFrame.Name = "ValueInput"
	valueFrame.Parent = setting
	valueFrame.AnchorPoint = Vector2.new(1, 0.5)
	valueFrame.Position = UDim2.new(1, -10, 0.5, 0)
	valueFrame.Size = UDim2.new(0, 150, 0, 30)
	valueFrame.BackgroundTransparency = 1
	local valueBox = Instance.new("TextBox")
	valueBox.Parent = valueFrame
	valueBox.Size = UDim2.new(1, 0, 1, 0)
	valueBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	valueBox.BackgroundTransparency = 0.5
	valueBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	valueBox.Font = Enum.Font.Gotham
	valueBox.TextSize = 14
	valueBox.TextXAlignment = Enum.TextXAlignment.Right
	valueBox.Text = tostring(_G.Config[configKey])
	valueBox.ClearTextOnFocus = false
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = valueBox
	valueBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local newValue = inputType == "number" and tonumber(valueBox.Text) or valueBox.Text
			if newValue ~= nil then
				_G.Config[configKey] = newValue
				saveConfig()
				if configKey == "AutoBrainrotWait" then runAutoBrainrot() end
			end
		end
		valueBox.Text = tostring(_G.Config[configKey])
	end)
end

local function createDropdownEditor(name, configKey, isRegistry, registryKey)
	local container = Instance.new("Frame")
	container.Name = name:gsub("%s+", "") .. "Editor"
	container.BackgroundTransparency = 0.5
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, -20, 0, 50)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.LayoutOrder = currentLayout
	currentLayout = currentLayout + 1
	container.Parent = ScrollingFrame
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(108, 108, 108)
	stroke.Thickness = 2
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = container
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = container
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = container
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = name
	titleLabel.Size = UDim2.new(1, 0, 0, 20)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 0
	titleLabel.Parent = container
	if not isRegistry then
		local addFrame = Instance.new("Frame")
		addFrame.Size = UDim2.new(1, 0, 0, 30)
		addFrame.BackgroundTransparency = 1
		addFrame.LayoutOrder = 1
		addFrame.Parent = container
		local addBox = Instance.new("TextBox")
		addBox.Size = UDim2.new(0.7, -5, 1, 0)
		addBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		addBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		addBox.PlaceholderText = "Add User..."
		addBox.Text = ""
		addBox.Font = Enum.Font.Gotham
		addBox.TextSize = 14
		addBox.Parent = addFrame
		Instance.new("UICorner", addBox).CornerRadius = UDim.new(0, 6)
		local addBtn = Instance.new("TextButton")
		addBtn.Size = UDim2.new(0.3, -5, 1, 0)
		addBtn.Position = UDim2.new(0.7, 5, 0, 0)
		addBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		addBtn.Text = "Add"
		addBtn.Font = Enum.Font.GothamBold
		addBtn.TextSize = 14
		addBtn.Parent = addFrame
		Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 6)
	end
	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
	dropdownFrame.BackgroundTransparency = 1
	dropdownFrame.LayoutOrder = 2
	dropdownFrame.Parent = container
	local dropBtn = Instance.new("TextButton")
	dropBtn.Size = UDim2.new(1, 0, 1, 0)
	dropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	dropBtn.Text = "Select Item..."
	dropBtn.Font = Enum.Font.Gotham
	dropBtn.TextSize = 14
	dropBtn.Parent = dropdownFrame
	Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
	local optionsFrame = Instance.new("ScrollingFrame")
	optionsFrame.Size = UDim2.new(1, 0, 0, 150)
	optionsFrame.Visible = false
	optionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	optionsFrame.BorderSizePixel = 0
	optionsFrame.LayoutOrder = 3
	optionsFrame.ScrollBarThickness = 4
	optionsFrame.Parent = container
	local optionsLayout = Instance.new("UIListLayout")
	optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optionsLayout.Padding = UDim.new(0, 2)
	optionsLayout.Parent = optionsFrame
	local editFrame = Instance.new("Frame")
	editFrame.Size = UDim2.new(1, 0, 0, 30)
	editFrame.BackgroundTransparency = 1
	editFrame.LayoutOrder = 4
	editFrame.Visible = false
	editFrame.Parent = container
	local editBox, actionBtn
	if isRegistry then
		editBox = Instance.new("TextBox")
		editBox.Size = UDim2.new(0.6, 0, 1, 0)
		editBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		editBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		editBox.Font = Enum.Font.Gotham
		editBox.TextSize = 14
		editBox.Parent = editFrame
		Instance.new("UICorner", editBox).CornerRadius = UDim.new(0, 6)
		local saveBtn = Instance.new("TextButton")
		saveBtn.Size = UDim2.new(0.35, 0, 1, 0)
		saveBtn.Position = UDim2.new(0.65, 0, 0, 0)
		saveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		saveBtn.Text = "Save Price"
		saveBtn.Font = Enum.Font.GothamBold
		saveBtn.TextSize = 14
		saveBtn.Parent = editFrame
		Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
		actionBtn = saveBtn
	else
		local removeBtn = Instance.new("TextButton")
		removeBtn.Size = UDim2.new(1, 0, 1, 0)
		removeBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
		removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		removeBtn.Text = "Remove Selected User"
		removeBtn.Font = Enum.Font.GothamBold
		removeBtn.TextSize = 14
		removeBtn.Parent = editFrame
		Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 6)
		actionBtn = removeBtn
	end
	local selectedItem = nil
	local function refreshOptions()
		for _, v in ipairs(optionsFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		local items = {}
		if isRegistry then
			for k, _ in pairs(_G.Config[configKey]) do table.insert(items, k) end
		else
			items = _G.Config[configKey]
		end
		table.sort(items)
		for i, item in ipairs(items) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, -10, 0, 25)
			optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			optBtn.Text = item
			optBtn.Font = Enum.Font.Gotham
			optBtn.TextSize = 14
			optBtn.LayoutOrder = i
			optBtn.Parent = optionsFrame
			Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
			optBtn.MouseButton1Click:Connect(function()
				selectedItem = item
				dropBtn.Text = item
				optionsFrame.Visible = false
				editFrame.Visible = true
				if isRegistry then
					editBox.Text = tostring(_G.Config[configKey][item][registryKey])
				end
			end)
		end
		optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 27)
	end
	dropBtn.MouseButton1Click:Connect(function()
		optionsFrame.Visible = not optionsFrame.Visible
		if optionsFrame.Visible then refreshOptions() end
	end)
	if isRegistry then
		actionBtn.MouseButton1Click:Connect(function()
			if selectedItem and tonumber(editBox.Text) then
				_G.Config[configKey][selectedItem][registryKey] = tonumber(editBox.Text)
				saveConfig()
				if configKey == "seedRegistryTable" then runSeedBuyer() else runGearBuyer() end
				editFrame.Visible = false
				dropBtn.Text = "Select Item..."
				selectedItem = nil
			end
		end)
	else
		local addBtn = container:FindFirstChild("Frame") and container.Frame:FindFirstChild("TextButton")
		local addBox = container:FindFirstChild("Frame") and container.Frame:FindFirstChild("TextBox")
		if addBtn and addBox then
			 addBtn.MouseButton1Click:Connect(function()
				if addBox.Text ~= "" and not table.find(_G.Config[configKey], addBox.Text) then
					table.insert(_G.Config[configKey], addBox.Text)
					saveConfig()
					addBox.Text = ""
					if optionsFrame.Visible then refreshOptions() end
				end
			end)
		end
		actionBtn.MouseButton1Click:Connect(function()
			if selectedItem then
				local idx = table.find(_G.Config[configKey], selectedItem)
				if idx then
					table.remove(_G.Config[configKey], idx)
					saveConfig()
					editFrame.Visible = false
					dropBtn.Text = "Select Item..."
					selectedItem = nil
					if optionsFrame.Visible then refreshOptions() end
				end
			end
		end)
	end
end

createToggle("Auto Seed Buyer", "AutoSeedBuyer", runSeedBuyer)
createToggle("Auto Gear Buyer", "AutoGearBuyer", runGearBuyer)
createToggle("Auto Brainrot", "AutoBrainrot", runAutoBrainrot)
createToggle("Auto Accept Gifts", "AutoAcceptGifts", runAutoAcceptGifts)
createToggle("Anti-AFK", "AntiAFK", runAntiAFK)
createToggle("Show Shop Timer", "ShowShopTimer", runShopTimer)
createToggle("Safe Location", "SafeLocation", runSafeLocation)
createToggle("Less Lag (Destructive)", "OPlessLag", runOPlessLag)

createInput("Seed Min Price", "SEED_MIN_PRICE", "number")
createInput("Gear Min Price", "GEAR_MIN_PRICE", "number")
createInput("Brainrot Wait (s)", "AutoBrainrotWait", "number")

createDropdownEditor("Whitelist", "wl", false)
createDropdownEditor("Seed Registry", "seedRegistryTable", true, "Price")
createDropdownEditor("Gear Registry", "gearRegistryTable", true, "Price")

if not _G.Config or not table.find(_G.Config.wl, LocalPlayer.Name) then
	if MainGui then MainGui:Destroy() end
	return
end

runSeedBuyer()
runGearBuyer()
runAutoBrainrot()
runAutoAcceptGifts()
runAntiAFK()
runShopTimer()
runSafeLocation()
runOPlessLag()
