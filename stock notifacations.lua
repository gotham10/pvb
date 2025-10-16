local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local ItemsData = {}
local itemsDataUrl = "https://raw.githubusercontent.com/gotham10/pvb/main/data"
local apiUrl = "https://plantsvsbrainrot.com/api/seed-shop.php"

local function updateItemsData()
    local success, response = pcall(function()
        return request({Url = itemsDataUrl, Method = "GET"})
    end)

    if success and response and response.StatusCode == 200 then
        local code = response.Body
        local returnableCode = code:gsub("local ItemsData = ", "return ", 1)
        local loadSuccess, loadedFunc = pcall(loadstring, returnableCode)
        if loadSuccess and type(loadedFunc) == "function" then
            local funcSuccess, data = pcall(loadedFunc)
            if funcSuccess and type(data) == "table" then
                ItemsData = data
            end
        end
    end
end

local function fetchAndProcessData()
    if not next(ItemsData) then return end
    
    local success, response = pcall(function()
        return request({
            Url = apiUrl,
            Method = "GET"
        })
    end)

    if success and response and response.StatusCode == 200 then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)

        if decodeSuccess and data and data.seeds then
            for _, seedInfo in ipairs(data.seeds) do
                print(seedInfo.name .. " - Quantity: " .. tostring(seedInfo.qty))
                local itemName = seedInfo.name
                local itemData = ItemsData[itemName]

                if itemData and itemData.IsTarget then
                    StarterGui:SetCore("SendNotification", {
                        Title = itemName,
                        Text = "Quantity: " .. tostring(seedInfo.qty),
                        Icon = itemData.Icon,
                        Duration = 270,
                    })
                end
            end
        end
    end
end

updateItemsData()
fetchAndProcessData()

while true do
    wait(300)
    fetchAndProcessData()
end
