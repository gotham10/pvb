local player = game:GetService("Players").LocalPlayer
local localPlayerName = player.Name
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local plotsFolder = Workspace:FindFirstChild("Plots")
local playersService = game:GetService("Players")
local assetsFolder = replicatedStorage:WaitForChild("Assets")
local rarityGradientsFolder = assetsFolder:WaitForChild("Gradients")
local mutationGradientsFolder = assetsFolder:WaitForChild("MutationGradients")

local allowedAttributes = {
	Title = true,
	Damage = true,
	Damage_Original = true,
	Icon = true,
	Mutation = true,
	Rarity = true,
	Row = true,
	Size = true
}

local highlightedParts = {}
local hiddenPlayers = {}
local currentPlayerData = {}

local function formatWithCommas(number)
	local numStr = tostring(math.floor(number))
	local reversed = string.reverse(numStr)
	local formatted = string.gsub(reversed, "(%d%d%d)", "%1,")
	local final = string.reverse(formatted)
	if string.sub(final, 1, 1) == "," then
		final = string.sub(final, 2)
	end
	return final
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlantViewer"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 332, 0, 450)
mainFrame.Position = UDim2.new(1, -342, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 80, 90)
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.LineJoinMode = Enum.LineJoinMode.Round
mainStroke.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = mainFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new(Color3.fromRGB(55, 55, 65), Color3.fromRGB(40, 40, 50))
titleGradient.Rotation = 90
titleGradient.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -140, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.Text = "Plant Inspector"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Parent = titleBar

local totalLabel = Instance.new("TextLabel")
totalLabel.Name = "TotalLabel"
totalLabel.Size = UDim2.new(0, 70, 1, 0)
totalLabel.Position = UDim2.new(1, -140, 0, 0)
totalLabel.BackgroundTransparency = 1
totalLabel.Font = Enum.Font.GothamSemibold
totalLabel.Text = "Total: 0"
totalLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
totalLabel.TextSize = 16
totalLabel.TextXAlignment = Enum.TextXAlignment.Right
totalLabel.Parent = titleBar

local filterButton = Instance.new("TextButton")
filterButton.Name = "FilterButton"
filterButton.Size = UDim2.new(0, 30, 0, 22)
filterButton.Position = UDim2.new(1, -65, 0, 4)
filterButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
filterButton.Font = Enum.Font.GothamBold
filterButton.Text = "..."
filterButton.TextColor3 = Color3.fromRGB(220, 220, 220)
filterButton.TextSize = 18
filterButton.ZIndex = 3
filterButton.Parent = titleBar

local filterCorner = Instance.new("UICorner")
filterCorner.CornerRadius = UDim.new(0, 6)
filterCorner.Parent = filterButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0
closeButton.ZIndex = 3
closeButton.Parent = titleBar

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.new(1, 0, 1, -30)
scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.ClipsDescendants = true
scrollingFrame.ZIndex = 1
scrollingFrame.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.Name = "GridLayout"
gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
gridLayout.CellSize = UDim2.new(0, 100, 0, 160)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.Parent = scrollingFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 6)
padding.PaddingRight = UDim.new(0, 6)
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.Parent = scrollingFrame

local filterFrame = Instance.new("ScrollingFrame")
filterFrame.Name = "FilterFrame"
filterFrame.Size = UDim2.new(0, 150, 0, 200)
filterFrame.Position = UDim2.new(1, -185, 0, 34)
filterFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
filterFrame.BorderColor3 = Color3.fromRGB(80, 80, 90)
filterFrame.BorderSizePixel = 1
filterFrame.ZIndex = 4
filterFrame.Visible = false
filterFrame.ScrollBarThickness = 6
filterFrame.Parent = mainFrame

local filterFrameCorner = Instance.new("UICorner")
filterFrameCorner.CornerRadius = UDim.new(0, 6)
filterFrameCorner.Parent = filterFrame

local filterListLayout = Instance.new("UIListLayout")
filterListLayout.SortOrder = Enum.SortOrder.Name
filterListLayout.Padding = UDim.new(0, 4)
filterListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
filterListLayout.Parent = filterFrame

local filterListPadding = Instance.new("UIPadding")
filterListPadding.PaddingLeft = UDim.new(0, 4)
filterListPadding.PaddingRight = UDim.new(0, 4)
filterListPadding.PaddingTop = UDim.new(0, 4)
filterListPadding.PaddingBottom = UDim.new(0, 4)
filterListPadding.Parent = filterFrame

local function toggleHighlight(model, button)
	if highlightedParts[model] then
		highlightedParts[model].billboardGui:Destroy()
		highlightedParts[model].selectionBox:Destroy()
		highlightedParts[model] = nil
		button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	else
		local partToAdorn = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model
		if not partToAdorn then return end

		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Adornee = partToAdorn
		selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
		selectionBox.LineThickness = 0.1
		selectionBox.Parent = mainFrame
		
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = partToAdorn
		billboardGui.AlwaysOnTop = true
		billboardGui.Size = UDim2.new(0, 200, 0, 50)
		billboardGui.StudsOffset = Vector3.new(0, 2, 0)
		billboardGui.Parent = mainFrame
		
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Text = "..."
		textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Parent = billboardGui
		
		highlightedParts[model] = {billboardGui = billboardGui, selectionBox = selectionBox, textLabel = textLabel}
		button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
end

local function createPlantCard(plantInfo, ownerName)
	local card = Instance.new("Frame")
	card.Name = "PlantCard"
	card.Size = UDim2.new(0, 100, 0, 160)
	card.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	card.LayoutOrder = plantInfo.Damage and -plantInfo.Damage or 0
	card.BorderSizePixel = 0
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 6)
	cardCorner.Parent = card
	
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(1, -10, 0, 80)
	icon.Position = UDim2.new(0, 5, 0, 5)
	icon.BackgroundTransparency = 1
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Image = plantInfo.Icon or ""
	icon.ClipsDescendants = true
	icon.Parent = card
	
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = 1
	aspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
	aspectRatio.DominantAxis = Enum.DominantAxis.Width
	aspectRatio.Parent = icon
	
	if plantInfo.Mutation then
		local mutationGradient = mutationGradientsFolder:FindFirstChild(plantInfo.Mutation)
		if mutationGradient and mutationGradient:IsA("UIGradient") then
			mutationGradient:Clone().Parent = icon
		end
	end
	
	local findButton = Instance.new("ImageButton")
	findButton.Name = "FindButton"
	findButton.Size = UDim2.new(0, 25, 0, 25)
	findButton.Position = UDim2.new(1, -30, 0, 5)
	findButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	findButton.Image = "rbxassetid://6034819080"
	findButton.ImageColor3 = Color3.fromRGB(220, 220, 220)
	findButton.ScaleType = Enum.ScaleType.Fit
	findButton.ZIndex = 2
	findButton.Parent = card
	
	if highlightedParts[plantInfo.Model] then
		findButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end

	local findCorner = Instance.new("UICorner")
	findCorner.CornerRadius = UDim.new(0, 6)
	findCorner.Parent = findButton
	
	findButton.MouseButton1Click:Connect(function()
		toggleHighlight(plantInfo.Model, findButton)
	end)
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -10, 0, 16)
	nameLabel.Position = UDim2.new(0, 5, 0, 90)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.Text = plantInfo.Name or "Unknown"
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ClipsDescendants = true
	nameLabel.Parent = card
	
	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Name = "OwnerLabel"
	ownerLabel.Size = UDim2.new(1, -10, 0, 14)
	ownerLabel.Position = UDim2.new(0, 5, 0, 108)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.Font = Enum.Font.Gotham
	ownerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	ownerLabel.TextSize = 12
	ownerLabel.TextXAlignment = Enum.TextXAlignment.Left
	ownerLabel.ClipsDescendants = true
	ownerLabel.Parent = card

	local ownerPlayer = playersService:FindFirstChild(ownerName)
	if ownerPlayer then
		ownerLabel.Text = ownerPlayer.DisplayName .. " (@" .. ownerPlayer.Name .. ")"
	else
		ownerLabel.Text = ownerName .. " (@" .. ownerName .. ")"
	end
	
	local damageLabel = Instance.new("TextLabel")
	damageLabel.Name = "DamageLabel"
	damageLabel.Size = UDim2.new(1, -10, 0, 14)
	damageLabel.Position = UDim2.new(0, 5, 0, 124)
	damageLabel.BackgroundTransparency = 1
	damageLabel.Font = Enum.Font.Gotham
	damageLabel.Text = "DMG: " .. formatWithCommas(plantInfo.Damage or 0)
	damageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	damageLabel.TextSize = 13
	damageLabel.TextXAlignment = Enum.TextXAlignment.Left
	damageLabel.Parent = card
	
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Size = UDim2.new(0.5, 0, 0, 12)
	rarityLabel.Position = UDim2.new(0, 5, 0, 142)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.GothamSemibold
	rarityLabel.Text = plantInfo.Rarity or "N/A"
	rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	rarityLabel.TextSize = 12
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent = card
	
	if plantInfo.Rarity then
		local rarityGradient = rarityGradientsFolder:FindFirstChild(plantInfo.Rarity)
		if rarityGradient and rarityGradient:IsA("UIGradient") then
			rarityGradient:Clone().Parent = rarityLabel
		end
	end
	
	local mutationLabel = Instance.new("TextLabel")
	mutationLabel.Name = "MutationLabel"
	mutationLabel.Size = UDim2.new(0.5, -5, 0, 12)
	mutationLabel.Position = UDim2.new(0.5, 0, 0, 142)
	mutationLabel.BackgroundTransparency = 1
	mutationLabel.Font = Enum.Font.Gotham
	mutationLabel.Text = plantInfo.Mutation or ""
	mutationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	mutationLabel.TextSize = 12
	mutationLabel.Visible = plantInfo.Mutation ~= nil
	mutationLabel.TextXAlignment = Enum.TextXAlignment.Left
	mutationLabel.Parent = card

	if plantInfo.Mutation then
		local mutationGradient = mutationGradientsFolder:FindFirstChild(plantInfo.Mutation)
		if mutationGradient and mutationGradient:IsA("UIGradient") then
			mutationGradient:Clone().Parent = mutationLabel
		end
	end

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Thickness = 2
	cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	cardStroke.LineJoinMode = Enum.LineJoinMode.Round
	cardStroke.Parent = card

	local gradientToClone = nil
	if plantInfo.Mutation then
		gradientToClone = mutationGradientsFolder:FindFirstChild(plantInfo.Mutation)
	end
	
	if not gradientToClone and plantInfo.Rarity then
		gradientToClone = rarityGradientsFolder:FindFirstChild(plantInfo.Rarity)
	end
	
	if gradientToClone and gradientToClone:IsA("UIGradient") then
		gradientToClone:Clone().Parent = cardStroke
	else
		cardStroke.Color = Color3.fromRGB(60, 60, 70)
	end
	
	return card
end

local function updateUI(playerData)
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local playerNames = {}
	for name in pairs(playerData) do
		table.insert(playerNames, name)
	end
	table.sort(playerNames)
	
	local totalCount = 0
	
	for _, playerName in ipairs(playerNames) do
		if playerName == localPlayerName or hiddenPlayers[playerName] then
			continue
		end
		
		local plants = playerData[playerName]
		for _, plantInfo in ipairs(plants) do
			local damage = plantInfo.Damage or 0
			local damageOriginal = plantInfo.Damage_Original or 0
			if damage >= 100000 or damageOriginal >= 100000 then
				totalCount = totalCount + 1
				local card = createPlantCard(plantInfo, playerName)
				card.Parent = scrollingFrame
			end
		end
	end
	
	if titleBar and titleBar:FindFirstChild("TotalLabel") then
		titleBar.TotalLabel.Text = "Total: " .. totalCount
	end
	
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y)
end

local function populateFilterFrame()
	for _, child in ipairs(filterFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local playerNames = {}
	for name in pairs(currentPlayerData) do
		if name ~= localPlayerName then
			table.insert(playerNames, name)
		end
	end
	table.sort(playerNames)
	
	for _, playerName in ipairs(playerNames) do
		local playerButton = Instance.new("TextButton")
		playerButton.Name = playerName
		playerButton.Size = UDim2.new(1, 0, 0, 25)
		playerButton.Font = Enum.Font.Gotham
		
		local ownerPlayer = playersService:FindFirstChild(playerName)
		if ownerPlayer then
			playerButton.Text = ownerPlayer.DisplayName .. " (@" .. ownerPlayer.Name .. ")"
		else
			playerButton.Text = playerName .. " (@" .. playerName .. ")"
		end
		
		playerButton.TextSize = 14
		playerButton.ClipsDescendants = true
		playerButton.Parent = filterFrame
		
		if hiddenPlayers[playerName] then
			playerButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			playerButton.TextColor3 = Color3.fromRGB(220, 220, 220)
		else
			playerButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			playerButton.TextColor3 = Color3.fromRGB(30, 30, 30)
		end
		
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 4)
		buttonCorner.Parent = playerButton
		
		playerButton.MouseButton1Click:Connect(function()
			hiddenPlayers[playerName] = not hiddenPlayers[playerName]
			updateUI(currentPlayerData)
			populateFilterFrame()
		end)
	end
end

filterButton.MouseButton1Click:Connect(function()
	filterFrame.Visible = not filterFrame.Visible
	if filterFrame.Visible then
		populateFilterFrame()
	end
end)

local function runScan()
	local newData = {}
	if not plotsFolder then
		plotsFolder = Workspace:FindFirstChild("Plots")
		if not plotsFolder then
			warn("Plots folder not found.")
			return
		end
	end
	
	for i = 1, 5 do
		local plot = plotsFolder:FindFirstChild(tostring(i))
		if plot then
			local plantsFolder = plot:FindFirstChild("Plants")
			if plantsFolder then
				for _, model in ipairs(plantsFolder:GetChildren()) do
					if model:IsA("Model") then
						local ownerName = model:GetAttribute("Owner")
						if ownerName and typeof(ownerName) == "string" then
							if not newData[ownerName] then
								newData[ownerName] = {}
							end
							
							local plantInfo = {}
							plantInfo.Name = model.Name
							plantInfo.Model = model
							
							for attrName, _ in pairs(allowedAttributes) do
								local attrValue = model:GetAttribute(attrName)
								if attrValue ~= nil then
									plantInfo[attrName] = attrValue
								end
							end
							
							table.insert(newData[ownerName], plantInfo)
						end
					end
				end
			end
		end
	end
	
	currentPlayerData = newData
	if screenGui and screenGui.Parent then
		updateUI(currentPlayerData)
	end
end

local dragging = false
local dragStart = Vector2.new()
local startPos = UDim2.new()

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if filterFrame.Visible and not filterFrame:IsAncestorOf(input.UserInputObject) and input.UserInputObject ~= filterButton then
			filterFrame.Visible = false
		end
		
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local updateConnection
updateConnection = runService.Heartbeat:Connect(function()
	if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
		return
	end
	
	local hrpPos = player.Character.HumanoidRootPart.Position
	
	for model, parts in pairs(highlightedParts) do
		local partToAdorn = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model
		if not model or not partToAdorn or not model:IsDescendantOf(Workspace) then
			parts.billboardGui:Destroy()
			parts.selectionBox:Destroy()
			highlightedParts[model] = nil
		else
			local distance = (hrpPos - partToAdorn.Position).Magnitude
			parts.textLabel.Text = string.format("%.1f studs", distance)
			parts.billboardGui.Adornee = partToAdorn
			parts.selectionBox.Adornee = partToAdorn
		end
	end
end)

closeButton.MouseButton1Click:Connect(function()
	if updateConnection then
		updateConnection:Disconnect()
		updateConnection = nil
	end
	for _, parts in pairs(highlightedParts) do
		parts.billboardGui:Destroy()
		parts.selectionBox:Destroy()
	end
	highlightedParts = {}
	screenGui:Destroy()
end)

playersService.PlayerAdded:Connect(function(playerWhoJoined)
	runScan()
	if filterFrame.Visible then
		populateFilterFrame()
	end
end)

playersService.PlayerRemoving:Connect(function(playerWhoLeft)
	local leftPlayerName = playerWhoLeft.Name
	if hiddenPlayers[leftPlayerName] then
		hiddenPlayers[leftPlayerName] = nil
	end
	
	updateUI(currentPlayerData)
	
	if filterFrame.Visible then
		populateFilterFrame()
	end
end)

task.spawn(function()
	while screenGui and screenGui.Parent do
		runScan()
		task.wait(5)
	end
end)
