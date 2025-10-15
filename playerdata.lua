local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataModule = ReplicatedStorage:WaitForChild("PlayerData")
local PlayerDataManager = getrenv().require(PlayerDataModule)
PlayerDataManager.Init()
local MyDataReplica = PlayerDataManager.GetData()
if MyDataReplica and MyDataReplica.Data then
    local function encodeJSON(tbl, indent)
        indent = indent or 0
        local lines = {}
        local spacing = string.rep("  ", indent)
        table.insert(lines, "{")
        local count = 0
        for k, v in pairs(tbl) do
            count = count + 1
            local key = '"' .. tostring(k) .. '": '
            if type(v) == "table" then
                table.insert(lines, spacing .. "  " .. key .. encodeJSON(v, indent + 1) .. ",")
            elseif type(v) == "string" then
                table.insert(lines, spacing .. "  " .. key .. '"' .. v .. '",')
            else
                table.insert(lines, spacing .. "  " .. key .. tostring(v) .. ",")
            end
        end
        if count > 0 then
            lines[#lines] = lines[#lines]:gsub(",$", "")
        end
        table.insert(lines, spacing .. "}")
        return table.concat(lines, "\n")
    end
    local jsonStr = encodeJSON(MyDataReplica.Data, 0)
    setclipboard(jsonStr)
end
