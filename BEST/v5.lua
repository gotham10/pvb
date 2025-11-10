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

local function createScannerModuleUI(parent, baseLayoutOrder)
    local Config = _G.Config.ScannerConfig
    if not Config then return baseLayoutOrder end

    local NotSameServersFile = Config.NotSameServersFile
    local AutoHopFile = Config.AutoHopFile
    local HIDE_MY_DATA = Config.HIDE_MY_DATA
    local MAX_KG_THRESHOLD_PLANT = Config.MAX_KG_THRESHOLD_PLANT
    local MAX_KG_THRESHOLD_BRAINROT = Config.MAX_KG_THRESHOLD_BRAINROT
    local ScanPlants = Config.ScanPlants
    local ScanBrainrots = Config.ScanBrainrots
    local ScanMutations = Config.ScanMutations
    local blocked = Config.blocked
    local Mutations = Config.Mutations
    
    local Plrs = game:GetService("Players")
    local Ws = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    
    local MY_USERNAME = Plrs.LocalPlayer.Name
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    
    local isAutoHopping = false
    local scanThread = nil
    local currentFrames = {}
    local highlightedPlayers = {}
    
    local function RobustReadFile(file)
        local content = ""
        local success = false
        for i = 1, 10 do
            wait(0.5)
            success, content = pcall(function() return readfile(file) end)
            if success and content and content ~= "" then
                return content
            end
        end
        return nil
    end
    
    local function RobustWriteFile(file, content)
        for i = 1, 7 do
            local success, err = pcall(function() writefile(file, content) end)
            if success then
                return true
            end
            wait(0.5)
        end
        return false
    end
    
    local hopStateContent = RobustReadFile(AutoHopFile)
    if hopStateContent == "true" then
        isAutoHopping = true
    end
    
    local serversFileContent = RobustReadFile(NotSameServersFile)
    if serversFileContent then
        local decoded, err = pcall(function() return HttpService:JSONDecode(serversFileContent) end)
        if decoded and type(decoded) == "table" and #decoded > 0 then
            if tonumber(decoded[1]) == tonumber(actualHour) then
                AllIDs = decoded
            else
                AllIDs = { actualHour }
            end
        else
            AllIDs = { actualHour }
        end
    else
        AllIDs = { actualHour }
    end
    
    local function TPReturner()
        local Site
        local success, result = pcall(function()
            local url
            if foundAnything == "" then
                url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true'
            else
                url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true&cursor=' .. foundAnything
            end
            local raw = game:HttpGet(url)
            return HttpService:JSONDecode(raw)
        end)
    
        if not success or not result then
            return
        end
    
        Site = result
        
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        
        if not Site.data then
            return
        end
    
        for i,v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if (tonumber(v.maxPlayers) or 0) > (tonumber(v.playing) or 0) then
                for j = 2, #AllIDs do
                    if ID == tostring(AllIDs[j]) then
                        Possible = false
                        break
                    end
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    wait()
                    pcall(function()
                        RobustWriteFile(NotSameServersFile, HttpService:JSONEncode(AllIDs))
                        wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    wait(4)
                end
            end
        end
    end
    
    local function HopServer()
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
    
    local function CheckForAutoHop(scrollingFrame, noDataLabel)
        if not scrollingFrame or not noDataLabel then return end
        local itemsVisible = false
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child:IsA("Frame") and child.Visible and child.Name ~= "ItemTemplate" then
                itemsVisible = true
                break
            end
        end
        noDataLabel.Visible = not itemsVisible
        
        if not itemsVisible and isAutoHopping then
            HopServer()
        end
    end
    
    local mutationLookup = {}
    for _,m in ipairs(Mutations) do mutationLookup[m:lower()] = m end
    local romanPattern = "%s+(IX|IV|V|V?I{1,3})$"
    
    local function cleanName(name)
        if not name or name == "Unknown" then return "Unknown" end
        local cleaned = name
        cleaned = cleaned:gsub("%[.-%]%s*", "")
        cleaned = cleaned:gsub(romanPattern, "")
        cleaned = cleaned:match("^%s*(.-)%s*$")
        return cleaned
    end
    
    local function shouldSkip(name)
        if not name then return true end
        local lower = name:lower()
        for _,word in ipairs(blocked) do
            if lower:find(word, 1, true) then
                return true
            end
        end
        return false
    end
    
    local function findMutation(s)
        if not s or s == "Unknown" then return nil end
        local firstWord = tostring(s):match("^([^%s]+)")
        return firstWord and mutationLookup[firstWord:lower()]
    end
    
    local function parseSizeToKg(sizeString)
        if not sizeString or type(sizeString) ~= "string" then
            return 0
        end
        local numStr = sizeString:match("^(%d+%.?%d*)%s*kg$")
        if numStr then
            return tonumber(numStr) or 0
        end
        return 0
    end
    
    local function parseTool(tool)
        if not tool or shouldSkip(tool.Name) then return nil end
        local isPlant = tool:GetAttribute("IsPlant")
        if isPlant then
            local data = {}
            data.Type = "Plant"
            data.Name = cleanName(tool:GetAttribute("ItemName") or tool.Name)
            data.Size = (tool:GetAttribute("Size") or "Unknown") .. " kg"
            data.Value = tool:GetAttribute("Value") or "Unknown"
            data.Colors = tool:GetAttribute("Colors") or "Unknown"
            data.Damage = tool:GetAttribute("Damage") or "Unknown"
            
            local mutationString = tool:GetAttribute("MutationString")
            local mut = findMutation(mutationString)
                            or findMutation(tool:GetAttribute("Mutation"))
                            or findMutation(tool.Name:match("%[([^%]]-)%]"))
                            or "Normal"
            data.Mutation = mut
            
            return data
        end
        local rawName = tool.Name
        local data = {}
        data.Type = "Brainrot"
        data.Size = (tool:GetAttribute("Size") or "Unknown") .. " kg"
        data.Name = cleanName(rawName)
        local mutationString = tool:GetAttribute("MutationString")
        local mut
        if mutationString and mutationString == data.Name then
            mut = "Normal"
        else
            mut = findMutation(mutationString)
                or findMutation(tool:GetAttribute("Mutation"))
                or findMutation(rawName:match("%[([^%]]-)%]"))
                or "Normal"
        end
        data.Mutation = mut
        local model = tool:FindFirstChildOfClass("Model")
        if model then
            data.Rarity = model:GetAttribute("Rarity") or "Unknown"
        else
            data.Rarity = "Unknown"
        end
        return data
    end
    
    local function scanPlayer(player)
        local items = {}
        if not player then return items end
        local function scan(parent)
            if not parent then return end
            for _,tool in ipairs(parent:GetChildren()) do
                if tool:IsA("Tool") then
                    local d = parseTool(tool)
                    if d then table.insert(items, d) end
                end
            end
        end
        scan(player:FindFirstChild("Backpack"))
        if player.Character then
            for _, child in ipairs(player.Character:GetChildren()) do
                if child:IsA("Tool") then
                    local d = parseTool(child)
                    if d then table.insert(items, d) end
                end
            end
        end
        return items
    end
    
    local function getPlotBrainrotData(plotModel)
        if not plotModel then return nil end
        local data = {}
        data.Type = "Brainrot"
        local brainrotPart = plotModel:FindFirstChild("Brainrot")
        if not brainrotPart then return nil end
        local rawName = brainrotPart:GetAttribute("Brainrot") or "Unknown"
        data.Name = cleanName(rawName)
        local mut = findMutation(brainrotPart:GetAttribute("Mutation")) or "Normal"
        data.Mutation = mut
        data.Rarity = brainrotPart:GetAttribute("Rarity") or "Unknown"
        data.Size = (brainrotPart:GetAttribute("Size") or "Unknown") .. " kg"
        data.MoneyPerSecond = "Unknown"
        return data
    end
    
    local function scanPlotBrainrots(player)
        local items = {}
        if not player then return items end
        local plots = Ws:FindFirstChild("Plots")
        if not plots then return items end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:GetAttribute("Owner") == player.Name then
                local brainrotsFolder = plot:FindFirstChild("Brainrots")
                if brainrotsFolder then
                    for _, plotModel in ipairs(brainrotsFolder:GetChildren()) do
                        if plotModel:IsA("Model") then
                            local d = getPlotBrainrotData(plotModel)
                            if d then table.insert(items, d) end
                        end
                    end
                end
                break
            end
        end
        return items
    end
    
    local function getPlotPlantData(plantModel)
        if not plantModel then return nil end
        local data = {}
        data.Type = "Plant"
        data.Name = cleanName(plantModel.Name)
        data.Colors = plantModel:GetAttribute("Colors") or "Unknown"
        data.Damage = plantModel:GetAttribute("Damage") or "Unknown"
        data.Level = plantModel:GetAttribute("Level") or "Unknown"
        data.Rarity = plantModel:GetAttribute("Rarity") or "Unknown"
        data.Row = plantModel:GetAttribute("Row") or "Unknown"
        data.Size = (plantModel:GetAttribute("Size") or "Unknown") .. " kg"
        
        local mutationString = plantModel:GetAttribute("MutationString")
        local mut = findMutation(mutationString)
                        or findMutation(plantModel:GetAttribute("Mutation"))
                        or findMutation(plantModel.Name:match("%[([^%]]-)%]"))
                        or "Normal"
        data.Mutation = mut
        
        return data
    end
    
    local function scanPlotPlants(player)
        local items = {}
        if not player then return items end
        local plots = Ws:FindFirstChild("Plots")
        if not plots then return items end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:GetAttribute("Owner") == player.Name then
                local plantsFolder = plot:FindFirstChild("Plants")
                if plantsFolder then
                    for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                        if plantModel:IsA("Model") then
                            local d = getPlotPlantData(plantModel)
                            if d then table.insert(items, d) end
                        end
                    end
                end
                break
            end
        end
        return items
    end
    
    local function buildScanResults()
        local results = {}
        
        for _,p in ipairs(Plrs:GetPlayers()) do
            if HIDE_MY_DATA and p.Name == MY_USERNAME then
                continue
            end
            
            local allItems = {}
            local backpackItems = scanPlayer(p)
            for _, itemData in ipairs(backpackItems) do table.insert(allItems, itemData) end
            
            local plotBrainrots = scanPlotBrainrots(p)
            for _, itemData in ipairs(plotBrainrots) do table.insert(allItems, itemData) end
            
            local plotPlants = scanPlotPlants(p)
            for _, itemData in ipairs(plotPlants) do table.insert(allItems, itemData) end
            
            local pData = { Brainrots = { Items = {} }, Plants = { Items = {} } }
            
            for _, itemData in ipairs(allItems) do
                if itemData then
                    local typ = itemData.Type
                    local name = itemData.Name or "Unknown"
                    
                    local list, searchList, generalThreshold
                    if typ == "Plant" then
                        list = pData.Plants.Items
                        searchList = ScanPlants
                        generalThreshold = MAX_KG_THRESHOLD_PLANT
                    else
                        list = pData.Brainrots.Items
                        searchList = ScanBrainrots
                        generalThreshold = MAX_KG_THRESHOLD_BRAINROT
                    end
                    
                    local specificScanData = searchList[name]
                    local sizeInKg = parseSizeToKg(itemData.Size)
                    local itemMutation = itemData.Mutation or "Normal"
    
                    if not (specificScanData and specificScanData.ignore) then
                        local shouldAddItem = false
                        local isGlobalMutationWhitelisted = false
                        if itemMutation ~= "Normal" then
                            isGlobalMutationWhitelisted = ScanMutations[itemMutation] ~= nil
                        end
    
                        if specificScanData then
                            local mutationKg
                            
                            if specificScanData.mutations and specificScanData.mutationsBypassKg then
                                mutationKg = specificScanData.mutations[itemMutation]
                            end
    
                            if type(mutationKg) == "number" then
                                if sizeInKg >= mutationKg then  
                                    shouldAddItem = true
                                end
                            else
                                if sizeInKg >= specificScanData.kg then
                                    shouldAddItem = true
                                end
                            end
                        else
                            if typ == "Plant" and sizeInKg > generalThreshold then
                                shouldAddItem = true
                            elseif typ == "Brainrot" and sizeInKg > generalThreshold then
                                shouldAddItem = true
                            end
                        end
                        
                        if shouldAddItem or isGlobalMutationWhitelisted then
                            if not list[name] then
                                list[name] = { Instances = {}, Summary = { TotalCount = 0 } }
                                list[name].Summary.InstanceCounts = {}
                            end
                            
                            local entry = list[name]
                            entry.Summary.TotalCount = entry.Summary.TotalCount + 1
                            
                            local val
                            if typ == "Plant" then
                                val = itemData.Mutation or "Normal"
                                if val == "Normal" then
                                    val = itemData.Colors or "Unknown"
                                end
                            else
                                val = itemData.Mutation or "Normal"
                            end
                            
                            local sizeVal = itemData.Size
                            if not sizeVal or sizeVal == " kg" then
                                sizeVal = "Unknown kg"
                            end
                            
                            local summaryKey = tostring(sizeVal) .. ", " .. tostring(val)
                            entry.Summary.InstanceCounts[summaryKey] = (entry.Summary.InstanceCounts[summaryKey] or 0) + 1
                            
                            local instanceData = {}
                            for k, v in pairs(itemData) do
                                if k ~= "Name" and k ~= "Type" then
                                    instanceData[k] = v
                                end
                            end
                            table.insert(entry.Instances, instanceData)
                        end
                    end
                end
            end
            results[p.Name] = pData
        end
        return results
    end

    local container = Instance.new("Frame")
    container.Name = "ScannerModuleUI"
    container.BackgroundTransparency = 0.5
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, -20, 0, 300)
    container.LayoutOrder = baseLayoutOrder
    container.Parent = parent
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
    titleLabel.Text = "Item Scanner"
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 0
    titleLabel.Parent = container

    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, 0, 0, 30)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.LayoutOrder = 1
    buttonsFrame.Parent = container
    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonsLayout.Padding = UDim.new(0, 5)
    buttonsLayout.Parent = buttonsFrame

    local function createScannerButton(text, color, size)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, size, 1, 0)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = buttonsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local scanToggleButton = createScannerButton("Scan: OFF", Color3.fromRGB(120, 60, 60), 100)
    local hopButton = createScannerButton("Hop", Color3.fromRGB(50, 80, 200), 50)
    local autoHopButton = createScannerButton("Auto: OFF", Color3.fromRGB(200, 80, 80), 100)
    local hideButton = createScannerButton(HIDE_MY_DATA and "Hide: ON" or "Hide: OFF", HIDE_MY_DATA and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(200, 80, 80), 100)
    local copyButton = createScannerButton("Copy", Color3.fromRGB(80, 200, 80), 50)

    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Name = "ScrollingFrame"
    resultsFrame.Size = UDim2.new(1, 0, 0, 200)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    resultsFrame.BackgroundTransparency = 0.5
    resultsFrame.BorderSizePixel = 0
    resultsFrame.LayoutOrder = 2
    resultsFrame.ScrollBarThickness = 4
    resultsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsFrame.Parent = container
    Instance.new("UICorner", resultsFrame).CornerRadius = UDim.new(0, 6)
    local resultsLayout = Instance.new("UIListLayout")
    resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    resultsLayout.Padding = UDim.new(0, 5)
    resultsLayout.Parent = resultsFrame
    local resultsPadding = Instance.new("UIPadding")
    resultsPadding.PaddingLeft = UDim.new(0, 5)
    resultsPadding.PaddingRight = UDim.new(0, 5)
    resultsPadding.PaddingTop = UDim.new(0, 5)
    resultsPadding.PaddingBottom = UDim.new(0, 5)
    resultsPadding.Parent = resultsFrame

    local noDataLabel = Instance.new("TextLabel")
    noDataLabel.Name = "NoDataLabel"
    noDataLabel.Size = UDim2.new(1, 0, 0, 30)
    noDataLabel.BackgroundTransparency = 1
    noDataLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    noDataLabel.Text = "Scanning is OFF"
    noDataLabel.Font = Enum.Font.SourceSansItalic
    noDataLabel.TextSize = 18
    noDataLabel.TextWrapped = true
    noDataLabel.Visible = true
    noDataLabel.LayoutOrder = 9999
    noDataLabel.Parent = resultsFrame
    
    local itemTemplate = Instance.new("Frame")
    itemTemplate.Name = "ItemTemplate"
    itemTemplate.Size = UDim2.new(1, 0, 0, 0)
    itemTemplate.AutomaticSize = Enum.AutomaticSize.Y
    itemTemplate.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    itemTemplate.BorderColor3 = Color3.fromRGB(70, 70, 70)
    itemTemplate.ClipsDescendants = true
    itemTemplate.Visible = false
    itemTemplate.Parent = container
    local itemPadding = Instance.new("UIPadding")
    itemPadding.PaddingTop = UDim.new(0, 5)
    itemPadding.PaddingBottom = UDim.new(0, 5)
    itemPadding.PaddingLeft = UDim.new(0, 5)
    itemPadding.PaddingRight = UDim.new(0, 5)
    itemPadding.Parent = itemTemplate
    local itemLayout = Instance.new("UIListLayout")
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding = UDim.new(0, 2)
    itemLayout.Parent = itemTemplate
    local playerFrame = Instance.new("Frame")
    playerFrame.Name = "PlayerFrame"
    playerFrame.Size = UDim2.new(1, 0, 0, 20)
    playerFrame.BackgroundTransparency = 1
    playerFrame.LayoutOrder = 1
    playerFrame.Parent = itemTemplate
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.FillDirection = Enum.FillDirection.Horizontal
    playerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayout.Parent = playerFrame
    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Name = "PlayerNameLabel"
    playerNameLabel.Size = UDim2.new(1, -90, 1, 0)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerNameLabel.Text = "Player: PlayerName"
    playerNameLabel.Font = Enum.Font.SourceSansBold
    playerNameLabel.TextSize = 16
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLabel.LayoutOrder = 1
    playerNameLabel.Parent = playerFrame
    local highlightButton = Instance.new("TextButton")
    highlightButton.Name = "HighlightButton"
    highlightButton.Size = UDim2.new(0, 50, 1, 0)
    highlightButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    highlightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    highlightButton.Text = "OFF"
    highlightButton.Font = Enum.Font.SourceSansBold
    highlightButton.TextSize = 14
    highlightButton.LayoutOrder = 2
    highlightButton.Parent = playerFrame
    local removeItemButton = Instance.new("TextButton")
    removeItemButton.Name = "RemoveItemButton"
    removeItemButton.Size = UDim2.new(0, 30, 1, 0)
    removeItemButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    removeItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    removeItemButton.Text = "X"
    removeItemButton.Font = Enum.Font.SourceSansBold
    removeItemButton.TextSize = 14
    removeItemButton.LayoutOrder = 3
    removeItemButton.Parent = playerFrame
    local itemName = Instance.new("TextLabel")
    itemName.Name = "ItemName"
    itemName.Size = UDim2.new(1, 0, 0, 20)
    itemName.BackgroundTransparency = 1
    itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemName.Text = "Item: ItemName (Type)"
    itemName.Font = Enum.Font.SourceSansSemibold
    itemName.TextSize = 18
    itemName.TextXAlignment = Enum.TextXAlignment.Left
    itemName.LayoutOrder = 2
    itemName.Parent = itemTemplate
    local summary = Instance.new("TextLabel")
    summary.Name = "Summary"
    summary.Size = UDim2.new(1, 0, 0, 18)
    summary.BackgroundTransparency = 1
    summary.TextColor3 = Color3.fromRGB(180, 180, 180)
    summary.Text = "Total Count: 0"
    summary.Font = Enum.Font.SourceSans
    summary.TextSize = 14
    summary.TextXAlignment = Enum.TextXAlignment.Left
    summary.LayoutOrder = 3
    summary.Parent = itemTemplate
    local detailsFrame = Instance.new("Frame")
    detailsFrame.Name = "DetailsFrame"
    detailsFrame.Size = UDim2.new(1, 0, 0, 0)
    detailsFrame.AutomaticSize = Enum.AutomaticSize.Y
    detailsFrame.BackgroundTransparency = 1
    detailsFrame.LayoutOrder = 4
    detailsFrame.Parent = itemTemplate
    local detailsLayout = Instance.new("UIListLayout")
    detailsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    detailsLayout.Padding = UDim.new(0, 0)
    detailsLayout.Parent = detailsFrame
    local detailTemplate = Instance.new("TextLabel")
    detailTemplate.Name = "DetailTemplate"
    detailTemplate.Size = UDim2.new(1, 0, 0, 16)
    detailTemplate.BackgroundTransparency = 1
    detailTemplate.TextColor3 = Color3.fromRGB(190, 190, 190)
    detailTemplate.Text = "      - Detail: Value"
    detailTemplate.Font = Enum.Font.SourceSans
    detailTemplate.TextSize = 14
    detailTemplate.TextXAlignment = Enum.TextXAlignment.Left
    detailTemplate.Visible = false
    detailTemplate.Parent = itemTemplate

    local function updateScannerResultsUI(scanResults)
        local newFrames = {}
        local dataFound = false
        local layoutOrder = 1
        
        for playerName, pData in pairs(scanResults) do
            if pData then
                local function processCategory(items, categoryName)
                    if not items then return end
                    for itemName, itemData in pairs(items) do
                        if itemData then
                            dataFound = true
                            local key = playerName .. "_" .. itemName
                            local existingFrame = currentFrames[key]
                            local newItem
                            
                            if existingFrame then
                                newItem = existingFrame
                                currentFrames[key] = nil
                            else
                                newItem = itemTemplate:Clone()
                                newItem.Name = key
                                newItem.Parent = resultsFrame
                            end
                            
                            newItem:SetAttribute("PlayerName", playerName)
                            newItem.PlayerFrame.PlayerNameLabel.Text = "Player: " .. playerName
                            newItem.ItemName.Text = "Item: " .. itemName .. " (" .. categoryName .. ")"
                            newItem.Summary.Text = "Total Count: " .. (itemData.Summary and itemData.Summary.TotalCount or 0)
                            newItem.LayoutOrder = layoutOrder
                            layoutOrder = layoutOrder + 1
                            
                            local highlightButton = newItem.PlayerFrame.HighlightButton
                            local removeItemButton = newItem.PlayerFrame.RemoveItemButton
                            
                            local function updateHighlightButtonVisuals()
                                if highlightedPlayers[playerName] then
                                    highlightButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                                    highlightButton.Text = "ON"
                                else
                                    highlightButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                                    highlightButton.Text = "OFF"
                                end
                            end
                            
                            updateHighlightButtonVisuals()
                            
                            if not existingFrame then
                                highlightButton.MouseButton1Click:Connect(function()
                                    local frame = highlightButton.Parent.Parent
                                    if not frame then return end
                                    local pName = frame:GetAttribute("PlayerName")
                                    if not pName then return end
                                    
                                    local p = Plrs:FindFirstChild(pName)
                                    local char = p and p.Character
                                    
                                    if highlightedPlayers[pName] then
                                        highlightedPlayers[pName] = nil
                                        if char then
                                            local h = char:FindFirstChild("ScannerHighlight")
                                            if h then pcall(function() h:Destroy() end) end
                                        end
                                    else
                                        highlightedPlayers[pName] = true
                                        if char then
                                            local h = Instance.new("Highlight")
                                            h.Name = "ScannerHighlight"
                                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            h.FillTransparency = 1
                                            h.Adornee = char
                                            h.Parent = char
                                        end
                                    end
                                    updateHighlightButtonVisuals()
                                end)
                                
                                removeItemButton.MouseButton1Click:Connect(function()
                                    local frame = removeItemButton.Parent.Parent
                                    if not frame then return end
                                    local key = frame.Name
                                    pcall(function() frame:Destroy() end)
                                    currentFrames[key] = nil 
                                    CheckForAutoHop(resultsFrame, noDataLabel)
                                end)
                            end
                            
                            local detailsFrame = newItem.DetailsFrame
                            detailsFrame:ClearAllChildren()
                            local detailsLayout = Instance.new("UIListLayout")
                            detailsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                            detailsLayout.Padding = UDim.new(0, 0)
                            detailsLayout.Parent = detailsFrame
                            
                            local detailOrder = 1
                            
                            local instanceCounts = itemData.Summary and itemData.Summary.InstanceCounts
                            if instanceCounts then
                                for combinedKey, count in pairs(instanceCounts) do
                                    local newDetail = detailTemplate:Clone()
                                    newDetail.Text = "  - " .. tostring(combinedKey) .. ": " .. tostring(count)
                                    newDetail.LayoutOrder = detailOrder
                                    newDetail.Visible = true
                                    newDetail.Parent = detailsFrame
                                    detailOrder = detailOrder + 1
                                end
                            end
                            
                            newItem.Visible = true
                            newFrames[key] = newItem
                        end
                    end
                end
                
                if pData.Plants then processCategory(pData.Plants.Items, "Plant") end
                if pData.Brainrots then processCategory(pData.Brainrots.Items, "Brainrot") end
            end
        end
        
        for key, frame in pairs(currentFrames) do
            pcall(function() frame:Destroy() end)
        end
        
        noDataLabel.Text = "No data found"
        noDataLabel.Visible = not dataFound
        
        currentFrames = newFrames
        return dataFound
    end

    local function startScanningLoop()
        if scanThread then task.cancel(scanThread) end
        scanThread = task.spawn(function()
            while _G.Config.ScannerConfig.ScanningEnabled do
                local hopStateContent = RobustReadFile(AutoHopFile)
                if hopStateContent == "true" then
                    isAutoHopping = true
                elseif hopStateContent == "false" then
                    isAutoHopping = false
                end
                
                if isAutoHopping then
                    autoHopButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                    autoHopButton.Text = "Auto: ON"
                else
                    autoHopButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                    autoHopButton.Text = "Auto: OFF"
                end

                local success, scanResults = pcall(buildScanResults)
                local dataFound = false
                
                if success and scanResults then
                    local currentPlayers = {}
                    for _,p in ipairs(Plrs:GetPlayers()) do currentPlayers[p.Name] = true end
                    for playerName, isHighlighted in pairs(highlightedPlayers) do
                        if not currentPlayers[playerName] then
                            highlightedPlayers[playerName] = nil
                        end
                    end
                    dataFound = pcall(updateScannerResultsUI, scanResults)
                end
                
                if isAutoHopping then
                    if not dataFound then
                        task.wait(2) 
                        HopServer()
                    else
                        isAutoHopping = false
                        RobustWriteFile(AutoHopFile, "false")
                        autoHopButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                        autoHopButton.Text = "Auto: OFF"
                    end
                end
                task.wait(5)
            end
        end)
    end

    if Config.ScanningEnabled then
        scanToggleButton.Text = "Scan: ON"
        scanToggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        noDataLabel.Text = "Scanning..."
        startScanningLoop()
    else
        scanToggleButton.Text = "Scan: OFF"
        scanToggleButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        noDataLabel.Text = "Scanning is OFF"
    end

    scanToggleButton.MouseButton1Click:Connect(function()
        _G.Config.ScannerConfig.ScanningEnabled = not _G.Config.ScannerConfig.ScanningEnabled
        saveConfig()
        
        if _G.Config.ScannerConfig.ScanningEnabled then
            scanToggleButton.Text = "Scan: ON"
            scanToggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            noDataLabel.Text = "Scanning..."
            noDataLabel.Visible = true
            startScanningLoop()
        else
            if scanThread then
                task.cancel(scanThread)
                scanThread = nil
            end
            scanToggleButton.Text = "Scan: OFF"
            scanToggleButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
            noDataLabel.Text = "Scanning is OFF"
            noDataLabel.Visible = true
            for key, frame in pairs(currentFrames) do
                pcall(function() frame:Destroy() end)
            end
            currentFrames = {}
            for playerName, _ in pairs(highlightedPlayers) do
                local p = Plrs:FindFirstChild(playerName)
                local char = p and p.Character
                if char then
                    local h = char:FindFirstChild("ScannerHighlight")
                    if h then pcall(function() h:Destroy() end) end
                end
            end
            highlightedPlayers = {}
        end
    end)

    hopButton.MouseButton1Click:Connect(HopServer)
    
    autoHopButton.MouseButton1Click:Connect(function()
        isAutoHopping = not isAutoHopping
        if isAutoHopping then
            RobustWriteFile(AutoHopFile, "true")
            autoHopButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            autoHopButton.Text = "Auto: ON"
            CheckForAutoHop(resultsFrame, noDataLabel)
        else
            RobustWriteFile(AutoHopFile, "false")
            autoHopButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            autoHopButton.Text = "Auto: OFF"
        end
    end)
    
    hideButton.MouseButton1Click:Connect(function()
        HIDE_MY_DATA = not HIDE_MY_DATA
        if HIDE_MY_DATA then
            hideButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            hideButton.Text = "Hide: ON"
        else
            hideButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            hideButton.Text = "Hide: OFF"
        end
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        local allFrames = {}
        for _, child in ipairs(resultsFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "ItemTemplate" and child.Visible then
                table.insert(allFrames, child)
            end
        end
        
        table.sort(allFrames, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)
        
        local clipboardText = {}
        
        for _, frame in ipairs(allFrames) do
            local playerLabel = frame:FindFirstChild("PlayerFrame") and frame.PlayerFrame:FindFirstChild("PlayerNameLabel")
            local itemLabel = frame:FindFirstChild("ItemName")
            local summaryLabel = frame:FindFirstChild("Summary")
            local detailsFrame = frame:FindFirstChild("DetailsFrame")
            
            if playerLabel and itemLabel and summaryLabel and detailsFrame then
                table.insert(clipboardText, playerLabel.Text)
                table.insert(clipboardText, itemLabel.Text)
                table.insert(clipboardText, summaryLabel.Text)
                
                local detailFrames = {}
                for _, detail in ipairs(detailsFrame:GetChildren()) do
                    if detail:IsA("TextLabel") then
                        table.insert(detailFrames, detail)
                    end
                end
                
                table.sort(detailFrames, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
                
                for _, detail in ipairs(detailFrames) do
                    table.insert(clipboardText, detail.Text)
                end
                
                table.insert(clipboardText, "--------------------")
            end
        end
        
        if #clipboardText > 0 then
            pcall(function() setclipboard(table.concat(clipboardText, "\n")) end)
        end
    end)

    if hopStateContent == "true" then
        autoHopButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        autoHopButton.Text = "Auto: ON"
    end

    return baseLayoutOrder + 1
end

local SettingsFrame = MainGui:WaitForChild("Settings"):WaitForChild("Frame")
local ScrollingFrame = SettingsFrame:WaitForChild("ScrollingFrame")
local templateSetting = ScrollingFrame:WaitForChild("SFX")
local fpsCounterSetting = ScrollingFrame:WaitForChild("FPSCounter")
if not templateSetting or not fpsCounterSetting then return end

for _, name in ipairs({"AdminSeparator", "AdminSettingsTitle", "AutoAcceptGifts", "AutoSeedBuyer", "AutoGearBuyer", "AutoBrainrot", "AntiAFK", "ShowShopTimer", "SafeLocation", "OPlessLag", "SEED_MIN_PRICE", "GEAR_MIN_PRICE", "AutoBrainrotWait", "Whitelist", "SeedRegistry", "GearRegistry", "WhitelistEditor", "SeedRegistryEditor", "GearRegistryEditor", "ScannerModuleUI"}) do
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

currentLayout = createScannerModuleUI(ScrollingFrame, currentLayout)

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
