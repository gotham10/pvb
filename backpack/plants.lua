local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function analyzeBackpackPlants()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	
	local backpack = player:WaitForChild("Backpack")
	local plantCounts = {}

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("Plant") ~= nil then
			local plantName = tool.Name
			plantCounts[plantName] = (plantCounts[plantName] or 0) + 1
		end
	end

	local finalReport = HttpService:JSONEncode(plantCounts)
	print(finalReport)
	setclipboard(finalReport)
end

pcall(analyzeBackpackPlants)
