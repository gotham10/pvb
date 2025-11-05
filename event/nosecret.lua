local Players = game:GetService("Players")
local player = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local autoSellRemote = replicatedStorage.Remotes.AutoSell
local brainrotsFolder = workspace:WaitForChild("ScriptedMap"):WaitForChild("MissionBrainrots")
local plotsFolder = workspace:WaitForChild("Plots")
local secretButton = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("AutoSell"):WaitForChild("Frame"):WaitForChild("Secret"):WaitForChild("TextButton")
local selectedGradient = secretButton:WaitForChild("selected")
local unselectedGradient = secretButton:WaitForChild("unselected")

local function toggleSecret()
	autoSellRemote:FireServer("Secret")
end

local function checkBrainrots()
	for _, model in ipairs(brainrotsFolder:GetChildren()) do
		if model:GetAttribute("Brainrot") == "Hacktini Adminini" then
			local plotNumber = model:GetAttribute("Plot")
			if plotNumber then
				local plotFolder = plotsFolder:FindFirstChild(tostring(plotNumber))
				if plotFolder and plotFolder:GetAttribute("Owner") == player.Name then
					if not unselectedGradient.Enabled then
						toggleSecret()
					end
					return
				end
			end
		end
	end
	if not selectedGradient.Enabled then
		toggleSecret()
	end
end

brainrotsFolder.ChildAdded:Connect(checkBrainrots)
brainrotsFolder.ChildRemoved:Connect(checkBrainrots)
for _, model in ipairs(brainrotsFolder:GetChildren()) do
	model:GetAttributeChangedSignal("Brainrot"):Connect(checkBrainrots)
	model:GetAttributeChangedSignal("Plot"):Connect(checkBrainrots)
end
checkBrainrots()
