_G.Config = {}
_G.Config.wl = {"DARK_ENCHANTEDD","pvbfarmeracc1","pvbfarmeracc2","pvbfarmeracc3","pvbfarmeracc4","pvbfarmeracc5","pvbfarmeracc6","pvbfarmeracc7","pvbfarmeracc8","pvbfarmeracc9","pvbfarmeracc10","pvbfarmeracc11","pvbfarmeracc12","pvbfarmeracc13","pvbfarmeracc14","pvbfarmeracc15","pvbfarmeracc16","pvbfarmeracc17","pvbfarmeracc18","pvbfarmeracc19","pvbfarmeracc20","pvbfarmeracc21","pvbfarmeracc22","pvbfarmeracc23","pvbfarmeracc24","pvbfarmeracc25","pvbfarmeracc26","pvbfarmeracc27","pvbfarmeracc28","pvbfarmeracc29","pvbfarmeracc30"}
_G.Config.SEED_MIN_PRICE = 200
_G.Config.GEAR_MIN_PRICE = 7500
_G.Config.AutoSeedBuyer = true
_G.Config.AutoGearBuyer = true
_G.Config.AutoBrainrot = false
_G.Config.AutoBrainrotWait = 60
_G.Config.AutoAcceptGifts = false
_G.Config.AntiAFK = false
_G.Config.ShowShopTimer = false
_G.Config.SafeLocation = false
_G.Config.OPlessLag = false
_G.Config.seedRegistryTable = {["Cactus Seed"] = { Plant = "Cactus", Price = 200 }, ["Strawberry Seed"] = { Plant = "Strawberry", Price = 1250 }, ["Pumpkin Seed"] = { Plant = "Pumpkin", Price = 5000 }, ["Sunflower Seed"] = { Plant = "Sunflower", Price = 25000 }, ["Dragon Fruit Seed"] = { Plant = "Dragon Fruit", Price = 100000 }, ["Eggplant Seed"] = { Plant = "Eggplant", Price = 250000 }, ["Watermelon Seed"] = { Plant = "Watermelon", Price = 1000000 }, ["Grape Seed"] = { Plant = "Grape", Price = 2500000 }, ["Cocotank Seed"] = { Plant = "Cocotank", Price = 5000000 }, ["Carnivorous Plant Seed"] = { Plant = "Carnivorous Plant", Price = 25000000 }, ["Mr Carrot Seed"] = { Plant = "Mr Carrot", Price = 50000000 }, ["Tomatrio Seed"] = { Plant = "Tomatrio", Price = 125000000 }, ["Shroombino Seed"] = { Plant = "Shroombino", Price = 200000000 }, ["Mango Seed"] = { Plant = "Mango", Price = 367000000 }, ["King Limone Seed"] = { Plant = "King Limone", Price = 670000000 }, ["Starfruit Seed"] = { Plant = "Starfruit", Price = 750000000 }}
_G.Config.gearRegistryTable = {["Water Bucket"] = { Price = 7500 }, ["Frost Grenade"] = { Price = 12500 }, ["Banana Gun"] = { Price = 25000 }, ["Frost Blower"] = { Price = 125000 }, ["Carrot Launcher"] = { Price = 500000 }}

_G.ScriptManager = _G.ScriptManager or { Connections = {}, Threads = {} }

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not _G.Config or not table.find(_G.Config.wl, LocalPlayer.Name) then return end

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
    local seedPrices = {}
    for seedName, seedInfo in pairs(_G.Config.seedRegistryTable) do
        if type(seedInfo) == "table" and seedInfo.Price then seedPrices[seedName] = tonumber(seedInfo.Price) end
    end
    local function canBuy(seedName)
        local price = seedPrices[seedName]
        return price and price >= _G.Config.SEED_MIN_PRICE
    end
    local function attemptBuy(seedName)
        local ok = pcall(function() buyRemote:FireServer(seedName) end)
        return ok
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

for _, name in ipairs({"AdminSeparator", "AdminSettingsTitle", "AutoAcceptGifts", "AutoSeedBuyer", "AutoGearBuyer", "AutoBrainrot", "AntiAFK", "ShowShopTimer", "SafeLocation", "OPlessLag", "SEED_MIN_PRICE", "GEAR_MIN_PRICE", "AutoBrainrotWait", "Whitelist", "SeedRegistry", "GearRegistry"}) do
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
        if updateFunc then updateFunc() end
    end)
end

local function createDisplay(name, contentStr, objName)
    local setting = templateSetting:Clone()
    setting.Name = objName or name:gsub("%s+", "")
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
    valueFrame.Name = "ValueDisplay"
    valueFrame.Parent = setting
    valueFrame.AnchorPoint = Vector2.new(1, 0.5)
    valueFrame.Position = UDim2.new(1, -10, 0.5, 0)
    valueFrame.Size = UDim2.new(0, 150, 0, 30)
    valueFrame.BackgroundTransparency = 1
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = valueFrame
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = contentStr
    valueLabel.TextScaled = true
end

createToggle("Auto Seed Buyer", "AutoSeedBuyer", runSeedBuyer)
createToggle("Auto Gear Buyer", "AutoGearBuyer", runGearBuyer)
createToggle("Auto Brainrot", "AutoBrainrot", runAutoBrainrot)
createToggle("Auto Accept Gifts", "AutoAcceptGifts", runAutoAcceptGifts)
createToggle("Anti-AFK", "AntiAFK", runAntiAFK)
createToggle("Show Shop Timer", "ShowShopTimer", runShopTimer)
createToggle("Safe Location", "SafeLocation", runSafeLocation)
createToggle("Less Lag (Destructive)", "OPlessLag", runOPlessLag)

createDisplay("Seed Min Price", tostring(_G.Config.SEED_MIN_PRICE), "SEED_MIN_PRICE")
createDisplay("Gear Min Price", tostring(_G.Config.GEAR_MIN_PRICE), "GEAR_MIN_PRICE")
createDisplay("Brainrot Wait", tostring(_G.Config.AutoBrainrotWait) .. "s", "AutoBrainrotWait")

createDisplay("Whitelist", table.concat(_G.Config.wl, ", "), "Whitelist")

local seedStr = ""
for k,v in pairs(_G.Config.seedRegistryTable) do seedStr = seedStr .. k .. ": $" .. v.Price .. ", " end
createDisplay("Seed Registry", seedStr:sub(1, -3), "SeedRegistry")

local gearStr = ""
for k,v in pairs(_G.Config.gearRegistryTable) do gearStr = gearStr .. k .. ": $" .. v.Price .. ", " end
createDisplay("Gear Registry", gearStr:sub(1, -3), "GearRegistry")

runSeedBuyer()
runGearBuyer()
runAutoBrainrot()
runAutoAcceptGifts()
runAntiAFK()
runShopTimer()
runSafeLocation()
runOPlessLag()
