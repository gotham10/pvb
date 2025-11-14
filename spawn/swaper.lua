local chosenRot = "67"

local rs = game:GetService("ReplicatedStorage")
local ppl = game:GetService("Players")
local me = ppl.LocalPlayer

rs.Remotes.SelectiveAssetService.RequestAsset:FireServer("Brainrots", chosenRot)

local guiStuff = me.PlayerGui:WaitForChild("AssetReplicator")
local rotFolder = guiStuff:WaitForChild("Brainrots")

local grabbed = rotFolder:WaitForChild(chosenRot)

local ac = grabbed:FindFirstChildOfClass("AnimationController") or grabbed:FindFirstChild("AnimationController")

local assetDump = rs.Assets
local prev = assetDump:FindFirstChild("Alessio")
if prev then prev:Destroy() end

grabbed.Parent = assetDump
grabbed.Name = "Alessio"

if ac and not ac:FindFirstChildOfClass("Animator") then
	local a = Instance.new("Animator")
	a.Parent = ac
end

local anims = rs.Assets.Animations.Brainrots
local srcAnimFolder = anims:FindFirstChild(chosenRot)
local dstAnimFolder = anims:FindFirstChild("Alessio")

if srcAnimFolder and dstAnimFolder then
	local srcWalk = srcAnimFolder:FindFirstChild("Walk")
	local srcIdle = srcAnimFolder:FindFirstChild("Idle")
	local dstWalk = dstAnimFolder:FindFirstChild("Walk")
	local dstIdle = dstAnimFolder:FindFirstChild("Idle")

	if srcWalk and dstWalk then
		dstWalk.AnimationId = srcWalk.AnimationId
	end

	if srcIdle and dstIdle then
		dstIdle.AnimationId = srcIdle.AnimationId
	end
end

task.spawn(function()
	while true do
		for _, thing in ipairs(rotFolder:GetChildren()) do
			if thing:IsA("Model") then
				thing:Destroy()
			end
		end
		task.wait()
	end
end)
