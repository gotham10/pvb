_G.ScriptManager = _G.ScriptManager or { Connections = {}, Threads = {} }
_G.AutoSellSecret_Active = true
local updateAutoSellSecret

local function cleanup(key)
    if _G.ScriptManager.Connections[key] then
        for _, conn in ipairs(_G.ScriptManager.Connections[key]) do
            pcall(conn.Disconnect, conn)
        end
    end
    _G.ScriptManager.Connections[key] = {}
    
    if _G.ScriptManager.Threads[key] then
        pcall(coroutine.close, _G.ScriptManager.Threads[key])
    end
    _G.ScriptManager.Threads[key] = nil
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")

local p = Players.LocalPlayer
if not _G.Config or not table.find(_G.Config.wl, p.Name) then return end

local player = p
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")
local modules = ReplicatedStorage:WaitForChild("Modules")
local registries = modules:WaitForChild("Registries")

local function runSeedBuyer()
    cleanup("SeedBuyer")
    if not _G.Config.AutoSeedBuyer then return end

    local connections = {}
    _G.ScriptManager.Connections["SeedBuyer"] = connections

    local buyRemote = remotes:WaitForChild("BuyItem", 5)
    local seedsGui = mainGui:WaitForChild("Seeds", 5)

    if not seedsGui or not buyRemote then return end

    local scrolling = seedsGui.Frame:WaitForChild("ScrollingFrame", 5)
    if not scrolling then return end

    local restockLabel = seedsGui:WaitForChild("Restock", 5)

    local function isIgnored(inst)
        if not inst or inst.Name == "Padding" then return true end
        local c = inst.ClassName
        return c == "UIPadding" or c == "UIListLayout"
    end

    local function findStockLabel(frame)
        for _, v in ipairs(frame:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then
                return v
            end
        end
        return nil
    end

    local function parseStock(text)
        if not text then return 0 end
        local n = text:match("x%s*(%d+)") or text:match("(%d+)")
        return tonumber(n) or 0
    end

    local seedPrices = {}
    for seedName, seedInfo in pairs(_G.Config.seedRegistryTable) do
        if type(seedInfo) == "table" and seedInfo.Price then
            seedPrices[seedName] = tonumber(seedInfo.Price)
        end
    end

    local function canBuy(seedName)
        local price = seedPrices[seedName]
        if not price then return false end
        return price >= _G.Config.SEED_MIN_PRICE
    end

    local function attemptBuy(seedName)
        local ok, err = pcall(function() buyRemote:FireServer(seedName) end)
        return ok
    end

    local processedFrames = {}

    local function processFrame(frame)
        if isIgnored(frame) or processedFrames[frame] then return end

        local seedName = frame.Name
        if not canBuy(seedName) then
            processedFrames[frame] = true
            return
        end

        local stockLabel = findStockLabel(frame)
        if not stockLabel then return end
        
        processedFrames[frame] = true

        local function onStockChanged()
            while _G.Config.AutoSeedBuyer do
                local count = parseStock(stockLabel.Text)
                if count > 0 then
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
        for _, child in ipairs(scrolling:GetChildren()) do
            if not isIgnored(child) then
                processFrame(child)
            end
        end
    end
    
    table.insert(connections, scrolling.ChildAdded:Connect(function(child)
        if not _G.Config.AutoSeedBuyer then return end
        if not isIgnored(child) then
            processFrame(child)
        end
    end))

    local function parseTimeToSeconds(text)
        if not text then return 0 end
        local mm, ss = text:match("(%d+):(%d+)")
        if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
        return tonumber(text:match("(%d+)")) or 0
    end

    if restockLabel then
        local lastSeconds = parseTimeToSeconds(restockLabel.Text)
        table.insert(connections, restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
            if not _G.Config.AutoSeedBuyer then return end
            local s = parseTimeToSeconds(restockLabel.Text)
            if s > lastSeconds then
                task.wait(0.5)
                scanAll()
            end
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

    local buyRemote = remotes:FindFirstChild("BuyGear")
    local gearsGui = mainGui:FindFirstChild("Gears")

    if not gearsGui or not buyRemote then return end

    local scrolling = gearsGui:FindFirstChild("Frame") and gearsGui.Frame:FindFirstChild("ScrollingFrame")
    if not scrolling then return end

    local restockLabel = gearsGui:FindFirstChild("Restock") or gearsGui.Frame:FindFirstChild("Restock")

    local function isIgnored(i)
        if not i or i.Name == "Padding" then return true end
        local c = i.ClassName
        return c == "UIPadding" or c == "UIListLayout"
    end

    local function findStockLabel(frame)
        if not frame then return nil end
        local direct = frame:FindFirstChild("Stock") or frame:FindFirstChild("StockValue")
        if direct and direct:IsA("TextLabel") then return direct end
        for _, v in ipairs(frame:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then
                return v
            end
        end
        return nil
    end

    local function parseStock(text)
        if not text then return 0 end
        local n = text:match("x%s*(%d+)") or text:match("(%d+)")
        return tonumber(n) or 0
    end
    
    local function canBuy(gearName)
        if not gearName or gearName == "" then return false end
        local gearInfo = _G.Config.gearRegistryTable[gearName]
        if not gearInfo or not gearInfo.Price then
            return false
        end
        return gearInfo.Price >= _G.Config.GEAR_MIN_PRICE
    end

    local function attemptBuy(gearName)
        local success, err
        
        success, err = pcall(function() buyRemote:FireServer(gearName) end)
        if success then return true end
        task.wait(0.15)
        
        success, err = pcall(function() buyRemote:FireServer({ Name = gearName }) end)
        if success then return true end
        task.wait(0.15)
        
        success, err = pcall(function() buyRemote:FireServer({ ID = gearName }) end)
        if success then return true end
        
        return false
    end

    local processedFrames = {}

    local function processFrame(frame)
        if isIgnored(frame) or processedFrames[frame] then return end
        
        local gearName = frame.Name
        if not canBuy(gearName) then
            processedFrames[frame] = true
            return
        end
        
        local stockLabel = findStockLabel(frame)
        if not stockLabel then return end
        
        processedFrames[frame] = true

        local function onStockChanged()
            while _G.Config.AutoGearBuyer do
                local count = parseStock(stockLabel.Text)
                if count > 0 then
                    if not attemptBuy(gearName) then
                        break
                    end
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
        for _, child in ipairs(scrolling:GetChildren()) do
            if not isIgnored(child) then
                processFrame(child)
            end
        end
    end
    
    table.insert(connections, scrolling.ChildAdded:Connect(function(child)
        if not _G.Config.AutoGearBuyer then return end
        if not isIgnored(child) then
            processFrame(child)
        end
    end))

    local function parseTimeToSeconds(t)
        if not t then return 0 end
        local mm, ss = t:match("(%d+):(%d+)")
        if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
        local n = t:match("(%d+)")
        return tonumber(n) or 0
    end

    if restockLabel then
        local lastSeconds = parseTimeToSeconds(restockLabel.Text)
        table.insert(connections, restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
            if not _G.Config.AutoGearBuyer then return end
            local s = parseTimeToSeconds(restockLabel.Text)
            if s > lastSeconds then
                task.wait(0.5)
                scanAll()
            end
            lastSeconds = s
        end))
    end

    scanAll()
end

local b_limited
local b_secret
local rem_autoSell

local function getGradients(b)
    local g = {}
    if not b then return g end
    for _, v in pairs(b:GetDescendants()) do
        if v:IsA("UIGradient") then
            g[v.Name] = v
        end
    end
    return g
end

local function updateAutoSellLimited()
    if not b_limited or not rem_autoSell then return end
    
    local g = getGradients(b_limited)
    if not g.selected or not g.unselected then return end
    
    local isSelected = g.selected.Enabled
    local desiredState = false

    if _G.Config.AutoSellLimited then
        local e = ws:GetAttribute("ActiveEvents") or ""
        desiredState = not not string.find(e, "HalloweenEvent")
    end

    if isSelected ~= desiredState then
        pcall(rem_autoSell.FireServer, rem_autoSell, "Limited")
    end
end

updateAutoSellSecret = function()
    if not b_secret or not rem_autoSell then return end
    
    local g = getGradients(b_secret)
    if not g.selected or not g.unselected then return end

    local isSelected = g.selected.Enabled
    local desiredState = false

    if _G.Config.AutoSellSecret then
        desiredState = _G.AutoSellSecret_Active
    end
    
    if isSelected ~= desiredState then
        pcall(rem_autoSell.FireServer, rem_autoSell, "Secret")
    end
end

local function runAutoSell()
    cleanup("AutoSell")
    
    local connections = {}
    _G.ScriptManager.Connections["AutoSell"] = connections

    b_limited = playerGui.Main.AutoSell.Frame.Limited.TextButton
    b_secret = playerGui.Main.AutoSell.Frame.Secret.TextButton
    rem_autoSell = remotes.AutoSell
    
    if not rem_autoSell then return end
    
    pcall(updateAutoSellLimited)
    pcall(updateAutoSellSecret)
    
    table.insert(connections, ws.AttributeChanged:Connect(function(attr)
        if attr == "ActiveEvents" then
            pcall(updateAutoSellLimited)
        end
    end))
    
    local thread = coroutine.create(function()
        while _G.Config.AutoSellLimited or _G.Config.AutoSellSecret or task.wait(3) do
            if coroutine.status(thread) == "dead" then break end
            task.wait(3)
            pcall(updateAutoSellLimited)
            pcall(updateAutoSellSecret)
        end
    end)
    _G.ScriptManager.Threads["AutoSell"] = thread
    coroutine.resume(thread)
end

local function runMissionBrainrotMonitor()
    if not _G.Config.AutoSellSecret then return end
    
    cleanup("BrainrotMonitor")
    local connections = {}
    _G.ScriptManager.Connections["BrainrotMonitor"] = connections
    
    local mySpecialBrainrots = {}
    local missionBrainrots = ws:WaitForChild("ScriptedMap"):WaitForChild("MissionBrainrots")

    local function checkMyBrainrots()
        local stillHaveSpecial = next(mySpecialBrainrots)
        local newState = not stillHaveSpecial
        if _G.AutoSellSecret_Active ~= newState then
            _G.AutoSellSecret_Active = newState
            pcall(updateAutoSellSecret)
        end
    end

    local function onChildAdded(child)
        if child.Name == "Hacktini" or child.Name == "Adminini" then
            local plotNum = child:GetAttribute("Plot")
            if plotNum then
                local plot = ws.Plots:FindFirstChild(tostring(plotNum))
                if plot and plot:GetAttribute("Owner") == p.Name then
                    mySpecialBrainrots[child] = true
                    checkMyBrainrots()
                end
            end
        end
    end

    local function onChildRemoved(child)
        if mySpecialBrainrots[child] then
            mySpecialBrainrots[child] = nil
            checkMyBrainrots()
        end
    end

    table.insert(connections, missionBrainrots.ChildAdded:Connect(onChildAdded))
    table.insert(connections, missionBrainrots.ChildRemoved:Connect(onChildRemoved))

    for _, child in ipairs(missionBrainrots:GetChildren()) do
        pcall(onChildAdded, child)
    end
    
    pcall(checkMyBrainrots)
end

local function getPlayerPlot()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        if plot:GetAttribute("Owner") == player.Name then
            return plot
        end
    end
    return nil
end

local function runAutoBrainrot()
    cleanup("AutoBrainrot")
    if not _G.Config.AutoBrainrot then return end

    local remotesFolder = remotes
    local equipRemote = remotesFolder:FindFirstChild("EquipBestBrainrots") or remotesFolder:FindFirstChild("EquipBest")

    local thread = coroutine.create(function()
        while _G.Config.AutoBrainrot and task.wait(_G.Config.AutoBrainrotWait or 60) do
            if coroutine.status(thread) == "dead" then break end
            pcall(function()
                local playerPlot = getPlayerPlot()
                if not playerPlot then return end

                if equipRemote then
                    equipRemote:FireServer()
                end

                task.wait(1)

                if playerPlot:FindFirstChild("Brainrots") then
                    for _, brainrot in ipairs(playerPlot.Brainrots:GetChildren()) do
                        if brainrot:FindFirstChild("Hitbox") and brainrot.Hitbox:FindFirstChild("ProximityPrompt") then
                            local prompt = brainrot.Hitbox.ProximityPrompt
                            if prompt.Enabled then
                                prompt:InputHoldBegin()
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
        end
    end)
    _G.ScriptManager.Threads["AutoBrainrot"] = thread
    coroutine.resume(thread)
end

local function runAutoAcceptGifts()
    cleanup("AutoAcceptGifts")
    if not _G.Config.AutoAcceptGifts then return end

    local connections = {}
    _G.ScriptManager.Connections["AutoAcceptGifts"] = connections

    local acceptGiftRemote = remotes:WaitForChild("AcceptGift")
    local giftItemRemote = remotes:WaitForChild("GiftItem")

    if not acceptGiftRemote or not giftItemRemote then return end

    local conn = giftItemRemote.OnClientEvent:Connect(function(giftPayload)
        if not _G.Config.AutoAcceptGifts then return end
        if giftPayload and type(giftPayload) == "table" and giftPayload.ID then
            acceptGiftRemote:FireServer({
                ID = giftPayload.ID
            })
        end
    end)
    table.insert(connections, conn)
end

runSeedBuyer()
runGearBuyer()
runAutoSell()
runMissionBrainrotMonitor()
runAutoBrainrot()
runAutoAcceptGifts()
