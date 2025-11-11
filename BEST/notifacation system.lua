local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local utilFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility")
local notifContainer = utilFolder:WaitForChild("Notification")
local template = notifContainer:FindFirstChild("Notification") or notifContainer:WaitForChild("Notification")
local pg = Player:WaitForChild("PlayerGui")
local notificationsGui = pg:FindFirstChild("Notifications") or Instance.new("ScreenGui", pg)
notificationsGui.Name = "Notifications"
notificationsGui.ResetOnSpawn = false
local notificationsFolder = notificationsGui:FindFirstChild("Notifications") or Instance.new("Folder", notificationsGui)
notificationsFolder.Name = "Notifications"

local gradientFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("MutationGradients")
local ruby = gradientFolder:WaitForChild("RubyScorched")

local function spawnNotification(text)
    local clone = template:Clone()
    local Message = clone:FindFirstChild("Message") or clone:FindFirstChildWhichIsA("TextLabel") or clone
    local Shadow = Message and Message:FindFirstChild("Shadow")
    if Message then
        Message.TextSize = 20
        Message.Text = text or ""
        Message.TextTransparency = 1
        if Message:FindFirstChild("UIStroke") then
            Message.UIStroke.Transparency = 1
        end
    end
    if Shadow then
        for _, v in ipairs(Shadow:GetChildren()) do v:Destroy() end
        local g = ruby:Clone()
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(1, 0.15)
        })
        g.Parent = Shadow
        Shadow.ImageTransparency = 0.15
    end
    clone.LayoutOrder = -(math.floor(tick() * 1000))
    clone.Parent = notificationsFolder
    local showTI = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if Shadow then TweenService:Create(Shadow, showTI, { ImageTransparency = 0.05 }):Play() end
    if Message then TweenService:Create(Message, showTI, { TextTransparency = 0 }):Play() end
    if Message and Message:FindFirstChild("UIStroke") then TweenService:Create(Message.UIStroke, showTI, { Transparency = 0 }):Play() end
    task.delay(3, function()
        local hideTI = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if Shadow then TweenService:Create(Shadow, hideTI, { ImageTransparency = 1 }):Play() end
        if Message then TweenService:Create(Message, hideTI, { TextTransparency = 1 }):Play() end
        if Message and Message:FindFirstChild("UIStroke") then TweenService:Create(Message.UIStroke, hideTI, { Transparency = 1 }):Play() end
        task.wait(0.25)
        clone:Destroy()
    end)
end

spawnNotification("Test")
