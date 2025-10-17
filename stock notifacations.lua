local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local ItemsData = {}
local itemsDataUrl = "https://raw.githubusercontent.com/gotham10/pvb/main/plantstockdata.json"
local activeTargetItems = {}

local notificationSound = Instance.new("Sound")
notificationSound.Name = "SeedNotifierAlertSound"
notificationSound.SoundId = "rbxassetid://5603534974"
notificationSound.Looped = true
notificationSound.Parent = SoundService

local function muteOtherSounds()
    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("Sound") and descendant.Name ~= notificationSound.Name then
            descendant.Volume = 0
        end
    end
end

game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound") and descendant.Name ~= notificationSound.Name then
        task.wait()
        descendant.Volume = 0
    end
end)

muteOtherSounds()

local function handleStockChange(plantName, stockLabel)
    local stockText = stockLabel.Text
    local stockNumber = tonumber(stockText:match("x(%d+)"))
    if stockNumber ~= nil then
        print(plantName .. " - In Stock: " .. tostring(stockNumber))

        local itemData = ItemsData[plantName]
        if itemData and itemData.IsTarget then
            local index = table.find(activeTargetItems, plantName)

            if stockNumber > 0 then
                if not index then
                    table.insert(activeTargetItems, plantName)
                    StarterGui:SetCore("SendNotification", {
                        Title = plantName,
                        Text = "In Stock: " .. tostring(stockNumber),
                        Icon = itemData.Icon,
                        Duration = 295,
                    })
                end
            elseif index then
                table.remove(activeTargetItems, index)
            end

            if #activeTargetItems > 0 and not notificationSound.IsPlaying then
                notificationSound:Play()
            elseif #activeTargetItems == 0 and notificationSound.IsPlaying then
                notificationSound:Stop()
            end
        end
    end
end

local function setupListenersForFrame(frame)
    if frame:IsA("Frame") and frame.Name ~= "Padding" then
        local plantName = frame.Name:gsub("Seed$", ""):match("^%s*(.-)%s*$")
        local stockLabel = frame:WaitForChild("Stock")
        if stockLabel and stockLabel:IsA("TextLabel") then
            handleStockChange(plantName, stockLabel)
            stockLabel:GetPropertyChangedSignal("Text"):Connect(function()
                handleStockChange(plantName, stockLabel)
            end)
        end
    end
end

local function initializeNotifier()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local scrollingFrame = playerGui:WaitForChild("Main"):WaitForChild("Seeds"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")

    for _, frame in ipairs(scrollingFrame:GetChildren()) do
        setupListenersForFrame(frame)
    end

    scrollingFrame.ChildAdded:Connect(setupListenersForFrame)
end

local function initializeRestockListener()
    local restockLabel = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Seeds"):WaitForChild("Restock")
    if restockLabel then
        restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
            if restockLabel.Text:match("04:59") or restockLabel.Text:match("05:00") then
                if notificationSound.IsPlaying then
                    notificationSound:Stop()
                end
                activeTargetItems = {}
            end
        end)
    end
end

local function updateItemsData()
    local success, response = pcall(function()
        return request({Url = itemsDataUrl, Method = "GET"})
    end)
    if success and response and response.StatusCode == 200 then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        if decodeSuccess and type(data) == "table" then
            ItemsData = data
            initializeNotifier()
            initializeRestockListener()
        end
    end
end

updateItemsData()
