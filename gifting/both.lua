local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MyRootPart = Character:WaitForChild("HumanoidRootPart")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local giftItemRemote = Remotes:WaitForChild("GiftItem")
local acceptGiftRemote = Remotes:WaitForChild("AcceptGift")

local function findClosestPlayer()
	local closestPlayer = nil
	local minDistance = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local playerCharacter = player.Character
			if playerCharacter then
				local playerRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
				if MyRootPart and playerRootPart then
					local distance = (MyRootPart.Position - playerRootPart.Position).Magnitude
					if distance < minDistance then
						minDistance = distance
						closestPlayer = player
					end
				end
			end
		end
	end
	return closestPlayer
end

Character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		task.spawn(function()
			while child.Parent == Character do
				local targetPlayer = findClosestPlayer()
				if targetPlayer then
					giftItemRemote:FireServer({
						ToGift = targetPlayer.Name,
						Item = child
					})
					task.wait(5.1)
				else
					task.wait(0.5)
				end
			end
		end)
	end
end)

giftItemRemote.OnClientEvent:Connect(function(giftPayload)
	if giftPayload and type(giftPayload) == "table" and giftPayload.ID then
		acceptGiftRemote:FireServer({
			ID = giftPayload.ID
		})
	end
end)
