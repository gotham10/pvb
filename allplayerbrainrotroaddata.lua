local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    return
end
local localUserId = localPlayer.UserId
local selectedUserId = localUserId

local brainrotsFolder = Workspace:WaitForChild("ScriptedMap"):WaitForChild("Brainrots")
if not brainrotsFolder then
    return
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotMonitorUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(1, -370, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40)
mainFrame.BorderColor3 = Color3.fromRGB(25, 26, 28)
mainFrame.BorderSizePixel = 2
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 26, 28)
titleLabel.Text = "Brainrot Monitor"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.ZIndex = 2
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(25, 26, 28)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.ZIndex = 3
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local playerDropdown = Instance.new("Frame")
playerDropdown.Name = "PlayerDropdown"
playerDropdown.Size = UDim2.new(1, -20, 0, 40)
playerDropdown.Position = UDim2.new(0, 10, 0, 45)
playerDropdown.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
playerDropdown.BorderSizePixel = 0
playerDropdown.ZIndex = 10
playerDropdown.ClipsDescendants = false
playerDropdown.Parent = mainFrame

local pdCorner = Instance.new("UICorner")
pdCorner.CornerRadius = UDim.new(0, 6)
pdCorner.Parent = playerDropdown

local selectedPlayerButton = Instance.new("TextButton")
selectedPlayerButton.Name = "SelectedPlayerButton"
selectedPlayerButton.Size = UDim2.new(1, 0, 1, 0)
selectedPlayerButton.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
selectedPlayerButton.Text = ""
selectedPlayerButton.Font = Enum.Font.Gotham
selectedPlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayerButton.TextSize = 14
selectedPlayerButton.ZIndex = 11
selectedPlayerButton.Parent = playerDropdown

local spbCorner = Instance.new("UICorner")
spbCorner.CornerRadius = UDim.new(0, 6)
spbCorner.Parent = selectedPlayerButton

local selectedPlayerIcon = Instance.new("ImageLabel")
selectedPlayerIcon.Name = "SelectedPlayerIcon"
selectedPlayerIcon.Size = UDim2.new(0, 30, 0, 30)
selectedPlayerIcon.Position = UDim2.new(0, 5, 0.5, -15)
selectedPlayerIcon.BackgroundTransparency = 1
selectedPlayerIcon.ZIndex = 12
selectedPlayerIcon.Parent = selectedPlayerButton

local spiCorner = Instance.new("UICorner")
spiCorner.CornerRadius = UDim.new(0, 4)
spiCorner.Parent = selectedPlayerIcon

local selectedPlayerLabel = Instance.new("TextLabel")
selectedPlayerLabel.Name = "SelectedPlayerLabel"
selectedPlayerLabel.Size = UDim2.new(1, -40, 1, 0)
selectedPlayerLabel.Position = UDim2.new(0, 40, 0, 0)
selectedPlayerLabel.BackgroundTransparency = 1
selectedPlayerLabel.Font = Enum.Font.Gotham
selectedPlayerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayerLabel.TextSize = 14
selectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedPlayerLabel.ZIndex = 12
selectedPlayerLabel.Parent = selectedPlayerButton

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(1, 0, 0, 150)
dropdownList.Position = UDim2.new(0, 0, 1, 5)
dropdownList.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.ZIndex = 9
dropdownList.Parent = playerDropdown

local dlCorner = Instance.new("UICorner")
dlCorner.CornerRadius = UDim.new(0, 6)
dlCorner.Parent = dropdownList

local dlLayout = Instance.new("UIListLayout")
dlLayout.Padding = UDim.new(0, 5)
dlLayout.SortOrder = Enum.SortOrder.LayoutOrder
dlLayout.Parent = dropdownList

local playerTemplate = Instance.new("TextButton")
playerTemplate.Name = "PlayerTemplate"
playerTemplate.Size = UDim2.new(1, -10, 0, 40)
playerTemplate.Position = UDim2.new(0, 5, 0, 0)
playerTemplate.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
playerTemplate.Text = ""
playerTemplate.ZIndex = 11
playerTemplate.AutoButtonColor = false

local ptCorner = Instance.new("UICorner")
ptCorner.CornerRadius = UDim.new(0, 6)
ptCorner.Parent = playerTemplate

local ptIcon = Instance.new("ImageLabel")
ptIcon.Name = "Icon"
ptIcon.Size = UDim2.new(0, 30, 0, 30)
ptIcon.Position = UDim2.new(0, 5, 0.5, -15)
ptIcon.BackgroundTransparency = 1
ptIcon.ZIndex = 12
ptIcon.Parent = playerTemplate

local ptiCorner = Instance.new("UICorner")
ptiCorner.CornerRadius = UDim.new(0, 4)
ptiCorner.Parent = ptIcon

local ptLabel = Instance.new("TextLabel")
ptLabel.Name = "Label"
ptLabel.Size = UDim2.new(1, -40, 1, 0)
ptLabel.Position = UDim2.new(0, 40, 0, 0)
ptLabel.BackgroundTransparency = 1
ptLabel.Font = Enum.Font.Gotham
ptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ptLabel.TextSize = 14
ptLabel.TextXAlignment = Enum.TextXAlignment.Left
ptLabel.ZIndex = 12
ptLabel.Parent = playerTemplate

selectedPlayerButton.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)

local function populatePlayerList()
    for _, child in ipairs(dropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local playerEntry = playerTemplate:Clone()
        playerEntry.Parent = dropdownList
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size48x48
        local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        if isReady then
            playerEntry.Icon.Image = content
        end
        playerEntry.Label.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        playerEntry.MouseButton1Click:Connect(function()
            selectedUserId = player.UserId
            selectedPlayerIcon.Image = content
            selectedPlayerLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            dropdownList.Visible = false
            updateUI()
        end)
    end
    dropdownList.CanvasSize = UDim2.new(0,0,0, #dropdownList:GetChildren() * 45)
end

populatePlayerList()
Players.PlayerAdded:Connect(populatePlayerList)
Players.PlayerRemoving:Connect(populatePlayerList)

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size48x48
local content, isReady = Players:GetUserThumbnailAsync(localUserId, thumbType, thumbSize)
if isReady then
    selectedPlayerIcon.Image = content
end
selectedPlayerLabel.Text = localPlayer.DisplayName .. " (@" .. localPlayer.Name .. ")"

local totalLabel = Instance.new("TextLabel")
totalLabel.Name = "TotalLabel"
totalLabel.Size = UDim2.new(1, -20, 0, 20)
totalLabel.Position = UDim2.new(0, 10, 0, 90)
totalLabel.BackgroundTransparency = 1
totalLabel.Font = Enum.Font.Gotham
totalLabel.Text = "Total Brainrots on Base: 0"
totalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
totalLabel.TextSize = 16
totalLabel.ZIndex = 2
totalLabel.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "Items"
scrollingFrame.Size = UDim2.new(1, -10, 1, -120)
scrollingFrame.Position = UDim2.new(0, 5, 0, 115)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.ZIndex = 2
scrollingFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Name = "List"
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollingFrame

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end)

local templateFrame = Instance.new("Frame")
templateFrame.Name = "Template"
templateFrame.Size = UDim2.new(1, 0, 0, 120)
templateFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
templateFrame.BorderSizePixel = 0
templateFrame.ClipsDescendants = true
templateFrame.ZIndex = 3

local tfCorner = Instance.new("UICorner")
tfCorner.CornerRadius = UDim.new(0, 6)
tfCorner.Parent = templateFrame

local iconImage = Instance.new("ImageLabel")
iconImage.Name = "Icon"
iconImage.Size = UDim2.new(0, 90, 0, 90)
iconImage.Position = UDim2.new(0, 15, 0.5, -45)
iconImage.BackgroundTransparency = 1
iconImage.ZIndex = 4
iconImage.Parent = templateFrame

local iCorner = Instance.new("UICorner")
iCorner.CornerRadius = UDim.new(0, 4)
iCorner.Parent = iconImage

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "Name"
nameLabel.Size = UDim2.new(1, -125, 0, 40)
nameLabel.Position = UDim2.new(0, 115, 0, 10)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "Brainrot Name"
nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
nameLabel.TextSize = 16
nameLabel.TextWrapped = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextYAlignment = Enum.TextYAlignment.Top
nameLabel.ZIndex = 4
nameLabel.Parent = templateFrame

local detailsLabel = Instance.new("TextLabel")
detailsLabel.Name = "Details"
detailsLabel.Size = UDim2.new(1, -125, 1, -60)
detailsLabel.Position = UDim2.new(0, 115, 0, 50)
detailsLabel.BackgroundTransparency = 1
detailsLabel.Font = Enum.Font.Gotham
detailsLabel.Text = "Details placeholder"
detailsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
detailsLabel.TextSize = 14
detailsLabel.TextWrapped = true
detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
detailsLabel.TextYAlignment = Enum.TextYAlignment.Top
detailsLabel.ZIndex = 4
detailsLabel.Parent = templateFrame

local connections = {}

local function makeDraggable(guiObject)
    local dragging = false
    local dragStart = nil
    local startPosition = nil
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dropdownList.Visible then return end
            dragging = true
            dragStart = input.Position
            startPosition = mainFrame.Position
            local conn 
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            end
        end
    end)
end

makeDraggable(titleLabel)

function updateUI()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    local totalBrainrots = 0
    for _, model in ipairs(brainrotsFolder:GetChildren()) do
        if model:IsA("Model") then
            local associatedPlayerId = model:GetAttribute("AssociatedPlayer")
            if associatedPlayerId and associatedPlayerId == selectedUserId then
                totalBrainrots = totalBrainrots + 1
                local newItem = templateFrame:Clone()
                newItem.Name = model.Name
                newItem.Parent = scrollingFrame
                local itemName = model:GetAttribute("Brainrot") or model.Name
                newItem:FindFirstChild("Name").Text = tostring(itemName)
                local icon = newItem:FindFirstChild("Icon")
                local iconId = model:GetAttribute("Icon")
                if iconId and typeof(iconId) == "string" and iconId ~= "" then
                    icon.Image = iconId
                else
                    icon.Image = "rbxassetid://10688454374"
                end
                local existingGradient = icon:FindFirstChildOfClass("UIGradient")
                if existingGradient then
                    existingGradient:Destroy()
                end
                local mutation = model:GetAttribute("Mutation")
                if mutation and typeof(mutation) == "string" and mutation ~= "" then
                    local mutationGradientsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("MutationGradients")
                    local mutationGradient = mutationGradientsFolder:FindFirstChild(mutation)
                    if mutationGradient and mutationGradient:IsA("UIGradient") then
                        mutationGradient:Clone().Parent = icon
                    end
                end
                local detailsText = ""
                local attributes = model:GetAttributes()
                local sortedKeys = {}
                for key in pairs(attributes) do
                    table.insert(sortedKeys, key)
                end
                table.sort(sortedKeys)
                for _, key in ipairs(sortedKeys) do
                    detailsText ..= tostring(key) .. ": " .. tostring(attributes[key]) .. "\n"
                end
                local detailsLabel = newItem:FindFirstChild("Details")
                detailsLabel.Text = detailsText
                local textWidth = mainFrame.AbsoluteSize.X - 20 - 115
                local detailsSize = TextService:GetTextSize(detailsText, detailsLabel.TextSize, detailsLabel.Font, Vector2.new(textWidth, math.huge))
                local calculatedHeight = 50 + detailsSize.Y + 10
                local minimumHeight = 120
                newItem.Size = UDim2.new(1, 0, 0, math.max(calculatedHeight, minimumHeight))
            end
        end
    end
    totalLabel.Text = "Total Brainrots on Base: " .. tostring(totalBrainrots)
end

local function connectModelSignals(model)
    if not model:IsA("Model") then return end
    if connections[model] then
        for _, connection in ipairs(connections[model]) do
            connection:Disconnect()
        end
        connections[model] = nil
    end
    connections[model] = {}
    for attributeName, _ in pairs(model:GetAttributes()) do
        table.insert(connections[model], model:GetAttributeChangedSignal(attributeName):Connect(updateUI))
    end
end

for _, child in ipairs(brainrotsFolder:GetChildren()) do
    connectModelSignals(child)
end
updateUI()

brainrotsFolder.ChildAdded:Connect(function(child)
    task.wait(0.1)
    connectModelSignals(child)
    updateUI()
end)

brainrotsFolder.ChildRemoved:Connect(function(child)
    if connections[child] then
        for _, connection in ipairs(connections[child]) do
            connection:Disconnect()
        end
        connections[child] = nil
    end
    updateUI()
end)

screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
