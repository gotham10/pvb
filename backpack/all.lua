local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")

local wl = {""}
local p = Players.LocalPlayer
if not table.find(wl, p.Name) then return end

local player = p
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")
local modules = ReplicatedStorage:WaitForChild("Modules")
local registries = modules:WaitForChild("Registries")

local function runSeedBuyer()
    local MIN_PRICE = 200
    
    local seedRegistryTable = {
        ["Cactus Seed"] = { Plant = "Cactus", Price = 200 },
		["Strawberry Seed"] = { Plant = "Strawberry", Price = 1250 },
		["Pumpkin Seed"] = { Plant = "Pumpkin", Price = 5000 },
		["Sunflower Seed"] = { Plant = "Sunflower", Price = 25000 },
		["Dragon Fruit Seed"] = { Plant = "Dragon Fruit", Price = 100000 },
		["Eggplant Seed"] = { Plant = "Eggplant", Price = 250000 },
		["Watermelon Seed"] = { Plant = "Watermelon", Price = 1000000 },
		["Grape Seed"] = { Plant = "Grape", Price = 2500000 },
        ["Cocotank Seed"] = { Plant = "Cocotank", Price = 5000000 },
        ["Carnivorous Plant Seed"] = { Plant = "Carnivorous Plant", Price = 25000000 },
        ["Mr Carrot Seed"] = { Plant = "Mr Carrot", Price = 50000000 },
        ["Tomatrio Seed"] = { Plant = "Tomatrio", Price = 125000000 },
        ["Shroombino Seed"] = { Plant = "Shroombino", Price = 200000000 },
		["Mango Seed"] = { Plant = "Mango", Price = 367000000 },
        ["King Limone Seed"] = { Plant = "King Limone", Price = 670000000 },
		["Starfruit Seed"] = { Plant = "Starfruit", Price = 750000000 },
    }

    local buyRemote = remotes:WaitForChild("BuyItem", 5)
    local seedsGui = mainGui:WaitForChild("Seeds", 5)

    if not seedsGui or not buyRemote then
        return
    end

    local scrolling = seedsGui.Frame:WaitForChild("ScrollingFrame", 5)
    if not scrolling then
        return
    end

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
    for seedName, seedInfo in pairs(seedRegistryTable) do
        if type(seedInfo) == "table" and seedInfo.Price then
            seedPrices[seedName] = tonumber(seedInfo.Price)
        end
    end

    local function canBuy(seedName)
        local price = seedPrices[seedName]
        if not price then
            return false
        end
        if price >= MIN_PRICE then
            return true
        else
            return false
        end
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
        if not stockLabel then
            return
        end
        
        processedFrames[frame] = true

        local function onStockChanged()
            while true do
                local count = parseStock(stockLabel.Text)
                if count > 0 then
                    if not attemptBuy(seedName) then
                        break
                    end
                else
                    break
                end
                task.wait()
            end
        end

        stockLabel:GetPropertyChangedSignal("Text"):Connect(onStockChanged)
        onStockChanged()
    end

    local function scanAll()
        for _, child in ipairs(scrolling:GetChildren()) do
            if not isIgnored(child) then
                processFrame(child)
            end
        end
    end
    
    scrolling.ChildAdded:Connect(function(child)
        if not isIgnored(child) then
            processFrame(child)
        end
    end)

    local function parseTimeToSeconds(text)
        if not text then return 0 end
        local mm, ss = text:match("(%d+):(%d+)")
        if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
        return tonumber(text:match("(%d+)")) or 0
    end

    if restockLabel then
        local lastSeconds = parseTimeToSeconds(restockLabel.Text)
        restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
            local s = parseTimeToSeconds(restockLabel.Text)
            if s > lastSeconds then
                task.wait(0.5)
                scanAll()
            end
            lastSeconds = s
        end)
    end

    task.wait(1)
    scanAll()
end

local function runGearBuyer()
    local gearRegistryTable = {
        ["Water Bucket"] = { Price = 7500 },
        ["Frost Gernade"] = { Price = 12500 },
        ["Banana Gun"] = { Price = 25000 },
        ["Frost Blower"] = { Price = 125000 },
        ["Carrot Launcher"] = { Price = 500000 }
    }
    
    local buyRemote = remotes:FindFirstChild("BuyGear")
    local gearsGui = mainGui:FindFirstChild("Gears")

    if not gearsGui or not buyRemote then
        return
    end

    local scrolling = gearsGui:FindFirstChild("Frame") and gearsGui.Frame:FindFirstChild("ScrollingFrame")
    if not scrolling then
        return
    end

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
        if not gearName or gearName == "" or not gearRegistryTable[gearName] then
            processedFrames[frame] = true
            return
        end
        
        local stockLabel = findStockLabel(frame)
        if not stockLabel then
            return
        end
        
        processedFrames[frame] = true

        local function onStockChanged()
            while true do
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

        stockLabel:GetPropertyChangedSignal("Text"):Connect(onStockChanged)
        onStockChanged()
    end

    local function scanAll()
        for _, child in ipairs(scrolling:GetChildren()) do
            if not isIgnored(child) then
                processFrame(child)
            end
        end
    end
    
    scrolling.ChildAdded:Connect(function(child)
        if not isIgnored(child) then
            processFrame(child)
        end
    end)

    local function parseTimeToSeconds(t)
        if not t then return 0 end
        local mm, ss = t:match("(%d+):(%d+)")
        if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
        local n = t:match("(%d+)")
        return tonumber(n) or 0
    end

    if restockLabel then
        local lastSeconds = parseTimeToSeconds(restockLabel.Text)
        restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
            local s = parseTimeToSeconds(restockLabel.Text)
            if s > lastSeconds then
                task.wait(0.5)
                scanAll()
            end
            lastSeconds = s
        end)
    end

    scanAll()
end

local function runAutoSell()
    local b = playerGui.Main.AutoSell.Frame.Limited.TextButton
    local rem = remotes.AutoSell
    
    if not b or not rem then return end

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
        local g = getGradiDients()
        if not g.selected or not g.unselected then return end
        
        local s = g.selected.Enabled
        local u = g.unselected.Enabled
        
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
    
    pcall(updateAutoSell)
    
    ws.AttributeChanged:Connect(function(attr)
        if attr == "ActiveEvents" then
            pcall(updateAutoSell)
        end
    end)
    
    task.spawn(function()
        while task.wait(3) do
            pcall(updateAutoSell)
        end
    end)
end

coroutine.wrap(runSeedBuyer)()
coroutine.wrap(runGearBuyer)()
coroutine.wrap(runAutoSell)()
