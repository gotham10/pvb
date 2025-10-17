local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local httpService = game:GetService("HttpService")

local plantData = {}

for _, tool in ipairs(backpack:GetChildren()) do
    if tool:IsA("Tool") and tool:GetAttribute("IsPlant") then
        local damage = tool:GetAttribute("Damage") or 0
        local cooldown = tool:GetAttribute("Cooldown") or 1
        local projectiles = tool:GetAttribute("Projectiles") or 1

        if cooldown == 0 then
            cooldown = 1
        end

        local dps = (damage * projectiles) / cooldown
        table.insert(plantData, {Name = tool.Name, DPS = math.floor(dps)})
    end
end

table.sort(plantData, function(a, b)
    return a.DPS > b.DPS
end)

local function toPrettyJSON(data)
    local jsonString = httpService:JSONEncode(data)
    local formattedString = ""
    local indentLevel = 0
    local inString = false

    for i = 1, #jsonString do
        local char = jsonString:sub(i, i)
        if char == '"' then
            inString = not inString
        end

        if not inString then
            if char == "{" or char == "[" then
                formattedString = formattedString .. char .. "\n" .. string.rep("  ", indentLevel + 1)
                indentLevel = indentLevel + 1
            elseif char == "}" or char == "]" then
                indentLevel = indentLevel - 1
                formattedString = formattedString .. "\n" .. string.rep("  ", indentLevel) .. char
            elseif char == "," then
                formattedString = formattedString .. char .. "\n" .. string.rep("  ", indentLevel)
            elseif char == ":" then
                formattedString = formattedString .. char .. " "
            elseif not char:match("%s") then
                formattedString = formattedString .. char
            end
        else
            formattedString = formattedString .. char
        end
    end
    return formattedString
end

local jsonOutput = toPrettyJSON(plantData)
setclipboard(jsonOutput)
