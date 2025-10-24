local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function prettyJSONEncode(val, indentLevel)
    local indentStr = "  "
    indentLevel = indentLevel or 0
    local indent = string.rep(indentStr, indentLevel)
    local indentInner = string.rep(indentStr, indentLevel + 1)
    
    local valType = type(val)
    
    if valType == "table" then
        local n = 0
        for _ in pairs(val) do
            n = n + 1
        end
        
        local isArray = #val == n
        
        if isArray then
            if #val == 0 then return "[]" end
            local parts = {}
            for i = 1, #val do
                table.insert(parts, indentInner .. prettyJSONEncode(val[i], indentLevel + 1))
            end
            return "[\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "]"
        else
            local keys = {}
            for k in pairs(val) do
                table.insert(keys, k)
            end
            table.sort(keys)
            
            if #keys == 0 then return "{}" end
            
            local parts = {}
            for _, k in ipairs(keys) do
                local keyStr = HttpService:JSONEncode(k)
                local valStr = prettyJSONEncode(val[k], indentLevel + 1)
                table.insert(parts, indentInner .. keyStr .. ": " .. valStr)
            end
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
        end
    elseif valType == "string" then
        return HttpService:JSONEncode(val)
    elseif valType == "number" or valType == "boolean" then
        return tostring(val)
    elseif valType == "nil" then
        return "null"
    else
        return HttpService:JSONEncode(tostring(val))
    end
end

local function analyzeBackpackBrainrot()
    local player = Players.LocalPlayer
    if not player then
        return
    end
    
    local backpack = player:WaitForChild("Backpack")
    local brainrotItems = {}
    local importantKeys = {
        ItemName = true,
        Mutation = true,
        Worth = true,
        Size = true
    }

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("Brainrot") ~= nil then
            local combinedAttributes = {}
            
            local model = tool:FindFirstChildOfClass("Model")
            if model then
                for attrName, attrValue in pairs(model:GetAttributes()) do
                    combinedAttributes[attrName] = attrValue
                end
            end
            
            for attrName, attrValue in pairs(tool:GetAttributes()) do
                if combinedAttributes[attrName] == nil then
                    combinedAttributes[attrName] = attrValue
                end
            end
            
            local importantAttributes = {}
            local keys = {}
            for k in pairs(importantKeys) do
                table.insert(keys, k)
            end
            table.sort(keys)

            for _, key in ipairs(keys) do
                 if combinedAttributes[key] ~= nil and combinedAttributes[key] ~= "" then
                    importantAttributes[key] = combinedAttributes[key]
                end
            end
            
            table.insert(brainrotItems, importantAttributes)
        end
    end

    local finalReport = prettyJSONEncode(brainrotItems, 0)
    print(finalReport)
    setclipboard(finalReport)
end

pcall(analyzeBackpackBrainrot)
