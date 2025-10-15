local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local equipRemote = remotesFolder:FindFirstChild("EquipBestBrainrots") or remotesFolder:FindFirstChild("EquipBest")

local function getPlayerPlot()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        if plot:GetAttribute("Owner") == localPlayer.Name then
            return plot
        end
    end
    return nil
end

while task.wait(10) do
    local playerPlot = getPlayerPlot()
    if not playerPlot then continue end

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
end
