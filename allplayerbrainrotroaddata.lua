local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

local connections = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotMonitorUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 550)
mainFrame.Position = UDim2.new(1, -380, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 29, 33)
mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 1
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(22, 23, 26)
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerShadow = Instance.new("UIStroke")
headerShadow.Color = Color3.fromRGB(18, 19, 22)
headerShadow.Thickness = 2
headerShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
headerShadow.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Brainrot Monitor"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
titleLabel.Parent = header

local function createHoverEffect(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = originalColor:Lerp(Color3.new(1, 1, 1), 0.1) }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = originalColor }):Play()
    end)
end

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 46, 50)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
closeButton.TextSize = 16
closeButton.ZIndex = 3
closeButton.Parent = header
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton
createHoverEffect(closeButton)
closeButton.MouseButton1Click:Connect(function() screenGui.Enabled = false end)

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2
contentFrame.Parent = mainFrame

local playerDropdown = Instance.new("Frame")
playerDropdown.Name = "PlayerDropdown"
playerDropdown.Size = UDim2.new(1, 0, 0, 40)
playerDropdown.Position = UDim2.new(0, 0, 0, 5)
playerDropdown.BackgroundColor3 = Color3.fromRGB(40, 42, 47)
playerDropdown.BorderSizePixel = 0
playerDropdown.ZIndex = 10
playerDropdown.ClipsDescendants = false
playerDropdown.Parent = contentFrame
local pdCorner = Instance.new("UICorner")
pdCorner.CornerRadius = UDim.new(0, 8)
pdCorner.Parent = playerDropdown
local pdStroke = Instance.new("UIStroke")
pdStroke.Color = Color3.fromRGB(60, 62, 67)
pdStroke.Thickness = 1
pdStroke.Parent = playerDropdown

local selectedPlayerButton = Instance.new("TextButton")
selectedPlayerButton.Name = "SelectedPlayerButton"
selectedPlayerButton.Size = UDim2.new(1, 0, 1, 0)
selectedPlayerButton.BackgroundColor3 = Color3.fromRGB(40, 42, 47)
selectedPlayerButton.Text = ""
selectedPlayerButton.ZIndex = 11
selectedPlayerButton.Parent = playerDropdown
local spbCorner = Instance.new("UICorner")
spbCorner.CornerRadius = UDim.new(0, 8)
spbCorner.Parent = selectedPlayerButton

local selectedPlayerIcon = Instance.new("ImageLabel")
selectedPlayerIcon.Name = "SelectedPlayerIcon"
selectedPlayerIcon.Size = UDim2.new(0, 28, 0, 28)
selectedPlayerIcon.Position = UDim2.new(0, 6, 0.5, -14)
selectedPlayerIcon.BackgroundTransparency = 1
selectedPlayerIcon.ZIndex = 12
selectedPlayerIcon.Parent = selectedPlayerButton
local spiCorner = Instance.new("UICorner")
spiCorner.CornerRadius = UDim.new(1, 0)
spiCorner.Parent = selectedPlayerIcon

local selectedPlayerLabel = Instance.new("TextLabel")
selectedPlayerLabel.Name = "SelectedPlayerLabel"
selectedPlayerLabel.Size = UDim2.new(1, -45, 1, 0)
selectedPlayerLabel.Position = UDim2.new(0, 40, 0, 0)
selectedPlayerLabel.BackgroundTransparency = 1
selectedPlayerLabel.Font = Enum.Font.Gotham
selectedPlayerLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
selectedPlayerLabel.TextSize = 14
selectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedPlayerLabel.ZIndex = 12
selectedPlayerLabel.Parent = selectedPlayerButton

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(1, 0, 0, 150)
dropdownList.Position = UDim2.new(0, 0, 1, 5)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 42, 47)
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.ZIndex = 9
dropdownList.ScrollBarThickness = 5
dropdownList.Parent = playerDropdown
local dlCorner = Instance.new("UICorner")
dlCorner.CornerRadius = UDim.new(0, 8)
dlCorner.Parent = dropdownList
local dlStroke = Instance.new("UIStroke")
dlStroke.Color = Color3.fromRGB(60, 62, 67)
dlStroke.Thickness = 1
dlStroke.Parent = dropdownList
local dlLayout = Instance.new("UIListLayout")
dlLayout.Padding = UDim.new(0, 2)
dlLayout.SortOrder = Enum.SortOrder.LayoutOrder
dlLayout.Parent = dropdownList
local dlUIPadding = Instance.new("UIPadding")
dlUIPadding.PaddingTop = UDim.new(0, 4)
dlUIPadding.PaddingBottom = UDim.new(0, 4)
dlUIPadding.Parent = dropdownList

local playerTemplate = Instance.new("TextButton")
playerTemplate.Name = "PlayerTemplate"
playerTemplate.Size = UDim2.new(1, -8, 0, 40)
playerTemplate.Position = UDim2.new(0, 4, 0, 0)
playerTemplate.BackgroundColor3 = Color3.fromRGB(50, 52, 57)
playerTemplate.Text = ""
playerTemplate.ZIndex = 11
playerTemplate.AutoButtonColor = false
local ptCorner = Instance.new("UICorner")
ptCorner.CornerRadius = UDim.new(0, 6)
ptCorner.Parent = playerTemplate
local ptIcon = Instance.new("ImageLabel")
ptIcon.Name = "Icon"
ptIcon.Size = UDim2.new(0, 28, 0, 28)
ptIcon.Position = UDim2.new(0, 6, 0.5, -14)
ptIcon.BackgroundTransparency = 1
ptIcon.ZIndex = 12
ptIcon.Parent = playerTemplate
local ptiCorner = Instance.new("UICorner")
ptiCorner.CornerRadius = UDim.new(1, 0)
ptiCorner.Parent = ptIcon
local ptLabel = Instance.new("TextLabel")
ptLabel.Name = "Label"
ptLabel.Size = UDim2.new(1, -45, 1, 0)
ptLabel.Position = UDim2.new(0, 40, 0, 0)
ptLabel.BackgroundTransparency = 1
ptLabel.Font = Enum.Font.Gotham
ptLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
ptLabel.TextSize = 14
ptLabel.TextXAlignment = Enum.TextXAlignment.Left
ptLabel.ZIndex = 12
ptLabel.Parent = playerTemplate
createHoverEffect(playerTemplate)

local searchBarContainer = Instance.new("Frame")
searchBarContainer.Name = "SearchBarContainer"
searchBarContainer.Size = UDim2.new(1, 0, 0, 35)
searchBarContainer.Position = UDim2.new(0, 0, 0, 55)
searchBarContainer.BackgroundTransparency = 1
searchBarContainer.Parent = contentFrame

local searchBar = Instance.new("TextBox")
searchBar.Name = "SearchBar"
searchBar.Size = UDim2.new(1, 0, 1, 0)
searchBar.BackgroundColor3 = Color3.fromRGB(40, 42, 47)
searchBar.Font = Enum.Font.Gotham
searchBar.Text = ""
searchBar.PlaceholderText = "Search brainrots..."
searchBar.TextColor3 = Color3.fromRGB(220, 221, 222)
searchBar.PlaceholderColor3 = Color3.fromRGB(114, 118, 125)
searchBar.TextSize = 14
searchBar.ClearTextOnFocus = false
searchBar.ZIndex = 2
searchBar.Parent = searchBarContainer
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = searchBar
local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Color3.fromRGB(60, 62, 67)
sbStroke.Thickness = 1
sbStroke.Parent = searchBar
local sbPadding = Instance.new("UIPadding")
sbPadding.PaddingLeft = UDim.new(0, 10)
sbPadding.Parent = searchBar

local totalLabel = Instance.new("TextLabel")
totalLabel.Name = "TotalLabel"
totalLabel.Size = UDim2.new(1, 0, 0, 20)
totalLabel.Position = UDim2.new(0, 0, 0, 95)
totalLabel.BackgroundTransparency = 1
totalLabel.Font = Enum.Font.Gotham
totalLabel.Text = "Total Brainrots: 0"
totalLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
totalLabel.TextSize = 14
totalLabel.TextXAlignment = Enum.TextXAlignment.Left
totalLabel.ZIndex = 2
totalLabel.Parent = contentFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "Items"
scrollingFrame.Size = UDim2.new(1, 0, 1, -120)
scrollingFrame.Position = UDim2.new(0, 0, 0, 120)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.ZIndex = 2
scrollingFrame.Parent = contentFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Name = "List"
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollingFrame
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y) end)

local templateButton = Instance.new("TextButton")
templateButton.Name = "Template"
templateButton.Size = UDim2.new(1, 0, 0, 50)
templateButton.BackgroundColor3 = Color3.fromRGB(40, 42, 47)
templateButton.ClipsDescendants = true
templateButton.ZIndex = 3
templateButton.Text = ""
templateButton.AutoButtonColor = false
local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 8)
tbCorner.Parent = templateButton
local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Color3.fromRGB(60, 62, 67)
tbStroke.Thickness = 1
tbStroke.Parent = templateButton
local iconImage = Instance.new("ImageLabel")
iconImage.Name = "Icon"
iconImage.Size = UDim2.new(0, 40, 0, 40)
iconImage.Position = UDim2.new(0, 5, 0, 5)
iconImage.BackgroundTransparency = 1
iconImage.ZIndex = 4
iconImage.Parent = templateButton
local iCorner = Instance.new("UICorner")
iCorner.CornerRadius = UDim.new(0, 6)
iCorner.Parent = iconImage
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "Name"
nameLabel.Size = UDim2.new(1, -90, 0, 50)
nameLabel.Position = UDim2.new(0, 55, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "Brainrot Name"
nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
nameLabel.TextSize = 16
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextYAlignment = Enum.TextYAlignment.Center
nameLabel.ZIndex = 4
nameLabel.Parent = templateButton
local detailsLabel = Instance.new("TextLabel")
detailsLabel.Name = "Details"
detailsLabel.Size = UDim2.new(1, -20, 1, -60)
detailsLabel.Position = UDim2.new(0, 10, 0, 50)
detailsLabel.BackgroundTransparency = 1
detailsLabel.Font = Enum.Font.Gotham
detailsLabel.Text = ""
detailsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
detailsLabel.TextSize = 14
detailsLabel.TextWrapped = true
detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
detailsLabel.TextYAlignment = Enum.TextYAlignment.Top
detailsLabel.ZIndex = 4
detailsLabel.Visible = false
detailsLabel.Parent = templateButton
local arrowLabel = Instance.new("TextLabel")
arrowLabel.Name = "Arrow"
arrowLabel.Size = UDim2.new(0, 24, 0, 24)
arrowLabel.Position = UDim2.new(1, -34, 0.5, -12)
arrowLabel.BackgroundTransparency = 1
arrowLabel.Text = "▼"
arrowLabel.Font = Enum.Font.GothamBold
arrowLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
arrowLabel.TextSize = 20
arrowLabel.ZIndex = 5
arrowLabel.Parent = templateButton

function updateUI()
    local expandedItems = {}
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            if child:GetAttribute("Expanded") then
                expandedItems[child.Name] = true
            end
            child:Destroy()
        end
    end

    local totalBrainrots = 0
    local searchText = searchBar.Text:lower()

    for _, model in ipairs(brainrotsFolder:GetChildren()) do
        if model:IsA("Model") then
            local associatedPlayerId = model:GetAttribute("AssociatedPlayer")
            local itemName = model:GetAttribute("Brainrot") or model.Name

            if associatedPlayerId and associatedPlayerId == selectedUserId and (searchText == "" or itemName:lower():find(searchText, 1, true)) then
                totalBrainrots = totalBrainrots + 1
                local newItem = templateButton:Clone()
                newItem.Name = model.Name
                newItem.Parent = scrollingFrame

                local name = newItem:FindFirstChild("Name")
                local icon = newItem:FindFirstChild("Icon")
                local details = newItem:FindFirstChild("Details")
                local arrow = newItem:FindFirstChild("Arrow")

                name.Text = tostring(itemName)
                local iconId = model:GetAttribute("Icon")
                if iconId and typeof(iconId) == "string" and iconId ~= "" then
                    icon.Image = iconId
                else
                    icon.Image = "rbxassetid://10688454374"
                end

                local existingGradient = icon:FindFirstChildOfClass("UIGradient")
                if existingGradient then existingGradient:Destroy() end

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
                for key in pairs(attributes) do table.insert(sortedKeys, key) end
                table.sort(sortedKeys)
                for _, key in ipairs(sortedKeys) do
                    detailsText ..= tostring(key) .. ": " .. tostring(attributes[key]) .. "\n"
                end
                details.Text = detailsText

                local textWidth = mainFrame.AbsoluteSize.X - 40
                local detailsSize = TextService:GetTextSize(detailsText, details.TextSize, details.Font, Vector2.new(textWidth, math.huge))
                local expandedHeight = 60 + detailsSize.Y
                newItem:SetAttribute("ExpandedHeight", expandedHeight)
                
                if expandedItems[model.Name] then
                    newItem:SetAttribute("Expanded", true)
                    newItem.Size = UDim2.new(1,0,0,expandedHeight)
                    details.Visible = true
                    arrow.Text = "▲"
                end

                newItem.MouseButton1Click:Connect(function()
                    local isExpanded = newItem:GetAttribute("Expanded") or false
                    local targetHeight = isExpanded and 50 or newItem:GetAttribute("ExpandedHeight")
                    
                    newItem:SetAttribute("Expanded", not isExpanded)
                    arrow.Text = isExpanded and "▼" or "▲"

                    TweenService:Create(newItem, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.new(1, 0, 0, targetHeight) }):Play()

                    if not isExpanded then
                        details.Visible = true
                    else
                        task.delay(0.3, function()
                            if not (newItem:GetAttribute("Expanded") or false) then
                                details.Visible = false
                            end
                        end)
                    end
                end)
            end
        end
    end
    totalLabel.Text = "Total Brainrots: " .. tostring(totalBrainrots)
end

local function makeDraggable(guiObject)
    local dragging = false
    local dragStart, startPosition
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dropdownList.Visible then return end
            dragging = true
            dragStart = input.Position
            startPosition = mainFrame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging, conn = false, conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
end

local function populatePlayerList()
    for _, child in ipairs(dropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local playerEntry = playerTemplate:Clone()
        playerEntry.Parent = dropdownList
        local thumbType, thumbSize = Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48
        local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        if isReady then playerEntry.Icon.Image = content end
        playerEntry.Label.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        playerEntry.MouseButton1Click:Connect(function()
            selectedUserId = player.UserId
            if isReady then selectedPlayerIcon.Image = content end
            selectedPlayerLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            dropdownList.Visible = false
            updateUI()
        end)
    end
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, (#dropdownList:GetChildren() * 42) + 8)
end

local function connectModelSignals(model)
    if not model:IsA("Model") then return end
    if connections[model] then
        for _, connection in ipairs(connections[model]) do connection:Disconnect() end
        connections[model] = nil
    end
    connections[model] = {}
    for attributeName, _ in pairs(model:GetAttributes()) do
        table.insert(connections[model], model:GetAttributeChangedSignal(attributeName):Connect(updateUI))
    end
end

makeDraggable(header)
populatePlayerList()
Players.PlayerAdded:Connect(populatePlayerList)
Players.PlayerRemoving:Connect(populatePlayerList)
selectedPlayerButton.MouseButton1Click:Connect(function() dropdownList.Visible = not dropdownList.Visible end)

local thumbType, thumbSize = Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48
local content, isReady = Players:GetUserThumbnailAsync(localUserId, thumbType, thumbSize)
if isReady then selectedPlayerIcon.Image = content end
selectedPlayerLabel.Text = localPlayer.DisplayName .. " (@" .. localPlayer.Name .. ")"

searchBar:GetPropertyChangedSignal("Text"):Connect(updateUI)

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
        for _, connection in ipairs(connections[child]) do connection:Disconnect() end
        connections[child] = nil
    end
    updateUI()
end)

screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
