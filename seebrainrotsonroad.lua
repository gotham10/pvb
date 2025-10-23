local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local plotLightPositions = {
    ["1"] = Vector3.new(74, 9, 536),
    ["2"] = Vector3.new(-28, 9, 536),
    ["3"] = Vector3.new(-128, 9, 536),
    ["4"] = Vector3.new(-229, 9, 536),
    ["5"] = Vector3.new(-331, 9, 536)
}

local localPlayer = Players.LocalPlayer
if not localPlayer then
    return
end

local plotsFolder = Workspace:FindFirstChild("Plots")
if not plotsFolder then
    return
end

local function deleteUnions(instance)
    if instance:IsA("UnionOperation") then
        instance:Destroy()
        return
    end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("UnionOperation") then
            descendant:Destroy()
        end
    end
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
    if plot:IsA("Folder") then
        local owner = plot:GetAttribute("Owner")
        
        if owner and owner == localPlayer.Name then
            local lightPos = plotLightPositions[plot.Name]
            local lightPartName = "PlotLight"
            
            if lightPos and not plot:FindFirstChild(lightPartName) then
                local lightPart = Instance.new("Part")
                lightPart.Name = lightPartName
                lightPart.Size = Vector3.new(1, 1, 1)
                lightPart.Position = lightPos
                lightPart.Anchored = true
                lightPart.CanCollide = false
                lightPart.Transparency = 1
                
                local pointLight = Instance.new("PointLight")
                pointLight.Brightness = 1.5
                pointLight.Range = 30
                pointLight.Parent = lightPart
                
                lightPart.Parent = plot
            end
            
            local spawner = plot:FindFirstChild("Spawner")
            
            if spawner then
                for _, child in ipairs(spawner:GetChildren()) do
                    deleteUnions(child)
                end
                
                spawner.ChildAdded:Connect(deleteUnions)
            end
            
            break 
        end
    end
end
